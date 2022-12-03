import { test, expect } from '@playwright/test';

test('Capture screenshot of the entire scrollable webpage', async ({page}) => {
    await page.goto('/')
    await expect(page.locator('#red-ui-workspace-tabs')).toBeVisible({timeout: 2000})
    await page.click('#red-ui-header-button-sidemenu')
    await page.click('#menu-item-view-menu')
    await page.click('#menu-item-palette')
    await page.click('#menu-item-sidebar')
    await expect(page.locator('#red-ui-palette')).toBeHidden({timeout: 1000})
    await page.screenshot({path: 'screenshots/fullPage.png', fullPage: true})
  })
