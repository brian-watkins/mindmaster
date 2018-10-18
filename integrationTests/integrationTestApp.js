import '../src/style/style.scss'
import MindMasterApp from "./IntegrationTestMain"
import { attachRequestScoresPort } from "../src/ports/requestScoresPort"

const mountNode = document.getElementById("mindmaster-app")

const app = MindMasterApp.Elm.IntegrationTestMain.init({
  node: mountNode, 
  flags: {
    topScores: 5,
    maxGuesses: 2,
    codeLength: 5
  }
})

attachRequestScoresPort(app)
