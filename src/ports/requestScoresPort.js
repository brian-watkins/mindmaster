export const attachRequestScoresPort = (app) => {
  app.ports.requestScores.subscribe(function (score) {
    let scores = JSON.parse(window.localStorage.getItem("scores")) || []

    if (score) {
      scores.push(score)
      window.localStorage.setItem("scores", JSON.stringify(scores))
    }

    app.ports.scores.send(scores)
  })
}
