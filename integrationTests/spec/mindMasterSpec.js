const puppeteer = require('puppeteer')
const appServer = require('../fakes/AppServer')

describe("MindMaster", () => {
  let browser
  let page

  beforeAll(async () => {
    browser = await puppeteer.launch({
      headless: true,
      slowMo: 0
    })

    await new Promise((resolve) => {
      appServer.listen(4001, () => {
        console.log('App served on 4001')
        resolve()
      })
    })

    page = await browser.newPage()
    await page.setViewport({
      width: 1024,
      height: 800
    })

    page.on('console', msg => {
      console.log("==>", msg.text())
    });

    await page.goto('http://localhost:4001/index.html')

    await page.evaluate(() => {
      window.localStorage.setItem('scores', JSON.stringify([ 190, 210, 650 ]))
    })

    await page.goto('http://localhost:4001/index.html')
    await page.waitFor(500)
  })

  afterAll(async () => {
    await browser.close()
  })

  it('shows the current high scores', async () => {
    await page.waitForSelector('.high-score')

    const highScores = await getHighScores(page)

    expect(highScores).toContain("190")
    expect(highScores).toContain("210")
    expect(highScores).toContain("650");
  })

  it('evaluates a guess', async () => {
    await page.waitFor('[data-guess-input]')

    await clickColorInput(page, 0)
    await clickColorInput(page, 1)
    await clickColorInput(page, 2)
    await clickColorInput(page, 3)
    await clickColorInput(page, 4)

    await page.click('#submit-guess')
    await page.waitFor('#feedback li')
    const historyItems = await page.$$('#feedback li')
    expect(historyItems.length).toBe(1)
  })

  it('shows the new high score in the list', async () => {
    const highScores = await getHighScores(page)

    expect(highScores.length).toBe(4)
  })

  it('persists the high scores', async () => {
    await page.close()

    const newPage = await browser.newPage()

    await newPage.goto('http://localhost:4001/index.html')

    await newPage.waitForSelector('.high-score')

    const highScores = await getHighScores(newPage)

    expect(highScores.length).toBe(4)
  })
})

const clickColorInput = async (page, index) => {
  const colorInput = await page.$(`[data-guess-input="${index}"]`)
  const boundingBox = await colorInput.boundingBox()

  const x = boundingBox.x + (boundingBox.width / 2)
  const y = boundingBox.y + (boundingBox.height - 20)

  return page.mouse.click(x, y)
}

const getHighScores = (page) => {
  return page.$$('.high-score')
    .then((scores) => {
      const texts = scores.map(s => s.getProperty('innerText'))
      return Promise.all(texts)
    })
    .then((texts) => {
      const vals = texts.map(t => t.jsonValue())
      return Promise.all(vals)
    })
}
