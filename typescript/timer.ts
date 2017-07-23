const Elm = require('../src/Timer/Main.elm')
const { ipcRenderer } = require('electron')

let flags = ipcRenderer.sendSync('timer-flags')
flags.isDev = process.env.NODE_ENV === 'dev'

document.addEventListener('DOMContentLoaded', function(event) {
  let timer = Elm.Timer.Main.fullscreen(flags)

  document.getElementById('timer-window').addEventListener(
    'mouseenter',
    function(event) {
      ipcRenderer.send('timer-mouse-hover')
    },
    false
  )

  timer.ports.timerDone.subscribe(function(elapsedSeconds: any) {
    ipcRenderer.send('timer-done', elapsedSeconds)
  })

  timer.ports.breakTimerDone.subscribe(function(elapsedSeconds: any) {
    ipcRenderer.send('break-done', elapsedSeconds)
  })
})
