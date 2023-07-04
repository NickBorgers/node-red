import { test, expect } from '@playwright/test';

test('Capture screenshot of the entire scrollable webpage', async ({page}) => {
    // Go to root page
    await page.goto('/')
    // Wait for load
    await expect(page.locator('#red-ui-header-button-sidemenu')).toBeVisible({timeout: 10000})
    // Bump up resolution to huuuuge
    await page.setViewportSize({ width: 5000, height: 4000 });
    // Close sidebars if open
        const pallette = await page.$("#red-ui-palette-container")
        if (await pallette.isVisible()) {
        // Close pallette
            // Open top-right corner hamburger menu
            await page.click('#red-ui-header-button-sidemenu')
            // Wait for the menu to appear
            await expect(page.locator('#red-ui-header-button-sidemenu-submenu')).toBeVisible({timeout: 500})
            // Open "view" submenu
            await page.hover('#menu-item-view-menu')
            // Wait for submenu to appear
            await expect(page.locator('#menu-item-view-menu-submenu')).toBeVisible({timeout: 500})
            // Uncheck pallette
            await page.click('#menu-item-palette')
            // Wait for closure
            await expect(page.locator('#red-ui-palette-container')).toBeHidden({timeout: 2000})
        }
        const sidebar = await page.$("#red-ui-sidebar")
        if (await sidebar.isVisible()) {
        // Close sidebars
            // Open top-right corner hamburger menu
            await page.click('#red-ui-header-button-sidemenu')
            // Wait for the menu to appear
            await expect(page.locator('#red-ui-header-button-sidemenu-submenu')).toBeVisible({timeout: 500})
            // Open "view" submenu
            await page.hover('#menu-item-view-menu')
            // Wait for submenu to appear
            await expect(page.locator('#menu-item-view-menu-submenu')).toBeVisible({timeout: 500})
            // Uncheck pallette
            await page.click('#menu-item-sidebar')
            // Wait for closure
            await expect(page.locator('#red-ui-sidebar')).toBeHidden({timeout: 2000})
        }
    // Disable grid
        // Open top-right corner hamburger menu
        await page.click('#red-ui-header-button-sidemenu')
        // Wait for the menu to appear
        await expect(page.locator('#red-ui-header-button-sidemenu-submenu')).toBeVisible({timeout: 500})
        // Go into settings menu
        await page.click('#menu-item-user-settings')
        // Wait for the menu to appear
        await expect(page.locator('#user-settings-view-show-grid')).toBeVisible({timeout: 500})
        // Uncheck show-grid option
        await page.uncheck('#user-settings-view-show-grid')
        // Save changes
        await page.click('#node-dialog-ok')
            
    // Get tabs
    // Collect tabs ids in this hacky way to return the list
    var tab_ids = await page.evaluate('var children_ids = []; document.getElementById("red-ui-workspace-tabs").childNodes.forEach(function(this_node) {children_ids.push(this_node.id)}); children_ids ');
    // Collect the flow names in this hacky way to return the list
    var flow_names = await page.evaluate('var flow_names = []; document.getElementById("red-ui-workspace-tabs").childNodes.forEach(function(this_node) {flow_names.push(this_node.getAttribute("flowname"))}); flow_names ');
    
    // Create index variable
    var index = 0;
    // Do some ugly looping
    for (var index = 0; index < tab_ids.length; index++) {
        // Set the tab id with the index
        var this_tab_id = tab_ids[index]
        // Set the flow name with the index
        var this_flow_name = flow_names[index]
        // Log that we're working this tab ID and flow name
        console.log(`Working tab ${this_tab_id}, ${this_flow_name}`)
        // Select the tab by clicking its tab element by id
        await page.click(`#${this_tab_id}`)
        // Wait for the chart to show up
        await expect(page.locator('#red-ui-workspace-chart')).toBeVisible({timeout: 1000})
        // There's this little thingy that I want to fade away before we screenshot, but don't want to go find the id for
        await page.waitForTimeout(500)
        // Take that sweet screenshot
        await page.locator("#red-ui-workspace-chart").screenshot({path: `screenshots/${this_flow_name}.png`})
    }

    // Yay we did it!
  })
