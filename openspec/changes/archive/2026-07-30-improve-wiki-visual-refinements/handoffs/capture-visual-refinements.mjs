import { mkdir, writeFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const handoffDirectory = path.dirname(fileURLToPath(import.meta.url));
const outputDirectory = path.resolve(handoffDirectory, '..', 'comparison-artifacts');
const requireFromWiki = createRequire(path.resolve(process.cwd(), 'Wiki', 'package.json'));
const { chromium } = requireFromWiki('@playwright/test');
await mkdir(outputDirectory, { recursive: true });

const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1440, height: 960 } });
const page = await context.newPage();
const baseURL = 'http://127.0.0.1:8080';

try {
  await page.goto(`${baseURL}/#AngelscriptWikiHome`);
  await page.locator('.tc-tiddler-frame', { has: page.locator('.as-sdk-description') }).waitFor();
  await page.screenshot({ path: path.join(outputDirectory, 'sdk-header.png') });

  await page.goto(`${baseURL}/#AS/Workflow/GettingStarted`);
  await page.locator('.tc-sidebar-tabs-main > .tc-tab-buttons > button').nth(3).click();
  await page.locator('.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button').first().waitFor();
  await page.screenshot({ path: path.join(outputDirectory, 'more-sidebar.png') });

  await page.goto(`${baseURL}/#AS/Workflow/GettingStarted`);
  await page.setViewportSize({ width: 2048, height: 1018 });
  const resizer = page.locator('#gk0wk-sidebar-resize-area');
  await resizer.waitFor();
  const idle = await resizer.evaluate(element => {
    const rail = getComputedStyle(element, '::before');
    return { opacity: rail.opacity, width: rail.width };
  });
  await page.screenshot({ path: path.join(outputDirectory, 'resize-idle.png') });

  await resizer.hover();
  await page.waitForTimeout(180);
  const hovered = await resizer.evaluate(element => {
    const rail = getComputedStyle(element, '::before');
    return { opacity: rail.opacity, width: rail.width };
  });
  await page.screenshot({ path: path.join(outputDirectory, 'resize-hover.png') });

  const box = await resizer.boundingBox();
  if (!box) throw new Error('The sidebar resize hit target has no bounding box');
  await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
  await page.mouse.down();
  await page.waitForTimeout(180);
  const active = await resizer.evaluate(element => {
    const rail = getComputedStyle(element, '::before');
    return { opacity: rail.opacity, width: rail.width };
  });
  await page.screenshot({ path: path.join(outputDirectory, 'resize-active.png') });
  await page.mouse.up();

  await writeFile(
    path.join(outputDirectory, 'visual-metrics.json'),
    `${JSON.stringify({ active, hovered, idle }, null, 2)}\n`,
    'utf8',
  );
} finally {
  await context.close();
  await browser.close();
}
