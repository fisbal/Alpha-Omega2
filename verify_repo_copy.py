import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.launch(executable_path='/opt/pw-browsers/chromium')
        page = await browser.new_page()
        errors = []
        page.on('pageerror', lambda exc: errors.append(str(exc)))
        await page.goto('file:///home/claude/alpha-omega-repo/app/index.html')
        await page.wait_for_timeout(500)
        check = await page.evaluate("""() => {
            document.querySelector('.tab[data-tab="evidence"]').click();
            return {
                evidenceSections: JESUS_EVIDENCE.length,
                hasManifestLink: !!document.querySelector('link[rel="manifest"]'),
                title: document.title,
            };
        }""")
        print("Check:", check)
        print("PAGE ERRORS:", errors)
        await browser.close()

asyncio.run(main())
