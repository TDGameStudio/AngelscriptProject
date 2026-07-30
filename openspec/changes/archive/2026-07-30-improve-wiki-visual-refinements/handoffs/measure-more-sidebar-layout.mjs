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

  const layout = await page.evaluate(() => {
    const measure = (selector) => {
      const element = document.querySelector(selector);
      if (!element) throw new Error(`Missing ${selector}`);
      const rect = element.getBoundingClientRect();
      const style = getComputedStyle(element);
      return {
        borderLeft: style.borderLeft,
        borderRight: style.borderRight,
        marginLeft: style.marginLeft,
        paddingLeft: style.paddingLeft,
        x: rect.x,
        width: rect.width,
      };
    };
    return {
      categoryButtons: measure('.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons'),
      firstCategoryButton: measure('.tc-more-sidebar > .tc-tab-set > .tc-tab-buttons > button'),
      firstCategoryContent: measure('.tc-more-sidebar > .tc-tab-set > .tc-tab-content a, .tc-more-sidebar > .tc-tab-set > .tc-tab-content button'),
      panel: measure('.tc-more-sidebar > .tc-tab-set > .tc-tab-content.tc-vertical.tc-sidebar-tabs-more'),
    };
  });

  await writeFile(
    path.resolve(handoffDirectory, 'more-sidebar-layout-measurements.json'),
    `${JSON.stringify(layout, null, 2)}\n`,
    'utf8',
  );
} finally {
  await context.close();
  await browser.close();
}
