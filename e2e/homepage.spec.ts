import { test, expect } from '@playwright/test'

test.describe('Homepage', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
  })

  test('has correct title', async ({ page }) => {
    await expect(page).toHaveTitle(/Connect with Expert Teachers/)
  })

  test('header is visible', async ({ page }) => {
    const header = page.getByTestId('header')
    await expect(header).toBeVisible()
  })

  test('color mode button is visible', async ({ page }) => {
    const colorModeBtn = page.getByTestId('color-mode-button')
    await expect(colorModeBtn).toBeVisible()
  })

  test('hero section displays main content', async ({ page }) => {
    const hero = page.getByTestId('hero')
    await expect(hero).toBeVisible()

    const heading = page.getByTestId('hero-heading')
    await expect(heading).toBeVisible()
    await expect(heading).toContainText('Learn from Expert Teachers')

    const description = page.getByTestId('hero-description')
    await expect(description).toBeVisible()
  })

  test('hero CTA buttons are visible', async ({ page }) => {
    const ctaButtons = page.getByTestId('hero-cta-buttons')
    await expect(ctaButtons).toBeVisible()

    const findTeacher = page.getByTestId('hero-cta-find-a-teacher')
    await expect(findTeacher).toBeVisible()

    const becomeTeacher = page.getByTestId('hero-cta-become-a-teacher')
    await expect(becomeTeacher).toBeVisible()
  })

  test('hero search bar is visible', async ({ page }) => {
    const searchBar = page.getByTestId('hero-search-bar')
    await expect(searchBar).toBeVisible()

    const searchBtn = page.getByTestId('hero-search-button')
    await expect(searchBtn).toBeVisible()
  })

  test('hero play video button is visible', async ({ page }) => {
    const playVideo = page.getByTestId('hero-play-video')
    await expect(playVideo).toBeVisible()
  })

  test('hero social proof is visible', async ({ page }) => {
    const socialProof = page.getByTestId('hero-social-proof')
    await expect(socialProof).toBeVisible()
    await expect(socialProof).toContainText('Trusted By')
    await expect(socialProof).toContainText('10k+ Students')
  })

  test('how it works section is visible', async ({ page }) => {
    const section = page.getByTestId('how-it-works')
    await expect(section).toBeVisible()

    const title = page.getByTestId('how-it-works-title')
    await expect(title).toBeVisible()
    await expect(title).toContainText('How It Works')

    const cta = page.getByTestId('how-it-works-cta')
    await expect(cta).toBeVisible()
    await expect(cta).toContainText('Start Learning Today')
  })

  test('teachers section is visible with mentor cards', async ({ page }) => {
    const section = page.getByTestId('teachers')
    await expect(section).toBeVisible()

    const title = page.getByTestId('teachers-title')
    await expect(title).toBeVisible()
    await expect(title).toContainText('Meet Our Teachers')

    const teacherCards = page.getByTestId(/teacher-card-\d/)
    await expect(teacherCards).toHaveCount(4)
  })

  test('testimonials section has navigation', async ({ page }) => {
    const section = page.getByTestId('testimonials')
    await expect(section).toBeVisible()

    const prevBtn = page.getByTestId('testimonials-prev')
    const nextBtn = page.getByTestId('testimonials-next')
    await expect(prevBtn).toBeVisible()
    await expect(nextBtn).toBeVisible()
  })

  test('testimonials carousel advances on next click', async ({ page }) => {
    const nextBtn = page.getByTestId('testimonials-next')
    await nextBtn.click()
    await expect(nextBtn).toBeVisible()
  })

  test('FAQ section is visible', async ({ page }) => {
    const section = page.getByTestId('faq')
    await expect(section).toBeVisible()

    const title = page.getByTestId('faq-title')
    await expect(title).toBeVisible()
    await expect(title).toContainText('Frequently Asked Questions')
  })

  test('CTA section is visible', async ({ page }) => {
    const section = page.getByTestId('cta')
    await expect(section).toBeVisible()

    const title = page.getByTestId('cta-title')
    await expect(title).toBeVisible()
    await expect(title).toContainText('Ready to Start Learning')

    const findTeacher = page.getByTestId('cta-find-a-teacher')
    const becomeTeacher = page.getByTestId('cta-become-a-teacher')
    await expect(findTeacher).toBeVisible()
    await expect(becomeTeacher).toBeVisible()
  })

  test('footer is visible', async ({ page }) => {
    const footer = page.getByTestId('footer')
    await expect(footer).toBeVisible()

    const credits = page.getByTestId('footer-credits')
    await expect(credits).toBeVisible()
    await expect(credits).toContainText('Nuxt')
  })
})
