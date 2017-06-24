const electron = require('electron')
const {
  ipcMain,
  globalShortcut,
  app,
  Tray,
  BrowserWindow,
  dialog,
  shell,
  remote
} = require('electron')
const fs = require('fs')

const transparencyDisabled = fs.existsSync(
  `${app.getPath('userData')}/NO_TRANSPARENCY`
)
const autoUpdater = require('electron-updater').autoUpdater
autoUpdater.requestHeaders = { 'Cache-Control': 'no-cache' }
require('electron-debug')({
  enabled: true // enable debug shortcuts in prod build
})

const child_process = require('child_process')
const ms = require('ms')
const path = require('path')
const url = require('url')
const log = require('electron-log')
const assetsDirectory = path.join(__dirname, 'assets')
const { version } = require('./package')
const osascript = require('node-osascript')
const appDataPath = app.getPath('userData')
currentMobstersFilePath = path.join(appDataPath, 'active-mobsters')
const bugsnag = require('bugsnag')
const isDev = require('electron-is-dev')
log.info(`Running version ${version}`)

let checkForUpdates = true

let releaseStage = isDev ? 'development' : 'production'
bugsnag.register('032040bba551785c7846442332cc067f', {
  autoNotify: true,
  appVersion: version,
  releaseStage: releaseStage
})

const shouldQuit = app.makeSingleInstance((commandLine, workingDirectory) => {
  // Someone tried to run a second instance, we should focus our window.
  if (mainWindow) {
    focusMainWindow()
  }
})
if (shouldQuit) {
  app.quit()
}

const returnFocusOsascript = `tell application "System Events"
	set activeApp to name of application processes whose frontmost is true
	if (activeApp = {"Mobster"} or activeApp = {"Electron"}) then
		tell application "System Events"
      delay 0.25 -- prevent issues when user is still holding down Command for a fraction of a second pressing Cmd+Shift+K shortcut
			key code 48 using {command down}
		end tell
	end if
end tell`

function returnFocusMac() {
  osascript.execute(returnFocusOsascript, function(err, result, raw) {
    if (err) {
      return console.error(err)
    }
    console.log(result, raw)
  })
}

function writeToFile(filePath, fileContents) {
  fs.writeFile(filePath, fileContents, function(err) {
    if (err) {
      console.log(err)
    }
  })
}

function updateMobsterNamesFile(currentMobsterNames) {
  writeToFile(currentMobstersFilePath, currentMobsterNames)
}

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow, timerWindow, tray

const timerHeight = 130
const timerWidth = 150

const onMac = /^darwin/.test(process.platform)
const onWindows = /^win/.test(process.platform)

function focusMainWindow() {
  // TODO: workaround - remove once
  // https://github.com/electron/electron/issues/2867#issuecomment-264312493 has been resolved
  if (onWindows) {
    mainWindow.minimize()
  }
  mainWindow.show()
  mainWindow.focus()
}

function hideMainWindow() {
  mainWindow.hide()
  returnFocus()
}

function positionWindowLeft(window) {
  let { width, height } = electron.screen.getPrimaryDisplay().workAreaSize
  window.setPosition(0, height - timerHeight)
}

function positionWindowRight(window) {
  const { width, height } = electron.screen.getPrimaryDisplay().workAreaSize
  window.setPosition(width - timerWidth, height - timerHeight)
}

function returnFocus() {
  if (onMac) {
    returnFocusMac()
  }
}

function startTimer(flags) {
  timerWindow = newTransparentOnTopWindow({
    width: timerWidth,
    height: timerHeight,
    focusable: false
  })

  timerWindow.webContents.on('crashed', function() {
    bugsnag.notify('crashed', 'timerWindow crashed')
  })
  timerWindow.on('unresponsive', function() {
    bugsnag.notify('unresponsive', 'timerWindow unresponsive')
  })

  positionWindowRight(timerWindow)

  ipcMain.once('timer-flags', event => {
    event.returnValue = flags
  })

  timerWindow.loadURL(
    url.format({
      pathname: path.join(__dirname, 'timer.html'),
      protocol: 'file:',
      slashes: true
    })
  )
}

ipcMain.on('timer-mouse-hover', event => {
  ;[x, y] = timerWindow.getPosition()
  if (x === 0) {
    positionWindowRight(timerWindow)
  } else {
    positionWindowLeft(timerWindow)
  }
})

ipcMain.on('ChangeShortcut', (event, payload) => {
  globalShortcut.unregisterAll()
  if (payload !== '') {
    setShowHideShortcut(payload)
  }
})

ipcMain.on('NotifySettingsDecodeFailed', (event, payload) => {
  bugsnag.notify('settings-decode-failure', payload)
})

ipcMain.on('get-active-mobsters-path', event => {
  event.returnValue = currentMobstersFilePath
})

function closeTimer() {
  if (timerWindow) {
    timerWindow.close()
    timerWindow = null
  }
}

function createWindow() {
  mainWindow = newTransparentOnTopWindow({
    icon: `${assetsDirectory}/icon.ico`
  })

  mainWindow.webContents.on('crashed', function() {
    bugsnag.notify('crashed', 'mainWindow crashed')
  })
  mainWindow.on('unresponsive', function() {
    bugsnag.notify('unresponsive', 'mainWindow unresponsive')
  })
  setTimeout(() => {
    mainWindow.setAlwaysOnTop(true) // delay to workaround https://github.com/electron/electron/issues/8287
  }, 1000)
  mainWindow.maximize()

  electron.screen.on('display-metrics-changed', function() {
    mainWindow.maximize()
  })

  mainWindow.loadURL(
    url.format({
      pathname: path.join(__dirname, 'setup.html'),
      protocol: 'file:',
      slashes: true
    })
  )

  ipcMain.on('StartTimer', (event, flags) => {
    startTimer(flags)
    hideMainWindow()
  })

  ipcMain.on('SaveActiveMobstersFile', (event, currentMobsterNames) => {
    updateMobsterNamesFile(currentMobsterNames)
  })

  ipcMain.on('OpenExternalUrl', (event, url) => {
    hideMainWindow()
    shell.openExternal(url)
  })

  ipcMain.on('timer-done', (event, timeElapsed) => {
    closeTimer()
    mainWindow.webContents.send('timer-done', timeElapsed)
    focusMainWindow()
  })

  ipcMain.on('break-done', (event, timeElapsed) => {
    closeTimer()
    mainWindow.webContents.send('break-done', timeElapsed)
    focusMainWindow()
  })

  ipcMain.on('Quit', event => {
    app.quit()
  })

  ipcMain.on('ShowFeedbackForm', event => {
    new BrowserWindow({ show: true, frame: true, alwaysOnTop: true }).loadURL(
      'https://dillonkearns.typeform.com/to/k9P6iV'
    )
  })

  ipcMain.on('ShowScriptInstallInstructions', event => {
    showScripts()
  })

  ipcMain.on('Hide', event => {
    toggleMainWindow()
  })

  ipcMain.on('QuitAndInstall', () => {
    autoUpdater.quitAndInstall()
  })

  // Emitted when the window is closed.
  mainWindow.on('closed', function() {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })
}

function toggleMainWindow() {
  if (mainWindow.isVisible()) {
    hideMainWindow()
  } else {
    focusMainWindow()
  }
}

function onClickTrayIcon() {
  if (!timerWindow) {
    toggleMainWindow()
  } else {
    closeTimer()
    focusMainWindow()
  }
}

const createTray = () => {
  tray = new Tray(path.join(assetsDirectory, 'tray-icon.png'))
  tray.on('right-click', onClickTrayIcon)
  tray.on('double-click', onClickTrayIcon)
  tray.on('click', onClickTrayIcon)
}

function newTransparentOnTopWindow(additionalOptions) {
  return new BrowserWindow(
    Object.assign(
      {
        transparent: !transparencyDisabled,
        frame: false,
        alwaysOnTop: true
      },
      additionalOptions
    )
  )
}

function showScripts() {
  mainWindow.hide()
  let scriptsWindow = new BrowserWindow({
    width: 1000,
    height: 800,
    frame: true,
    icon: `${assetsDirectory}/icon.ico`
  })
  scriptsWindow.loadURL(
    url.format({
      pathname: path.join(__dirname, 'script-install-instructions.html'),
      protocol: 'file:',
      slashes: true
    })
  )
  scriptsWindow.on('closed', () => {
    scriptsWindow = null
    toggleMainWindow()
  })
}

function onReady() {
  createWindow()
  createTray()
  setupAutoUpdater()
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', onReady)

// Quit when all windows are closed.
app.on('window-all-closed', function() {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function() {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})

function setupAutoUpdater() {
  autoUpdater.logger = log
  autoUpdater.on('checking-for-update', () => {
    log.info('checking-for-update')
  })

  autoUpdater.on('error', (ev, err) => {
    checkForUpdates = true
  })

  autoUpdater.on('update-available', () => {
    log.info('update-available')
    checkForUpdates = false
  })

  autoUpdater.on('update-downloaded', versionInfo => {
    log.info('update-downloaded: ', versionInfo)
    mainWindow.webContents.send('update-downloaded', versionInfo)
  })

  autoUpdater.on('update-not-available', () => {
    log.info('update-not-available')
  })

  if (!isDev) {
    autoUpdater.checkForUpdates()
    log.info('About to set up interval')
    function myCheckForUpdates() {
      log.info('About to check for updates on interval')

      if (checkForUpdates) {
        autoUpdater.checkForUpdates()
      }
    }
    setInterval(myCheckForUpdates, 120 * 1000)
  }
}

function setShowHideShortcut(shortcutString) {
  globalShortcut.register(shortcutString, () => {
    if (timerWindow) {
      app.focus() // ensure that app is focused so dialog appears in foreground
      let dialogActionIndex = dialog.showMessageBox({
        type: 'warning',
        buttons: ['Stop timer', 'Keep it running'],
        message: 'Stop the timer?',
        cancelId: 1
      })
      if (dialogActionIndex !== 1) {
        closeTimer()
        mainWindow.show()
        mainWindow.focus()
      }
    } else {
      toggleMainWindow()
    }
  })
}
