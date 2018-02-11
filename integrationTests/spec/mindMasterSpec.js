const puppeteer = require('puppeteer')
const appServer = require('../fakes/AppServer')

describe("MindMaster", () => {
  let browser
  let page

  beforeAll(async () => {
    browser = await puppeteer.launch()

    await new Promise((resolve) => {
      appServer.listen(4001, () => {
        console.log('App served on 4001')
        resolve()
      })
    })
  })

  afterAll(async () => {
    await browser.close()
  })

  beforeEach(async () => {
    page = await browser.newPage()
    await page.goto('http://localhost:4001/index.html')
  })

  it('evaluates a guess', async () => {
    for (var i = 0; i < 700; i = i + 5) {
      await page.mouse.click(i, 50)
    }

    await page.click('#submit-guess')
    await page.waitFor('[data-guess-feedback]')
    const feedback = await page.$('[data-guess-feedback]')
    expect(feedback).not.toBe(null)
  })
})

const textFor = (page, selector) => {
  return page.$(selector)
    .then(el => el.getProperty('innerText'))
    .then(js => js.jsonValue())
}
