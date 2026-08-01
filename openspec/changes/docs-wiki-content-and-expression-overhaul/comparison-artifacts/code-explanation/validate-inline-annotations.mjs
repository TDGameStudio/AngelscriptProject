import fs from "node:fs";
import path from "node:path";
import { createRequire } from "node:module";
import { fileURLToPath, pathToFileURL } from "node:url";

const artifactDir = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(artifactDir, "../../../../..");
const requireFromWiki = createRequire(path.join(repoRoot, "Wiki", "package.json"));
const { chromium } = requireFromWiki("@playwright/test");

const targets = [
  {
    file: "05-as-interlinear-notes.html",
    expectedAnnotations: 5,
    signature: "ApplyDamageToTarget",
  },
  {
    file: "06-as-expression-footnotes.html",
    expectedAnnotations: 5,
    signature: "ApplyDamageToTarget",
  },
  {
    file: "07-cpp-block-commentary.html",
    expectedAnnotations: 5,
    signature: "InitializeAngelscript",
  },
  {
    file: "08-as-runtime-annotations.html",
    expectedAnnotations: 6,
    expectedScenarios: 3,
    signature: "ApplyDamageToTarget",
  },
];

const failures = [];
const results = [];

function fail(message) {
  failures.push(message);
}

function inspectStatic(target) {
  const targetPath = path.join(artifactDir, target.file);
  if (!fs.existsSync(targetPath)) {
    fail(`missing ${target.file}`);
    return null;
  }

  const html = fs.readFileSync(targetPath, "utf8");
  const checks = {
    doctype: /^<!doctype html>/i.test(html),
    inlineStyle: /<style>[\s\S]*<\/style>/i.test(html),
    inlineScript: /<script>[\s\S]*<\/script>/i.test(html),
    noExternalAssetTag: !/<(?:script|img|link)\b[^>]*(?:src|href)\s*=/i.test(html),
    evidencePath: /Script\/Examples|AngelscriptRuntime\/Core/.test(html),
    signature: html.includes(target.signature),
  };

  for (const [name, passed] of Object.entries(checks)) {
    if (!passed) fail(`${target.file}: static ${name}`);
  }

  return { targetPath, bytes: Buffer.byteLength(html), checks };
}

async function visibleAnnotationCount(page) {
  return page.locator("[data-annotation-id]").evaluateAll((nodes) =>
    nodes.filter((node) => {
      const style = getComputedStyle(node);
      return !node.hidden && style.display !== "none" && style.visibility !== "hidden";
    }).length,
  );
}

async function inspectDesktop(browser, target, targetPath) {
  const context = await browser.newContext({
    viewport: { width: 1440, height: 1000 },
    reducedMotion: "reduce",
  });
  const page = await context.newPage();
  const runtimeErrors = [];
  const externalRequests = [];

  page.on("pageerror", (error) => runtimeErrors.push(`pageerror:${error.message}`));
  page.on("console", (message) => {
    if (message.type() === "error") runtimeErrors.push(`console:${message.text()}`);
  });
  page.on("requestfailed", (request) =>
    runtimeErrors.push(`requestfailed:${request.url()}`),
  );
  page.on("request", (request) => {
    if (!request.url().startsWith("file:")) externalRequests.push(request.url());
  });

  await page.goto(pathToFileURL(targetPath).href);

  const initial = await page.evaluate(() => ({
    audit: window.__CODE_EXPLANATION_PREVIEW__?.audit(),
    annotationsState: document.documentElement.dataset.annotations,
    previewState: document.documentElement.dataset.previewState,
    overflow:
      document.documentElement.scrollWidth -
      document.documentElement.clientWidth,
    reduced: matchMedia("(prefers-reduced-motion: reduce)").matches,
  }));
  const initialVisible = await visibleAnnotationCount(page);

  if (!initial.audit) {
    fail(`${target.file}: missing preview audit`);
  } else {
    if (initial.audit.errors?.length) {
      fail(`${target.file}: audit ${initial.audit.errors.join("|")}`);
    }
    if (initial.audit.annotationCount !== target.expectedAnnotations) {
      fail(
        `${target.file}: annotationCount ${initial.audit.annotationCount}/${target.expectedAnnotations}`,
      );
    }
    if (!(initial.audit.sourceCount > 0)) {
      fail(`${target.file}: sourceCount must be positive`);
    }
  }
  if (initial.annotationsState !== "visible") {
    fail(`${target.file}: annotations default ${initial.annotationsState}`);
  }
  if (initial.previewState === "error") {
    fail(`${target.file}: preview error state`);
  }
  if (initial.overflow !== 0) {
    fail(`${target.file}: desktop overflow ${initial.overflow}`);
  }
  if (!initial.reduced) {
    fail(`${target.file}: reduced motion context inactive`);
  }
  if (initialVisible !== target.expectedAnnotations) {
    fail(
      `${target.file}: visible annotations ${initialVisible}/${target.expectedAnnotations}`,
    );
  }

  const toggle = page.locator('[data-action="toggle-notes"]');
  if ((await toggle.count()) !== 1) {
    fail(`${target.file}: toggle-notes control count`);
  } else {
    await toggle.click();
    const hiddenState = await page.evaluate(
      () => document.documentElement.dataset.annotations,
    );
    const hiddenVisible = await visibleAnnotationCount(page);
    if (hiddenState !== "hidden" || hiddenVisible !== 0) {
      fail(
        `${target.file}: hide notes state=${hiddenState} visible=${hiddenVisible}`,
      );
    }
    await toggle.click();
    const restoredVisible = await visibleAnnotationCount(page);
    if (restoredVisible !== target.expectedAnnotations) {
      fail(
        `${target.file}: restored annotations ${restoredVisible}/${target.expectedAnnotations}`,
      );
    }
  }

  const sourceText = await page.evaluate(
    () => window.__CODE_EXPLANATION_PREVIEW__?.sourceText(),
  );
  if (typeof sourceText !== "string" || !sourceText.includes(target.signature)) {
    fail(`${target.file}: clean source missing signature`);
  }
  for (const forbidden of ["WHY", "RESULT", "OWNERSHIP"]) {
    if (sourceText?.includes(forbidden)) {
      fail(`${target.file}: clean source contains annotation token ${forbidden}`);
    }
  }

  const copy = page.locator('[data-action="copy"]');
  if ((await copy.count()) !== 1) {
    fail(`${target.file}: copy control count`);
  } else {
    await copy.click();
    const copyReceipt = await page.locator("[data-copy-status]").innerText();
    if (!copyReceipt.trim()) fail(`${target.file}: empty copy receipt`);
  }

  const firstAnnotation = page.locator("[data-annotation-id]").first();
  await firstAnnotation.focus();
  await page.keyboard.press("Enter");
  const pinned = await page.locator('[data-pinned="true"]').count();
  await page.keyboard.press("Escape");
  const cleared = await page.locator('[data-pinned="true"]').count();
  if (pinned < 2 || cleared !== 0) {
    fail(`${target.file}: keyboard pin ${pinned}->${cleared}`);
  }

  const scenarioReceipts = [];
  if (target.expectedScenarios) {
    const scenarios = page.locator("[data-scenario-id]");
    const scenarioCount = await scenarios.count();
    if (scenarioCount !== target.expectedScenarios) {
      fail(
        `${target.file}: scenario count ${scenarioCount}/${target.expectedScenarios}`,
      );
    }
    for (let index = 0; index < scenarioCount; index += 1) {
      const scenario = scenarios.nth(index);
      const scenarioId = await scenario.getAttribute("data-scenario-id");
      await scenario.click();
      const scenarioAudit = await page.evaluate(
        () => window.__CODE_EXPLANATION_PREVIEW__.audit(),
      );
      const pressed = await page.locator(
        '[data-scenario-id][aria-pressed="true"]',
      ).count();
      if (scenarioAudit.selectedScenario !== scenarioId || pressed !== 1) {
        fail(
          `${target.file}: scenario ${scenarioId} audit=${scenarioAudit.selectedScenario} pressed=${pressed}`,
        );
      }
      scenarioReceipts.push(scenarioId);
    }
  }

  if (runtimeErrors.length) {
    fail(`${target.file}: runtime ${runtimeErrors.join("|")}`);
  }
  if (externalRequests.length) {
    fail(`${target.file}: network ${externalRequests.join("|")}`);
  }

  await context.close();
  return {
    audit: initial.audit,
    initialVisible,
    pinned,
    cleared,
    scenarios: scenarioReceipts,
    runtimeErrors,
    externalRequests,
  };
}

async function inspectMobile(browser, target, targetPath) {
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 },
    reducedMotion: "reduce",
  });
  const page = await context.newPage();
  const runtimeErrors = [];
  page.on("pageerror", (error) => runtimeErrors.push(error.message));
  page.on("console", (message) => {
    if (message.type() === "error") runtimeErrors.push(message.text());
  });

  await page.goto(pathToFileURL(targetPath).href);
  const mobile = await page.evaluate(() => ({
    overflow:
      document.documentElement.scrollWidth -
      document.documentElement.clientWidth,
    annotationsState: document.documentElement.dataset.annotations,
    auditErrors:
      window.__CODE_EXPLANATION_PREVIEW__?.audit().errors ?? [
        "missing audit",
      ],
  }));

  if (
    mobile.overflow !== 0 ||
    mobile.annotationsState !== "visible" ||
    mobile.auditErrors.length ||
    runtimeErrors.length
  ) {
    fail(
      `${target.file}: mobile ${JSON.stringify({ ...mobile, runtimeErrors })}`,
    );
  }

  await context.close();
  return { ...mobile, runtimeErrors };
}

const staticInspections = targets.map((target) => ({
  target,
  inspection: inspectStatic(target),
}));

const browser = await chromium.launch({ headless: true });
try {
  for (const { target, inspection } of staticInspections) {
    if (!inspection) continue;
    const desktop = await inspectDesktop(browser, target, inspection.targetPath);
    const mobile = await inspectMobile(browser, target, inspection.targetPath);
    results.push({
      file: target.file,
      bytes: inspection.bytes,
      desktop,
      mobile,
    });
  }
} finally {
  await browser.close();
}

console.log(
  JSON.stringify(
    {
      passedFiles: results.map((result) => result.file),
      targetCount: targets.length,
      failureCount: failures.length,
      failures,
    },
    null,
    2,
  ),
);

if (failures.length) process.exit(1);
