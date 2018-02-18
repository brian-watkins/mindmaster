import '../src/style/style.scss'
import MindMasterApp from "./IntegrationTestMain"
import { requestScoresPort } from "../src/ports/requestScoresPort"

const mountNode = document.getElementById("mindmaster-app")

const app = MindMasterApp.IntegrationTestMain.embed(mountNode)
requestScoresPort(app)
