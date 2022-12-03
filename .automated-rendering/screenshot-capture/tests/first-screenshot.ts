import { test, expect } from '@playwright/test';

test('Capture screenshot of the entire scrollable webpage', async ({page}) => {
    await page.goto('http://node-red-local/')
    await page.screenshot({path: 'screenshots/fullPage.png', fullPage: true})
  })
