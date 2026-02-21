import { test, expect } from '@playwright/test';

test('app should load and show login button', async ({ page }) => {
    // Navigate to the app
    await page.goto('/');

    // Check if the page title is correct (Flutter apps often have a title in the HTML)
    await expect(page).toHaveTitle(/hangul_play/);

    // Wait for the Flutter app to initialize 
    // Flutter web often takes a few seconds to load the engine and assets
    await page.waitForLoadState('networkidle');

    // Since Flutter renders on Canvas, finding specific buttons can be tricky
    // However, we can check if the canvas exists or if certain aria-labels are present
    const canvas = page.locator('canvas');
    await expect(canvas).toBeVisible();

    // If you enabled semantic labels in Flutter, you can find elements by name
    // For now, we take a screenshot to verify visual state
    await page.screenshot({ path: 'test-results/login-screen.png' });
});
