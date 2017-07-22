// import * as $ from 'jquery'
const Elm = require('../src/Setup/Main.elm')
// const { ipcRenderer, clipboard } = require('electron')
import { ipcRenderer, clipboard } from 'electron'
const { version } = require('../package.json')
console.log(`Running version ${version}`)
let settings = JSON.parse(window.localStorage.getItem('settings'))
let onMac = /Mac/.test(navigator.platform)
let isDev = require('electron-is-dev')
console.log('Its running!!!!!!!!!!!!!!!!!!!!!!!!!')

document.addEventListener('DOMContentLoaded', function(event) {
  const div = document.getElementById('main')
  // let setup = Elm.Increment.embed(div)

  let setup = Elm.Setup.Main.fullscreen({ settings, onMac, isDev })
  setup.ports.selectDuration.subscribe(function(id: string) {
    let inputElement: any = document.getElementById(id)
    inputElement.select()
  })
  setup.ports.sendIpc.subscribe(function([message, data]: any) {
    console.log('sendIpc', message, data)
    ipcRenderer.send(message, data)
  })
  setup.ports.saveSettings.subscribe(function(settings: any) {
    window.localStorage.setItem('settings', JSON.stringify(settings))
  })
  ipcRenderer.on('update-downloaded', function(
    event: any,
    updatedVersion: any
  ) {
    console.log('on update-downloaded. updatedVersion = ', updatedVersion)
    setup.ports.updateDownloaded.send('Not a real version...')
  })
  ipcRenderer.on('timer-done', function(event: any, elapsedSeconds: any) {
    setup.ports.timeElapsed.send(elapsedSeconds)
  })
  ipcRenderer.on('break-done', function(event: any, elapsedSeconds: any) {
    setup.ports.breakDone.send(elapsedSeconds)
  })
  $(() => {
    $('.invisible-trigger').hover(
      () => {
        $('body').addClass('transparent')
      },
      () => {
        $('body').removeClass('transparent')
      }
    )
  })
})
