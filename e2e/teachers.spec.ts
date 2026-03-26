import { test, expect, type Page } from '@playwright/test'

async function gotoTeachersPage(page: Page, search = ''): Promise<void> {
  const url = search ? `/teachers?${search}` : '/teachers'
  await page.goto(url)
  await page.getByRole('complementary', { name: 'Filter teachers' }).waitFor({ state: 'visible' })
}

test.describe('Teachers directory page', () => {
  test.beforeEach(async ({ page }) => {
    await gotoTeachersPage(page)
  })

  test('has title and main heading', async ({ page }) => {
    await expect(page).toHaveTitle(/Find Your Mentor/)
    const heading = page.getByTestId('teachers-page-title')
    await expect(heading).toBeVisible()
    await expect(heading).toContainText('Find Your Mentor')
  })

  test('main navigation includes Teachers link to directory', async ({ page }) => {
    const header = page.getByTestId('header')
    const navTeachers = header.getByRole('link', { name: 'Teachers' })
    await expect(navTeachers).toBeVisible()
    await expect(navTeachers).toHaveAttribute('href', '/teachers')
  })

  test('shows featured teacher and full grid', async ({ page }) => {
    const featured = page.getByTestId('teachers-featured')
    await expect(featured).toBeVisible()
    await expect(featured.getByTestId('teachers-featured-name')).toContainText('Dr. Wei Zhang')

    const gridCards = page.locator('[data-testid^="teachers-grid-card-"]')
    await expect(gridCards).toHaveCount(23)
  })

  test('search filters mentor cards by name', async ({ page }) => {
    await gotoTeachersPage(page, 'q=Rodriguez')
    const search = page.getByTestId('teachers-search').locator('input')
    await expect(search).toHaveValue('Rodriguez')
    const gridCards = page.locator('[data-testid^="teachers-grid-card-"]')
    await expect(gridCards).toHaveCount(1)
    await expect(page.getByText('James Rodriguez', { exact: false }).first()).toBeVisible()
  })

  test('subject filter limits grid to matching mentors', async ({ page }) => {
    await gotoTeachersPage(page, 'subject=Calculus')
    const gridCards = page.locator('[data-testid^="teachers-grid-card-"]')
    await expect(gridCards).toHaveCount(1)
    await expect(page.getByText('Dr. Sarah Chen', { exact: false }).first()).toBeVisible()
  })

  test('navigating to /teachers without subject query restores full mentor grid', async ({ page }) => {
    await gotoTeachersPage(page, 'subject=Calculus')
    await expect(page.locator('[data-testid^="teachers-grid-card-"]')).toHaveCount(1)
    await gotoTeachersPage(page)
    await expect(page.locator('[data-testid^="teachers-grid-card-"]')).toHaveCount(23)
  })

  test('All subjects button clears subject filter and updates the grid', async ({ page }) => {
    await gotoTeachersPage(page, 'subject=Calculus')
    await expect(page.locator('[data-testid^="teachers-grid-card-"]')).toHaveCount(1)
    const filters = page.getByRole('complementary', { name: 'Filter teachers' })
    const allSubjects = filters.getByRole('button', { name: 'All subjects' })
    await allSubjects.scrollIntoViewIfNeeded()
    await allSubjects.click()
    await expect(page.locator('[data-testid^="teachers-grid-card-"]')).toHaveCount(23)
  })
})
