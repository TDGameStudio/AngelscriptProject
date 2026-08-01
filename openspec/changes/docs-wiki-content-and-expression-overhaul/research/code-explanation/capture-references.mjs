import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { createRequire } from "node:module";

const projectRoot = process.cwd();
const requireFromWiki = createRequire(path.join(projectRoot, "Wiki", "package.json"));
const { chromium } = requireFromWiki("@playwright/test");

const outputRoot =
  process.env.CODE_EXPLANATION_CAPTURE_ROOT ??
  path.join(
    process.env.TEMP ?? projectRoot,
    "codex-code-explanation-references-20260730",
  );

const references = [
  {
    id: "unreal-directive",
    title: "Unreal Directive · Enhanced Input",
    url: "https://unrealdirective.com/articles/enhanced-input-what-you-need-to-know/",
    captureUrl:
      "https://unrealdirective.com/images/articles/enhanced-input/02.png",
  },
  {
    id: "explainshell",
    title: "ExplainShell",
    url: "https://explainshell.com/explain?cmd=git%20log%20--graph%20--abbrev-commit%20--pretty%3Doneline%20origin..mybranch",
    captureUrl:
      "https://explainshell.com/explain?cmd=git%20log%20--graph%20--abbrev-commit%20--pretty%3Doneline%20origin..mybranch",
  },
  {
    id: "backbone",
    title: "Backbone.js Annotated Source",
    url: "https://backbonejs.org/docs/backbone.html",
    captureUrl: "https://backbonejs.org/docs/backbone.html",
    anchor: "Backbone.js",
  },
  {
    id: "github",
    title: "GitHub Pull Request Comments",
    url: "https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/commenting-on-a-pull-request",
    captureUrl:
      "https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/commenting-on-a-pull-request",
    selector: 'img[alt*="blue plus icon"]',
  },
  {
    id: "quarto",
    title: "Quarto Code Annotations",
    url: "https://quarto.org/docs/authoring/code-annotation.html",
    captureUrl: "https://quarto.org/docs/authoring/code-annotation.html",
    anchor: "Overview",
  },
  {
    id: "tufte",
    title: "Tufte CSS Sidenotes",
    url: "https://edwardtufte.github.io/tufte-css/#sidenotes",
    captureUrl: "https://edwardtufte.github.io/tufte-css/#sidenotes",
    selector: "#sidenotes",
  },
  {
    id: "material",
    title: "Material for MkDocs Code Annotations",
    url: "https://squidfunk.github.io/mkdocs-material/reference/code-blocks/#code-annotations",
    captureUrl:
      "https://squidfunk.github.io/mkdocs-material/reference/code-blocks/#code-annotations",
    selector: "#adding-annotations",
  },
  {
    id: "code-hike",
    title: "Code Hike Footnotes",
    url: "https://codehike.org/docs/code/footnotes",
    captureUrl: "https://codehike.org/docs/code/footnotes",
    anchor: "Footnotes",
  },
  {
    id: "expressive-code",
    title: "Expressive Code Text Markers",
    url: "https://expressive-code.com/key-features/text-markers/",
    captureUrl: "https://expressive-code.com/key-features/text-markers/",
    anchor: "Text markers",
  },
  {
    id: "twoslash",
    title: "Shiki Twoslash",
    url: "https://shiki.style/packages/twoslash",
    captureUrl: "https://shiki.style/packages/twoslash",
    selector: "#rendererrich",
  },
];

async function centerAnchor(page, reference) {
  if (!reference.anchor && !reference.selector) {
    return;
  }

  const candidate = reference.selector
    ? page.locator(reference.selector).first()
    : page.getByText(reference.anchor, { exact: false }).first();
  await candidate.waitFor({ state: "attached", timeout: 8_000 }).catch(() => {});
  if ((await candidate.count()) === 0) {
    return;
  }

  await candidate.scrollIntoViewIfNeeded().catch(() => {});
  await page.evaluate(() => window.scrollBy(0, -150));
}

async function jpegToWebp(page, jpegBuffer) {
  const jpegData = jpegBuffer.toString("base64");
  return page.evaluate(async (encoded) => {
    const image = new Image();
    image.src = `data:image/jpeg;base64,${encoded}`;
    await image.decode();

    const scale = Math.min(1, 1440 / image.naturalWidth, 960 / image.naturalHeight);
    const canvas = document.createElement("canvas");
    canvas.width = Math.max(1, Math.round(image.naturalWidth * scale));
    canvas.height = Math.max(1, Math.round(image.naturalHeight * scale));
    const context = canvas.getContext("2d", { alpha: false });
    context.fillStyle = "#f5f2e9";
    context.fillRect(0, 0, canvas.width, canvas.height);
    context.drawImage(image, 0, 0, canvas.width, canvas.height);
    return canvas.toDataURL("image/webp", 0.82).split(",")[1];
  }, jpegData);
}

await mkdir(outputRoot, { recursive: true });

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({
  viewport: { width: 1440, height: 960 },
  deviceScaleFactor: 1,
  colorScheme: "light",
  locale: "en-US",
});

try {
  const requestedIds = new Set(
    process.argv
      .filter((argument) => argument.startsWith("--only="))
      .flatMap((argument) => argument.slice("--only=".length).split(",")),
  );
  const selectedReferences =
    requestedIds.size === 0
      ? references
      : references.filter((reference) => requestedIds.has(reference.id));

  for (const reference of selectedReferences) {
    const page = await context.newPage();
    page.setDefaultTimeout(18_000);

    try {
      await page.goto(reference.captureUrl, {
        waitUntil: "domcontentloaded",
        timeout: 45_000,
      });
      await page.waitForTimeout(1_800);
      await centerAnchor(page, reference);
      await page.waitForTimeout(450);

      const jpeg = await page.screenshot({
        type: "jpeg",
        quality: 88,
        fullPage: false,
      });
      const encodedWebp = await jpegToWebp(page, jpeg);
      const outputPath = path.join(outputRoot, `${reference.id}.webp`);
      await writeFile(outputPath, Buffer.from(encodedWebp, "base64"));
      console.log(`captured ${reference.id} -> ${outputPath}`);
    } catch (error) {
      console.error(`capture failed ${reference.id}: ${error.message}`);
      process.exitCode = 1;
    } finally {
      await page.close();
    }
  }
} finally {
  await context.close();
  await browser.close();
}

console.log(`capture root: ${outputRoot}`);
process.exit(process.exitCode ?? 0);
