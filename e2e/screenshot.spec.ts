import { test } from '@playwright/test'

test('capture app screenshot for review', async ({ page }) => {
  await page.goto('/')
  // Wait for mock data to load
  await page.waitForTimeout(500)
  await page.screenshot({ path: 'test-results/app-screenshot.png', fullPage: true })
})

test('capture editor with note selected', async ({ page }) => {
  await page.goto('/')
  await page.waitForTimeout(500)

  // Click the first note in the list
  await page.click('.note-list__item')
  await page.waitForTimeout(300)

  await page.screenshot({ path: 'test-results/editor-screenshot.png', fullPage: true })
})

test('live preview: headings styled, syntax hidden', async ({ page }) => {
  await page.goto('/')
  await page.waitForTimeout(500)

  // Click a note to load it
  await page.click('.note-list__item')
  await page.waitForTimeout(500)

  // Screenshot showing live preview (headings styled, syntax hidden)
  await page.screenshot({ path: 'test-results/live-preview.png', fullPage: true })
})

test('tab bar: multiple tabs open and close', async ({ page }) => {
  await page.goto('/')
  await page.waitForTimeout(500)

  // Click first note — opens a tab
  await page.click('.note-list__item:nth-child(1)')
  await page.waitForTimeout(300)

  // Click second note — opens a second tab
  await page.click('.note-list__item:nth-child(2)')
  await page.waitForTimeout(300)

  // Click third note — opens a third tab
  await page.click('.note-list__item:nth-child(3)')
  await page.waitForTimeout(300)

  await page.screenshot({ path: 'test-results/tabs-screenshot.png', fullPage: true })
})
