import { writeFile } from 'node:fs/promises';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const handoffDirectory = path.dirname(fileURLToPath(import.meta.url));
const requireFromWiki = createRequire(path.resolve(process.cwd(), 'Wiki', 'package.json'));
const { chromium } = requireFromWiki('@playwright/test');

const browser = await chromium.launch();
const context = await browser.newContext({ viewport: { width: 1440, height: 960 } });
const page = await context.newPage();

try {
  await page.goto('http://127.0.0.1:8080/#AS/Workflow/GettingStarted');
  await page.locator('.tc-sidebar-tabs-main > .tc-tab-buttons > button').nth(3).click();
  await page.locator('.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button').first().waitFor();

  const borders = await page.evaluate(() =>
    Array.from(document.querySelectorAll('.tc-more-sidebar, .tc-more-sidebar *'))
      .map(element => {
        const style = getComputedStyle(element);
        const rect = element.getBoundingClientRect();
        return {
          borderBottom: `${style.borderBottomWidth} ${style.borderBottomStyle} ${style.borderBottomColor}`,
          borderLeft: `${style.borderLeftWidth} ${style.borderLeftStyle} ${style.borderLeftColor}`,
          borderRight: `${style.borderRightWidth} ${style.borderRightStyle} ${style.borderRightColor}`,
          borderTop: `${style.borderTopWidth} ${style.borderTopStyle} ${style.borderTopColor}`,
          className: element.className,
          height: rect.height,
          tagName: element.tagName,
          width: rect.width,
          x: rect.x,
          y: rect.y,
        };
      })
      .filter(entry =>
        entry.height >= 40 &&
        (entry.borderLeft.startsWith('1px') ||
          entry.borderRight.startsWith('1px') ||
          entry.borderTop.startsWith('1px') ||
          entry.borderBottom.startsWith('1px')),
      ),
  );

  await writeFile(
    path.resolve(handoffDirectory, 'more-sidebar-border-diagnostics.json'),
    `${JSON.stringify(borders, null, 2)}\n`,
    'utf8',
  );
} finally {
  await context.close();
  await browser.close();
}
