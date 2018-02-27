import './style/style.scss'
import MindMasterApp from "./elm/Main"
import { attachRequestScoresPort } from "./ports/requestScoresPort"

const mountNode = document.getElementById("mindmaster-app")

const app = MindMasterApp.Main.embed(mountNode, {
  topScores: 5,
  maxGuesses: 10,
  codeLength: 5
})

attachRequestScoresPort(app)
