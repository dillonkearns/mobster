import {
  ipcMain,
  globalShortcut,
  app,
  Tray,
  BrowserWindow,
  dialog,
  shell,
  remote,
  screen
} from 'electron'
import * as fs from 'fs'
import { Ipc, ElmIpc } from './typescript/ipc'
import { DisplayManager } from './typescript/display-manager'

const transparencyDisabled = fs.existsSync(
  `${app.getPath('userData')}/NO_TRANSPARENCY`
)
const autoUpdater = require('electron-updater').autoUpdater
autoUpdater.requestHeaders = { 'Cache-Control': 'no-cache' }
require('electron-debug')({
  enabled: true // enable debug shortcuts in prod build
})
import * as ua from 'universal-analytics'
import { Analytics } from './typescript/analytics'
let analytics = new Analytics()

import * as path from 'path'
import * as url from 'url'
const log = require('electron-log')
const assetsDirectory = path.join(__dirname, 'assets')
const packageJson = require('./package.json')
const version: string = packageJson.version
const appDataPath = app.getPath('userData')
let currentMobstersFilePath: string = path.join(appDataPath, 'active-mobsters')
import * as bugsnag from 'bugsnag'
const isLocal = require('electron-is-dev')

log.info(`Running version ${version}`)

let checkForUpdates = true

let releaseStage = isLocal ? 'development' : 'production'
bugsnag.register('032040bba551785c7846442332cc067f', {
  autoNotify: true,
  appVersion: version,
  releaseStage: releaseStage
})

const shouldQuit = app.requestSingleInstanceLock()
app.on('second-instance', (event, commandLine, workingDirectory) => {
  // Someone tried to run a second instance, we should focus our window.
  if (displayManager) {
    displayManager.showMain()
  }
})
if (!shouldQuit) {
  app.exit()
}

function writeToFile(filePath: string, fileContents: string) {
  fs.writeFile(filePath, fileContents, function(err) {
    if (err) {
      console.log(err)
    }
  })
}

function updateMobsterNamesFile(currentMobsterNames: string) {
  writeToFile(currentMobstersFilePath, currentMobsterNames)
}

function showFeedbackForm() {
  new BrowserWindow({ show: true, frame: true, alwaysOnTop: true }).loadURL(
    'https://dillonkearns.typeform.com/to/k9P6iV'
  )
}

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let timerWindow: Electron.BrowserWindow | null,
  tray: Electron.Tray,
  displayManager: DisplayManager

const timerHeight = 130
const timerWidth = 150

const onMac = /^darwin/.test(process.platform)
const onWindows = /^win/.test(process.platform)

function positionWindowLeft(window: Electron.BrowserWindow) {
  let { width, height } = screen.getPrimaryDisplay().workAreaSize
  window.setPosition(0, height - timerHeight)
}

function positionWindowRight(window: Electron.BrowserWindow) {
  const { width, height } = screen.getPrimaryDisplay().workAreaSize
  window.setPosition(width - timerWidth, height - timerHeight)
}

function startTimer(flags: any) {
  timerWindow = newTransparentOnTopWindow({
    width: timerWidth,
    height: timerHeight,
    focusable: false,
    show: false
  })
  timerWindow.setAlwaysOnTop(true, 'floating', 1)
  timerWindow.setVisibleOnAllWorkspaces(true)
  timerWindow.once('ready-to-show', () => {
    timerWindow && timerWindow.show()
  })

  timerWindow.webContents.on('crashed', function() {
    bugsnag.notify('crashed', { details: 'timerWindow crashed' })
  })
  timerWindow.on('unresponsive', function() {
    bugsnag.notify('unresponsive', { details: 'timerWindow unresponsive' })
  })

  positionWindowRight(timerWindow)

  ipcMain.once('timer-flags', (event: any) => {
    event.returnValue = flags
  })

  let timerFile = transparencyDisabled ? 'opaque-timer' : 'transparent-timer'

  let timerPathName = path.join('pages', timerFile)

  let nodeDevEnv = process.env.NODE_ENV === 'dev'
  let timerProdUrl = url.format({
    pathname: path.join(__dirname, '/pages', `${timerFile}.prod.html`),
    protocol: 'file:'
  })
  let timerDevUrl = url.format({
    hostname: 'localhost',
    pathname: path.join('pages', `${timerFile}.dev.html`),
    port: '8080',
    protocol: 'http',
    slashes: true
  })
  console.log('timer file name:', nodeDevEnv ? timerDevUrl : timerProdUrl)
  timerWindow.loadURL(nodeDevEnv ? timerDevUrl : timerProdUrl)
}

ipcMain.on('timer-mouse-hover', (event: any) => {
  if (timerWindow) {
    let [x, y] = timerWindow.getPosition()
    if (x === 0) {
      positionWindowRight(timerWindow)
    } else {
      positionWindowLeft(timerWindow)
    }
  }
})

ipcMain.on('get-active-mobsters-path', (event: any) => {
  event.returnValue = currentMobstersFilePath
})

function closeTimer() {
  if (timerWindow) {
    timerWindow.close()
    timerWindow = null
  }
}

function onClickTrayIcon() {
  showStopTimerDialog()
}

const createTray = () => {
  tray = new Tray(path.join(assetsDirectory, 'tray-icon.png'))
  tray.on('right-click', onClickTrayIcon)
  tray.on('double-click', onClickTrayIcon)
  tray.on('click', onClickTrayIcon)
}

function newTransparentOnTopWindow(
  additionalOptions: Electron.BrowserWindowConstructorOptions
) {
  const transparentWindowDefaultOptions: Electron.BrowserWindowConstructorOptions = {
    transparent: !transparencyDisabled,
    frame: false,
    alwaysOnTop: true
  }
  return new BrowserWindow({
    ...transparentWindowDefaultOptions,
    ...additionalOptions
  })
}

function onReady() {
  // On Arch Linux with OpenBox, `app.dock` is `undefined`
  if (app.dock) {
    app.dock.hide() // needed to support fullscreen mode in OS X, see https://github.com/electron/electron/issues/3302
  }
  displayManager = new DisplayManager(
    transparencyDisabled,
    bugsnag,
    closeTimer,
    (ipc: ElmIpc) => {
      if (ipc.message === 'ShowFeedbackForm') {
        showFeedbackForm()
      } else if (ipc.message === 'ShowScriptInstallInstructions') {
        displayManager.showScripts()
      } else if (ipc.message === 'Hide') {
        displayManager.toggleMain()
      } else if (ipc.message === 'Quit') {
        app.quit()
      } else if (ipc.message === 'QuitAndInstall') {
        autoUpdater.quitAndInstall()
      } else if (ipc.message === 'ChangeShortcut') {
        globalShortcut.unregisterAll()
        if (ipc.data !== '') {
          setShowHideShortcut(ipc.data)
        }
      } else if (ipc.message === 'OpenExternalUrl') {
        displayManager.hideMain()
        shell.openExternal(ipc.data)
      } else if (ipc.message === 'StartTimer') {
        startTimer(ipc.data)
        analytics.trackEvent({
          category: 'timer',
          action: ipc.data.isBreak ? 'start-break' : 'start-timer',
          label: '',
          value: ipc.data.minutes
        })
        displayManager.hideMain()
      } else if (ipc.message === 'SaveActiveMobstersFile') {
        updateMobsterNamesFile(ipc.data)
      } else if (ipc.message === 'NotifySettingsDecodeFailed') {
        bugsnag.notify('settings-decode-failure', { decodeError: ipc.data })
      } else if (ipc.message === 'TrackEvent') {
        analytics.trackEventParams(ipc.data)
      } else if (ipc.message === 'TrackPage') {
        analytics.trackPage(ipc.data)
      } else {
        const exhaustiveCheck: never = ipc
      }
    }
  )
  createTray()
  setupAutoUpdater()
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', onReady)
app.on('before-quit', () => analytics.endSession())

app.on('activate', function() {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (displayManager) {
    displayManager.showMain()
  }
})

function setupAutoUpdater() {
  autoUpdater.logger = log
  autoUpdater.on('checking-for-update', () => {
    log.info('checking-for-update')
  })

  autoUpdater.on('error', (ev: any, err: any) => {
    bugsnag.notify('autoUpdate error', { details: err })
    checkForUpdates = true
  })

  autoUpdater.on('update-available', () => {
    log.info('update-available')
    checkForUpdates = false
  })

  autoUpdater.on('update-downloaded', (versionInfo: any) => {
    log.info('update-downloaded: ', versionInfo)
    displayManager
      .getMainWindow()
      .webContents.send('update-downloaded', versionInfo)
  })

  autoUpdater.on('update-not-available', () => {
    log.info('update-not-available')
  })

  if (!isLocal) {
    autoUpdater.checkForUpdates()
    log.info('About to set up interval')
    let myCheckForUpdates = () => {
      log.info('About to check for updates on interval')

      if (checkForUpdates) {
        autoUpdater.checkForUpdates()
      }
    }
    setInterval(myCheckForUpdates, 120 * 1000)
  }
}

function setShowHideShortcut(shortcutString: string) {
  globalShortcut.register(shortcutString, () => {
    analytics.trackEventParams({
      ec: 'shortcut',
      ea: 'show-hide',
      el: shortcutString,
      ev: undefined
    })
    showStopTimerDialog()
  })
}

let dialogDisplayed = false

function showStopTimerDialog() {
  if (dialogDisplayed) {
    return
  }
  dialogDisplayed = true
  if (timerWindow) {
    app.focus() // ensure that app is focused so dialog appears in foreground
    let dialogActionIndex = dialog.showMessageBox({
      type: 'warning',
      buttons: ['Stop timer', 'Keep it running'],
      message: 'Stop the timer?',
      cancelId: 1
    })
    if (dialogActionIndex === 1) {
      analytics.trackEventParams({
        ec: 'stop-timer',
        ea: 'cancel',
        el: '',
        ev: undefined
      })
    } else {
      closeTimer()
      displayManager.showMain()
      analytics.trackEventParams({
        ec: 'stop-timer',
        ea: 'confirm',
        el: '',
        ev: undefined
      })
    }
  } else {
    displayManager.toggleMain()
  }
  dialogDisplayed = false
}
