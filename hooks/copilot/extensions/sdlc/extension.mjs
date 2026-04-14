import { joinSession } from "@github/copilot-sdk/extension";

// Build-time replacement target -- must be exactly this string
const AGENTS = "__AGENTS_PLACEHOLDER__";

const PIPELINES = {
  full: [
    "architect",
    "ux-designer?",
    "skeptic-design",
    "developer",
    "skeptic-code|security-auditor",
    "tester",
    "friction-reviewer",
  ],
  light: [
    "ux-designer?",
    "developer",
    "skeptic-code|security-auditor",
    "tester",
    "friction-reviewer",
  ],
};

// Map pipeline step names to AGENTS keys
function agentKey(step) {
  const clean = step.replace(/\?$/, "");
  if (clean === "skeptic-design" || clean === "skeptic-code") return "skeptic";
  return clean;
}

// Gate roles that block on non-approved verdict
const GATE_ROLES = ["skeptic-design", "skeptic-code", "security-auditor"];

// Build role prompt from agent def + task + relay context
function buildRolePrompt(role, agentDef, task, relay) {
  const label = role
    .split("-")
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(" ");

  let framing = "";
  if (role === "skeptic-design") {
    framing =
      "You are reviewing the DESIGN for correctness, completeness, and risk. This is a design review, not a code review.";
  } else if (role === "skeptic-code") {
    framing =
      "You are reviewing the IMPLEMENTATION code for bugs, quality, and adherence to the approved design. This is a code review.";
  }

  const parts = [
    `**[${label}]**`,
    `<role-definition>\n${agentDef}\n</role-definition>`,
  ];
  if (framing) parts.push(framing);

  if (GATE_ROLES.includes(role)) {
    parts.push(
      "You MUST end your response with a verdict line in this exact format:\n" +
        "**Verdict:** Approved | Rejected | Revise\n" +
        "**Reason:** <one-line explanation>\n" +
        "Do not omit the verdict."
    );
  }

  parts.push(`Task: ${task}`);
  if (relay) parts.push(`Upstream context:\n${relay}`);
  return parts.join("\n\n");
}

// Parse verdict from response content. Gate roles that omit a verdict get "missing".
function parseVerdict(content, role) {
  const match = content.match(/\*\*Verdict:\*\*\s*(Approved|Rejected|Revise)/i);
  if (!match) {
    return GATE_ROLES.includes(role) ? "missing" : "approved";
  }
  return match[1].toLowerCase();
}

// Extract reason from verdict block
function extractReason(content) {
  const match = content.match(/\*\*Reason:\*\*\s*(.+)/i);
  if (match) return match[1].trim();
  // Fallback: grab text after the verdict line
  const verdictMatch = content.match(
    /\*\*Verdict:\*\*\s*(?:Approved|Rejected|Revise)\s*[—\-:]*\s*(.*)/i
  );
  if (verdictMatch && verdictMatch[1].trim()) return verdictMatch[1].trim();
  return "no reason provided";
}

// Run a single role
async function runRole(session, role, task, relay) {
  const key = agentKey(role);
  const agentDef = AGENTS[key];
  if (!agentDef) {
    throw new Error(`No agent definition found for key "${key}" (role: ${role})`);
  }

  const prompt = buildRolePrompt(role, agentDef, task, relay);

  await session.log(`[SDLC] Starting: ${role}`);
  const response = await session.sendAndWait({ prompt }, 300000);

  if (!response) {
    throw new Error(
      `sendAndWait returned undefined for role "${role}" -- session may have ended`
    );
  }

  const section = response.data?.content ?? "";
  if (!section) {
    throw new Error(
      `Role "${role}" produced empty response (keys: ${Object.keys(response.data ?? {}).join(", ") || "none"})`
    );
  }
  const verdict = parseVerdict(section, role);
  await session.log(`[SDLC] Completed: ${role} (verdict: ${verdict})`);

  return { role, section, verdict };
}

// Build gate error message based on verdict type
function gateError(role, verdict, content) {
  const reason = extractReason(content);
  if (verdict === "rejected") {
    return `Pipeline blocked: ${role} rejected -- ${reason}`;
  }
  if (verdict === "revise") {
    return `Pipeline blocked: ${role} requests revision -- ${reason}`;
  }
  if (verdict === "missing") {
    return `Pipeline blocked: ${role} did not provide a verdict`;
  }
  return `Pipeline blocked: ${role} verdict is "${verdict}"`;
}

// Run full pipeline
async function runPipeline(session, mode, task, hasUI) {
  const steps = PIPELINES[mode];
  if (!steps) throw new Error(`Unknown pipeline mode: "${mode}"`);

  let relay = "";

  for (const step of steps) {
    // Handle conditional steps (? suffix)
    if (step.endsWith("?")) {
      if (!hasUI) {
        await session.log(`[SDLC] Skipping (no UI): ${step.replace(/\?$/, "")}`);
        continue;
      }
    }

    // Handle concurrent steps (| separator) -- run sequentially per SDK constraint
    if (step.includes("|")) {
      const roles = step.split("|").map((r) => r.replace(/\?$/, ""));

      for (const r of roles) {
        const result = await runRole(session, r, task, relay);
        relay += `\n\n## ${result.role}\n${result.section}`;

        if (GATE_ROLES.includes(result.role) && result.verdict !== "approved") {
          throw new Error(gateError(result.role, result.verdict, result.section));
        }
      }
      continue;
    }

    // Sequential step
    const role = step.replace(/\?$/, "");
    const result = await runRole(session, role, task, relay);
    relay += `\n\n## ${result.role}\n${result.section}`;

    if (GATE_ROLES.includes(role) && result.verdict !== "approved") {
      throw new Error(gateError(role, result.verdict, result.section));
    }
  }

  await session.log("[SDLC] Pipeline complete.");
}

// Join session with slash commands, tools + hooks
const session = await joinSession({
  slashCommands: [
    {
      name: "sdlc",
      description:
        "Start a structured SDLC pipeline run. Provide a task description after the command.",
      action: async (sess, params) => {
        const task = params?.args?.trim() || "";
        if (!task) {
          await sess.send({
            prompt:
              "The user invoked /sdlc without a task description. Ask them what they want to build or fix, " +
              "then call the sdlc_pipeline tool with the appropriate mode, task, and hasUI.",
          });
          return;
        }
        await sess.send({
          prompt:
            `The user wants an SDLC pipeline run for: "${task}". ` +
            "Determine the appropriate mode (full for new features, light for bug fixes/clear-scope changes) " +
            "and whether it involves UI changes, then call the sdlc_pipeline tool.",
        });
      },
    },
  ],
  tools: [
    {
      name: "sdlc_pipeline",
      description:
        "Run structured SDLC pipeline (multi-role: architect, skeptic, developer, security auditor, tester, friction reviewer). " +
        "Call when the user says /sdlc, asks to 'start pipeline', or wants a disciplined multi-role workflow for a feature or fix. " +
        "The tool orchestrates each role sequentially, enforcing gate reviews before proceeding.",
      skipPermission: true,
      parameters: {
        type: "object",
        properties: {
          mode: {
            type: "string",
            enum: ["full", "light"],
            description:
              "Pipeline mode. full: new features (architect-first). light: bug fixes, clear-scope changes.",
          },
          task: {
            type: "string",
            description: "One-line task description.",
          },
          hasUI: {
            type: "boolean",
            description:
              "Whether the task involves UI changes (triggers UX Designer role).",
          },
        },
        required: ["mode", "task", "hasUI"],
      },
      handler: async (args) => {
        try {
          await runPipeline(session, args.mode, args.task, args.hasUI);
          return {
            textResultForLlm: "Pipeline complete.",
            resultType: "success",
          };
        } catch (err) {
          return {
            textResultForLlm: `Pipeline failed: ${err.message}`,
            resultType: "failure",
          };
        }
      },
    },
  ],
  hooks: {
    onUserPromptSubmitted: async (input) => {
      if (
        /\/sdlc\b|(?:start|run|execute)\s+(?:the\s+)?sdlc\s+pipeline/i.test(
          input.prompt
        )
      ) {
        return {
          additionalContext:
            "The user wants an SDLC pipeline run. Call the sdlc_pipeline tool with mode, task, and hasUI.",
        };
      }
      return {};
    },
    onErrorOccurred: async (error) => {
      if (
        error?.code === "model_call" ||
        error?.message?.includes("model_call")
      ) {
        return { retryCount: 2 };
      }
      return {};
    },
    onSessionStart: async () => {
      await session.log("[SDLC] Extension loaded.");
      return {};
    },
  },
});
