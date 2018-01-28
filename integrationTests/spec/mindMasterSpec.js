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
    await page.type("#guess-input", 'rrrrr')
    await page.click('#guess-submit')
    await page.waitFor('[data-guess-feedback]')
    const feedbackText = await textFor(page, '[data-guess-feedback]')
    expect(feedbackText).not.toEqual('')
  })
})

const textFor = (page, selector) => {
  return page.$(selector)
    .then(el => el.getProperty('innerText'))
    .then(js => js.jsonValue())
}
