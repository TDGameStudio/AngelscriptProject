import crypto from "node:crypto";
import fs from "node:fs/promises";
import { createRequire } from "node:module";
import path from "node:path";
import process from "node:process";
import { fileURLToPath, pathToFileURL } from "node:url";

const validatorDir = path.dirname(fileURLToPath(import.meta.url));
const changeDir = path.resolve(validatorDir, "..", "..");
const repoRoot = path.resolve(changeDir, "..", "..", "..");
const galleryPath = path.join(changeDir, "research", "code-explanation", "reference-gallery.html");
const requireFromWiki = createRequire(path.join(repoRoot, "Wiki", "package.json"));
const { chromium } = requireFromWiki("@playwright/test");

const legacyFiles = {
  "01-as-line-bridge.html": "BBC96CDB62EDD8D23845DC31169585DCC396C726F89D2CFFBCBA9E71308C7516",
  "02-as-execution-receipt.html": "DB21D55B2D56AFA40B5A993E836FCE0A6F73B4F97B05920B90260BB3CD715120",
  "03-cpp-initialization-router.html": "1549580A99D15D5CDA4FC2DFDE8D27FEA8357A1CC02ED2332FFFD69F9113D477",
  "04-as-cpp-reflective-boundary.html": "D2A715A48455A835E7EB3BD8FD44CAC8D7E5A8E2BEC4D3ECDE58A724A195E7BF",
  "05-as-interlinear-notes.html": "7A4024F93EA2BC70270B4828F136FBBC92E58726129699DD1C4E27E4A04C06B3",
  "06-as-expression-footnotes.html": "58AC172B4AE57015B5C95737C946C7742164AAB1A022F2394B5B844365C3C009",
  "07-cpp-block-commentary.html": "148CFD561E448F1A55F7EEFBAC168C801CD21C871098DB4BEE087CAD88CCF1D1",
  "08-as-runtime-annotations.html": "9E3F1AB6822BAEB235356BE276CA52815C2A5627E973DDA0079FA0471C8E48BD",
  "09-as-rail-margin-notes.html": "79139047F4E9B77BAE52AF4515AF03A128212CC885B70C420815537175AA0EB4",
  "10-cpp-range-rail-notes.html": "9576DEF2AD0824D4C756D6806D84948178AD5457C469274D0ED25EBF28BFEF00",
  "11-as-edge-tags.html": "04179F04D45900141857A9CC9EC361A9DFA097C425EE226306C8A929BB3C1EC6",
  "12-cpp-free-callouts.html": "8DA885883289F4C178AA6E8734B8D70CF657A439817D3B5702E9B223C59F87CE",
  "13-as-embedded-note-chips.html": "3276AF117BC67BC08353158EF73FCC5BF36B42336EBC8CB48FD750D9336793F4"
};

const targets = [
  {
    file: "09-as-rail-margin-notes.html",
    layoutMode: "rail",
    connectorMode: "css",
    sourceKind: "as"
  },
  {
    file: "10-cpp-range-rail-notes.html",
    layoutMode: "rail",
    connectorMode: "svg",
    sourceKind: "cpp"
  },
  {
    file: "11-as-edge-tags.html",
    layoutMode: "free",
    connectorMode: "css",
    sourceKind: "as"
  },
  {
    file: "12-cpp-free-callouts.html",
    layoutMode: "free",
    connectorMode: "svg",
    sourceKind: "cpp"
  },
  {
    file: "13-as-embedded-note-chips.html",
    layoutMode: "embedded",
    connectorMode: "css",
    sourceKind: "as"
  },
  {
    file: "14-as-adaptive-embedded-notes.html",
    layoutMode: "embedded-adaptive",
    connectorMode: "svg-native",
    sourceKind: "as-enhanced-input",
    library: {
      name: "native",
      version: "web-platform",
      license: "n/a"
    },
    strictCollision: true,
    checkEndpoints: true
  },
  {
    file: "15-cpp-linkerline-embedded-notes.html",
    layoutMode: "embedded-adaptive",
    connectorMode: "linkerline",
    sourceKind: "cpp-call-binds",
    library: {
      name: "linkerline",
      version: "1.6.1",
      license: "MIT",
      licenseNotice: "Copyright (c) 2024 Ahmed Ayachi"
    },
    strictCollision: true,
    checkEndpoints: true
  },
  {
    file: "16-as-perfect-arrows-embedded-notes.html",
    layoutMode: "embedded-adaptive",
    connectorMode: "perfect-arrows",
    sourceKind: "as-interface",
    library: {
      name: "perfect-arrows",
      version: "0.3.7",
      license: "MIT",
      licenseNotice: "Copyright (c) 2020 Steve"
    },
    strictCollision: true,
    checkEndpoints: true
  },
  {
    file: "17-cpp-floating-ui-embedded-notes.html",
    layoutMode: "embedded-adaptive",
    connectorMode: "floating-ui+svg",
    sourceKind: "cpp-subsystem",
    library: {
      name: "@floating-ui/dom",
      version: "1.8.0",
      license: "MIT",
      licenseNotice: "Copyright (c) 2021-present Floating UI contributors"
    },
    strictCollision: true,
    checkEndpoints: true,
    floatingDetails: true
  }
];

const failures = [];
const passedFiles = [];

function fail(scope, message) {
  failures.push(`${scope}: ${message}`);
}

function normalize(text) {
  return text.replace(/\r\n/g, "\n").replace(/[ \t]+$/gm, "").trim();
}

function extractBalancedFunction(text, startMarker, prefixMarker = startMarker) {
  const normalized = text.replace(/\r\n/g, "\n");
  const signatureIndex = normalized.indexOf(startMarker);
  if (signatureIndex < 0) {
    throw new Error(`source marker not found: ${startMarker}`);
  }
  const prefixIndex = normalized.lastIndexOf(prefixMarker, signatureIndex);
  const startIndex = prefixIndex >= 0 ? prefixIndex : signatureIndex;
  const braceStart = normalized.indexOf("{", signatureIndex);
  if (braceStart < 0) {
    throw new Error(`opening brace not found after: ${startMarker}`);
  }
  let depth = 0;
  for (let index = braceStart; index < normalized.length; index += 1) {
    const char = normalized[index];
    if (char === "{") depth += 1;
    if (char === "}") {
      depth -= 1;
      if (depth === 0) return normalize(normalized.slice(startIndex, index + 1));
    }
  }
  throw new Error(`closing brace not found after: ${startMarker}`);
}

async function expectedSources() {
  const asPath = path.join(repoRoot, "Script", "Examples", "Extended", "Example_InterfaceDispatch.as");
  const cppPath = path.join(
    repoRoot,
    "Plugins",
    "Angelscript",
    "Source",
    "AngelscriptRuntime",
    "Core",
    "AngelscriptRuntimeModule.cpp"
  );
  const enhancedInputPath = path.join(
    repoRoot,
    "Script",
    "Examples",
    "EnhancedInput",
    "Example_EI_Component.as"
  );
  const bindsPath = path.join(
    repoRoot,
    "Plugins",
    "Angelscript",
    "Source",
    "AngelscriptRuntime",
    "Core",
    "AngelscriptBinds.cpp"
  );
  const subsystemPath = path.join(
    repoRoot,
    "Plugins",
    "Angelscript",
    "Source",
    "AngelscriptRuntime",
    "Core",
    "AngelscriptSubsystem.cpp"
  );
  const [asText, cppText, enhancedInputText, bindsText, subsystemText] = await Promise.all([
    fs.readFile(asPath, "utf8"),
    fs.readFile(cppPath, "utf8"),
    fs.readFile(enhancedInputPath, "utf8"),
    fs.readFile(bindsPath, "utf8"),
    fs.readFile(subsystemPath, "utf8")
  ]);
  return {
    as: extractBalancedFunction(
      asText,
      "void ApplyDamageToTarget(AExampleDamageableBase Target, float Damage)",
      'UFUNCTION(Category = "Example Dispatch")'
    ),
    cpp: extractBalancedFunction(
      cppText,
      "void FAngelscriptRuntimeModule::InitializeAngelscript()"
    ),
    "as-enhanced-input": extractBalancedFunction(
      enhancedInputText,
      "void BeginPlay()",
      "UFUNCTION(BlueprintOverride)"
    ),
    "cpp-call-binds": extractBalancedFunction(
      bindsText,
      "void FAngelscriptBinds::CallBinds(const TSet<FName>& DisabledBindNames)"
    ),
    "as-interface": extractBalancedFunction(
      asText,
      "void ApplyDamageToTarget(AExampleDamageableBase Target, float Damage)",
      'UFUNCTION(Category = "Example Dispatch")'
    ),
    "cpp-subsystem": extractBalancedFunction(
      subsystemText,
      "void UAngelscriptSubsystem::EnsurePrimaryEngineInitialized()"
    )
  };
}

function sha256(buffer) {
  return crypto.createHash("sha256").update(buffer).digest("hex").toUpperCase();
}

async function checkLegacyFiles() {
  for (const [file, expectedHash] of Object.entries(legacyFiles)) {
    const filePath = path.join(validatorDir, file);
    try {
      const buffer = await fs.readFile(filePath);
      const actualHash = sha256(buffer);
      if (actualHash !== expectedHash) {
        fail(file, `legacy hash changed; expected ${expectedHash}, received ${actualHash}`);
      }
    } catch (error) {
      fail(file, `legacy file missing or unreadable: ${error.message}`);
    }
  }
}

function hasStandaloneShell(html) {
  return /^<!doctype html>/i.test(html)
    && /<style>[\s\S]*<\/style>/i.test(html)
    && /<script>[\s\S]*<\/script>/i.test(html);
}

function hasExternalAsset(html) {
  return /<script\b[^>]*\bsrc\s*=/i.test(html)
    || /<link\b[^>]*\bhref\s*=/i.test(html)
    || /<img\b[^>]*\bsrc\s*=\s*["']https?:/i.test(html);
}

async function withPage(browser, viewport, callback) {
  const context = await browser.newContext({
    viewport,
    reducedMotion: "reduce"
  });
  const page = await context.newPage();
  const consoleErrors = [];
  const externalRequests = [];
  page.on("console", (message) => {
    if (message.type() === "error") consoleErrors.push(message.text());
  });
  page.on("request", (request) => {
    if (/^https?:/i.test(request.url())) externalRequests.push(request.url());
  });
  try {
    await callback(page, consoleErrors, externalRequests);
  } finally {
    await context.close();
  }
}

async function checkGallery(browser) {
  const scope = "reference-gallery.html";
  let html;
  try {
    html = await fs.readFile(galleryPath, "utf8");
  } catch (error) {
    fail(scope, `missing gallery: ${error.message}`);
    return;
  }

  if (!hasStandaloneShell(html)) fail(scope, "missing standalone doctype/style/script shell");
  if (hasExternalAsset(html)) fail(scope, "contains an external runtime asset");

  for (const viewport of [{ width: 1440, height: 1000 }, { width: 390, height: 844 }]) {
    await withPage(browser, viewport, async (page, consoleErrors, externalRequests) => {
      await page.goto(pathToFileURL(galleryPath).href);
      await page.waitForLoadState("domcontentloaded");

      const audit = await page.evaluate(() => window.__REFERENCE_GALLERY__?.audit?.());
      if (!audit) {
        fail(scope, `${viewport.width}px missing __REFERENCE_GALLERY__.audit()`);
        return;
      }
      if (audit.errors?.length) fail(scope, `${viewport.width}px audit errors: ${audit.errors.join(" | ")}`);
      if (audit.referenceCount !== 10) fail(scope, `${viewport.width}px expected 10 references, received ${audit.referenceCount}`);

      const cardFacts = await page.locator("[data-reference-id]").evaluateAll((cards) =>
        cards.map((card) => ({
          image: card.querySelector("img")?.getAttribute("src") || "",
          source: card.querySelector("a[data-source-link]")?.getAttribute("href") || "",
          strengths: card.querySelectorAll("[data-strengths] li").length,
          limitations: card.querySelectorAll("[data-limitations] li").length,
          adoption: Boolean(card.querySelector("[data-adoption]"))
        }))
      );
      if (cardFacts.length !== 10) fail(scope, `${viewport.width}px expected 10 cards, received ${cardFacts.length}`);
      cardFacts.forEach((fact, index) => {
        if (!fact.image.startsWith("data:image/webp;base64,")) fail(scope, `card ${index + 1} screenshot is not embedded WebP`);
        if (!/^https:\/\//.test(fact.source)) fail(scope, `card ${index + 1} has no direct HTTPS source`);
        if (fact.strengths < 2) fail(scope, `card ${index + 1} has fewer than two strengths`);
        if (fact.limitations < 1) fail(scope, `card ${index + 1} has no limitation`);
        if (!fact.adoption) fail(scope, `card ${index + 1} has no adoption decision`);
      });

      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      if (overflow > 1) fail(scope, `${viewport.width}px page overflow ${overflow}px`);
      if (externalRequests.length) fail(scope, `${viewport.width}px external requests: ${externalRequests.join(", ")}`);
      if (consoleErrors.length) fail(scope, `${viewport.width}px console errors: ${consoleErrors.join(" | ")}`);

      const enlarge = page.locator('[data-action="enlarge"]').first();
      await enlarge.click();
      if (!(await page.locator("dialog[open]").isVisible())) fail(scope, `${viewport.width}px image dialog did not open`);
      await page.keyboard.press("Escape");
      if (await page.locator("dialog[open]").count()) fail(scope, `${viewport.width}px Escape did not close image dialog`);
    });
  }

  if (!failures.some((message) => message.startsWith(`${scope}:`))) passedFiles.push(scope);
}

async function sourceGeometry(page) {
  return page.locator("[data-source-root] > .code-row").evaluateAll((rows) => {
    const canvasRect = document.querySelector(".annotation-canvas")?.getBoundingClientRect();
    return rows.map((row) => {
      const rect = row.getBoundingClientRect();
      return {
        x: canvasRect ? rect.x - canvasRect.x : rect.x,
        y: canvasRect ? rect.y - canvasRect.y : rect.y,
        width: rect.width,
        height: rect.height
      };
    });
  });
}

function compareGeometry(before, after) {
  if (before.length !== after.length) return false;
  return before.every((rect, index) =>
    ["x", "y", "width", "height"].every((key) => Math.abs(rect[key] - after[index][key]) <= 0.5)
  );
}

async function checkSvgEndpoints(page, file) {
  const endpointErrors = await page.evaluate(() => {
    const canvas = document.querySelector(".annotation-canvas");
    if (!canvas) return ["missing annotation canvas"];
    return [...document.querySelectorAll('[data-connector-layer] [data-connector-for]')].flatMap((connector) => {
      const coordinateRoot = connector.closest(".paper-stage") || canvas;
      const canvasRect = coordinateRoot.getBoundingClientRect();
      const id = connector.dataset.connectorFor;
      const note = document.querySelector(`[data-annotation-id="${id}"] [data-note-port]`);
      const source = document.querySelector(`[data-source-port="${id}"]`);
      if (!note || !source) return [`${id}: missing source or note port`];
      const noteRect = note.getBoundingClientRect();
      const sourceRect = source.getBoundingClientRect();
      const expectedStart = {
        x: sourceRect.left + sourceRect.width / 2 - canvasRect.left,
        y: sourceRect.top + sourceRect.height / 2 - canvasRect.top
      };
      const expectedEnd = {
        x: noteRect.left + noteRect.width / 2 - canvasRect.left,
        y: noteRect.top + noteRect.height / 2 - canvasRect.top
      };
      const actualStart = {
        x: Number(connector.dataset.startX),
        y: Number(connector.dataset.startY)
      };
      const actualEnd = {
        x: Number(connector.dataset.endX),
        y: Number(connector.dataset.endY)
      };
      const distance = (a, b) => Math.hypot(a.x - b.x, a.y - b.y);
      const errors = [];
      if (![actualStart.x, actualStart.y, actualEnd.x, actualEnd.y].every(Number.isFinite)) {
        errors.push(`${id}: connector endpoint metadata is not finite`);
      } else {
        if (distance(expectedStart, actualStart) > 4) errors.push(`${id}: source endpoint exceeds 4px`);
        if (distance(expectedEnd, actualEnd) > 4) errors.push(`${id}: note endpoint exceeds 4px`);
      }
      return errors;
    });
  });
  endpointErrors.forEach((message) => fail(file, message));
}

async function checkPreview(browser, target, sources) {
  const filePath = path.join(validatorDir, target.file);
  let html;
  try {
    html = await fs.readFile(filePath, "utf8");
  } catch (error) {
    fail(target.file, `missing target: ${error.message}`);
    return;
  }

  if (!hasStandaloneShell(html)) fail(target.file, "missing standalone doctype/style/script shell");
  if (hasExternalAsset(html)) fail(target.file, "contains an external runtime asset");
  if (target.library?.licenseNotice) {
    if (!html.includes(target.library.licenseNotice)) {
      fail(target.file, `missing dependency copyright notice: ${target.library.licenseNotice}`);
    }
    if (!html.includes("Permission is hereby granted, free of charge")) {
      fail(target.file, "missing embedded MIT permission notice");
    }
  }

  for (const viewport of [{ width: 1440, height: 1000 }, { width: 390, height: 844 }]) {
    await withPage(browser, viewport, async (page, consoleErrors, externalRequests) => {
      await page.goto(pathToFileURL(filePath).href);
      await page.waitForLoadState("domcontentloaded");
      await page.evaluate(() => window.__CODE_EXPLANATION_PREVIEW__?.refreshConnectors?.());

      const audit = await page.evaluate(() => window.__CODE_EXPLANATION_PREVIEW__?.audit?.());
      if (!audit) {
        fail(target.file, `${viewport.width}px missing preview audit`);
        return;
      }
      if (audit.errors?.length) fail(target.file, `${viewport.width}px audit errors: ${audit.errors.join(" | ")}`);
      if (audit.layoutMode !== target.layoutMode) fail(target.file, `${viewport.width}px expected layout ${target.layoutMode}`);
      if (audit.connectorMode !== target.connectorMode) fail(target.file, `${viewport.width}px expected connector ${target.connectorMode}`);
      if (audit.annotationCount !== 5) fail(target.file, `${viewport.width}px expected five annotations`);
      if (audit.connectorCount !== 5) fail(target.file, `${viewport.width}px expected five connectors`);
      if (audit.sourceContinuous !== true) fail(target.file, `${viewport.width}px sourceContinuous is not true`);
      if (target.library) {
        for (const key of ["name", "version", "license"]) {
          if (audit.library?.[key] !== target.library[key]) {
            fail(
              target.file,
              `${viewport.width}px expected library ${key}=${target.library[key]}, received ${audit.library?.[key]}`
            );
          }
        }
        if (!Number.isSafeInteger(audit.library?.inlineBytes) || audit.library.inlineBytes < 0) {
          fail(target.file, `${viewport.width}px library inlineBytes is not a non-negative integer`);
        }
        if (!/^https:\/\//.test(audit.library?.upstream || "") && audit.library?.name !== "native") {
          fail(target.file, `${viewport.width}px library has no direct HTTPS upstream`);
        }
      }
      if (target.strictCollision && audit.collisions?.length) {
        fail(target.file, `${viewport.width}px collisions: ${audit.collisions.join(" | ")}`);
      }

      const expected = sources[target.sourceKind];
      const actualSource = await page.evaluate(() => window.__CODE_EXPLANATION_PREVIEW__.sourceText());
      if (normalize(actualSource) !== expected) fail(target.file, `${viewport.width}px sourceText differs from repository source`);

      const structure = await page.evaluate(() => {
        const root = document.querySelector("[data-source-root]");
        return {
          root: Boolean(root),
          childCount: root?.children.length || 0,
          allRows: root ? [...root.children].every((child) => child.classList.contains("code-row")) : false,
          nestedAnnotations: root?.querySelectorAll("[data-annotation-id]").length || 0,
          nestedConnectors: root?.querySelectorAll("[data-connector-layer], [data-connector-for]").length || 0,
          notes: document.querySelectorAll("[data-annotation-id]").length,
          connectors: document.querySelectorAll("[data-connector-for]").length,
          rails: document.querySelectorAll("[data-note-rail]").length
        };
      });
      if (!structure.root || !structure.childCount || !structure.allRows) fail(target.file, `${viewport.width}px source root is not continuous rows`);
      if (structure.nestedAnnotations || structure.nestedConnectors) fail(target.file, `${viewport.width}px source root contains note/connector nodes`);
      if (structure.notes !== 5 || structure.connectors !== 5) fail(target.file, `${viewport.width}px note/connector DOM count mismatch`);
      if (target.layoutMode === "rail" && structure.rails !== 1) fail(target.file, `${viewport.width}px rail page must have one rail`);
      if (target.layoutMode !== "rail" && structure.rails !== 0) fail(target.file, `${viewport.width}px non-rail page must not have a rail`);

      const clippedSourceLines = await page.locator("[data-source-root] > .code-row .code-text").evaluateAll((items) =>
        items
          .filter((item) => item.scrollWidth - item.clientWidth > 1)
          .map((item) => item.closest(".code-row")?.getAttribute("data-source-line") || "?")
      );
      if (clippedSourceLines.length) {
        fail(target.file, `${viewport.width}px source lines clipped by code paper: ${clippedSourceLines.join(", ")}`);
      }

      const summariesVisible = await page.locator(
        "[data-annotation-id] > summary, [data-annotation-id] > [data-note-summary]"
      ).evaluateAll((items) =>
        items.every((item) => {
          const style = getComputedStyle(item);
          const rect = item.getBoundingClientRect();
          return style.visibility !== "hidden" && style.display !== "none" && rect.width > 0 && rect.height > 0;
        })
      );
      if (!summariesVisible) fail(target.file, `${viewport.width}px short notes are not all visible`);
      if (target.layoutMode === "embedded-adaptive" && viewport.width === 1440) {
        const escapedSummaries = await page.locator("[data-annotation-id]").evaluateAll((notes) => {
          const viewportRect = document.querySelector(".annotation-viewport")?.getBoundingClientRect();
          if (!viewportRect) return ["missing-annotation-viewport"];
          return notes.flatMap((note) => {
            const summary = note.querySelector("[data-note-summary]");
            if (!summary) return [note.getAttribute("data-annotation-id") || "unknown-note"];
            const rect = summary.getBoundingClientRect();
            return rect.left < viewportRect.left - 1 || rect.right > viewportRect.right + 1
              ? [note.getAttribute("data-annotation-id") || "unknown-note"]
              : [];
          });
        });
        if (escapedSummaries.length) {
          fail(
            target.file,
            `${viewport.width}px short notes escaped initial desktop viewport: ${escapedSummaries.join(", ")}`
          );
        }
      }
      if (await page.locator("[data-annotation-id][open]").count()) fail(target.file, `${viewport.width}px details are open by default`);

      const before = await sourceGeometry(page);
      const firstNote = page.locator("[data-annotation-id]").first();
      const firstSummary = firstNote.locator("summary, [data-note-summary]");
      await firstSummary.hover();
      if (!(await firstNote.locator(".note-detail").isVisible())) fail(target.file, `${viewport.width}px hover did not reveal detail`);
      await firstSummary.focus();
      if (!(await firstNote.locator(".note-detail").isVisible())) fail(target.file, `${viewport.width}px focus did not reveal detail`);
      await page.keyboard.press("Enter");
      if (!(await firstNote.getAttribute("open") !== null)) fail(target.file, `${viewport.width}px Enter did not pin note`);
      const afterPin = await sourceGeometry(page);
      if (!compareGeometry(before, afterPin)) fail(target.file, `${viewport.width}px pin changed source geometry`);
      await page.keyboard.press("Escape");
      if (await page.locator("[data-annotation-id][open]").count()) fail(target.file, `${viewport.width}px Escape did not clear pin`);

      await page.locator('[data-action="toggle-notes"]').click();
      const afterHide = await sourceGeometry(page);
      if (!compareGeometry(before, afterHide)) fail(target.file, `${viewport.width}px hiding notes changed source geometry`);
      await page.locator('[data-action="toggle-notes"]').click();

      await page.locator('[data-action="copy"]').click();
      const state = await page.locator("html").getAttribute("data-preview-state");
      if (state !== "copied") fail(target.file, `${viewport.width}px copy did not enter copied state`);

      const pageOverflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      if (pageOverflow > 1) fail(target.file, `${viewport.width}px page overflow ${pageOverflow}px`);
      if (viewport.width === 390) {
        const containedScroll = await page.locator(".annotation-viewport").evaluate((element) => element.scrollWidth > element.clientWidth);
        if (!containedScroll) fail(target.file, "390px canvas does not retain contained horizontal scroll");
      }
      if (externalRequests.length) fail(target.file, `${viewport.width}px external requests: ${externalRequests.join(", ")}`);
      if (consoleErrors.length) fail(target.file, `${viewport.width}px console errors: ${consoleErrors.join(" | ")}`);

      if (target.connectorMode === "svg" || target.checkEndpoints) {
        await checkSvgEndpoints(page, target.file);
      }

      if (target.file.includes("linkerline")) {
        const linkerLineFacts = await page.evaluate(() => ({
          inside: document.querySelectorAll(".code-paper [data-linker-line-runtime]").length,
          outside: [...document.querySelectorAll("[data-linker-line-runtime]")]
            .filter((element) => !element.closest(".code-paper")).length
        }));
        if (linkerLineFacts.inside !== 5) {
          fail(target.file, `${viewport.width}px expected five LinkerLine runtime SVGs inside code paper`);
        }
        if (linkerLineFacts.outside !== 0) {
          fail(target.file, `${viewport.width}px LinkerLine runtime SVG escaped code paper`);
        }
      }

      if (target.file.includes("perfect-arrows")) {
        const arrowMarkers = await page.locator(
          '[data-connector-layer] [marker-end], [data-connector-layer] marker, [data-connector-layer] polygon'
        ).count();
        if (arrowMarkers !== 0) {
          fail(target.file, `${viewport.width}px Perfect Arrows preview rendered an arrow head`);
        }
      }

      if (target.floatingDetails) {
        const detailBounds = await firstNote.locator(".note-detail").evaluate((element) => {
          const detail = element.getBoundingClientRect();
          const paper = element.closest(".code-paper")?.getBoundingClientRect();
          if (!paper) return { inside: false };
          return {
            inside:
              detail.left >= paper.left - 1
              && detail.top >= paper.top - 1
              && detail.right <= paper.right + 1
              && detail.bottom <= paper.bottom + 1
          };
        });
        if (!detailBounds.inside) {
          fail(target.file, `${viewport.width}px Floating UI detail escaped code paper`);
        }
      }

      if (target.layoutMode === "embedded-adaptive") {
        const teardownFacts = await page.evaluate(() => {
          const preview = window.__CODE_EXPLANATION_PREVIEW__;
          preview?.teardown?.();
          return {
            complete: preview?.audit?.().teardownComplete === true,
            runtimeLines: document.querySelectorAll("[data-linker-line-runtime]").length
          };
        });
        if (!teardownFacts.complete) fail(target.file, `${viewport.width}px teardown did not complete`);
        if (teardownFacts.runtimeLines !== 0) {
          fail(target.file, `${viewport.width}px teardown retained LinkerLine runtime SVGs`);
        }
        if (consoleErrors.length) {
          fail(target.file, `${viewport.width}px console errors after teardown: ${consoleErrors.join(" | ")}`);
        }
      }
    });
  }

  if (!failures.some((message) => message.startsWith(`${target.file}:`))) passedFiles.push(target.file);
}

async function main() {
  await checkLegacyFiles();
  const sources = await expectedSources();
  const browser = await chromium.launch({ headless: true });
  try {
    await checkGallery(browser);
    for (const target of targets) {
      await checkPreview(browser, target, sources);
    }
  } finally {
    await browser.close();
  }

  const result = {
    passedFiles,
    referenceCount: passedFiles.includes("reference-gallery.html") ? 10 : 0,
    targetCount: targets.length,
    failureCount: failures.length,
    failures
  };
  console.log(JSON.stringify(result, null, 2));
  process.exitCode = failures.length ? 1 : 0;
}

await main();
