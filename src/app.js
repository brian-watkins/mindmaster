import './style/style.scss'
import MindMasterApp from "./elm/Main"
import { requestScoresPort } from "./ports/requestScoresPort"

const mountNode = document.getElementById("mindmaster-app")

const app = MindMasterApp.Main.embed(mountNode)
requestScoresPort(app)
