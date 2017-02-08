const electron = require('electron')
const {ipcMain, globalShortcut, app, Tray, BrowserWindow} = require('electron')

const path = require('path')
const url = require('url')
const log = require('electron-log')
const assetsDirectory = path.join(__dirname, 'assets')
const {version} = require('./package')

log.info(`Running version ${version}`)


// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow, timerWindow, tray

const timerHeight = 130
const timerWidth = 150

const onMac = /^darwin/.test(process.platform)

function positionWindowLeft(window) {
  let {width, height} = electron.screen.getPrimaryDisplay().workAreaSize
  window.setPosition(0, height - timerHeight);
}

function positionWindowRight(window) {
  const {width, height} = electron.screen.getPrimaryDisplay().workAreaSize
  window.setPosition(width - timerWidth, height - timerHeight);
}

function startTimer(flags) {
  timerWindow = new BrowserWindow({transparent: true, frame: false, alwaysOnTop: true,
    width: timerWidth, height: timerHeight, focusable: false})

  positionWindowRight(timerWindow)

  ipcMain.once('timer-flags', (event) => {
    event.returnValue = flags
  })


  timerWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'timer.html'),
    protocol: 'file:',
    slashes: true
  }))


}

ipcMain.on('timer-mouse-hover', (event) => {
  [x, y] = timerWindow.getPosition()
  if (x === 0) {
    positionWindowRight(timerWindow)
  } else {
    positionWindowLeft(timerWindow)
  }
})

function closeTimer() {
  if (timerWindow) {
    timerWindow.close()
    timerWindow = null
  }
}

function showSetupAgain(setupWindow) {
  setupWindow.show()
}

function createWindow () {
  mainWindow = new BrowserWindow({
    transparent: true,
    frame: false,
    alwaysOnTop: true,
    icon: `${assetsDirectory}/icon.ico`
  })
  mainWindow.maximize()
  mainWindow.setResizable(false)

  electron.screen.on('display-metrics-changed', function () {
    mainWindow.setResizable(true)
    mainWindow.maximize()
    mainWindow.setResizable(false)
  })

  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'setup.html'),
    protocol: 'file:',
    slashes: true
  }))

  mainWindow.center()

  ipcMain.on('start-timer', (event, flags) => {
    startTimer(flags)
    mainWindow.hide()
  })

  ipcMain.on('timer-done', (event, timeElapsed) => {
    closeTimer()
    mainWindow.webContents.send('timer-done', timeElapsed)
    showSetupAgain(mainWindow)
  })

  ipcMain.on('quit', (event) => {
    app.quit()
  })

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })


}

function toggleMainWindow() {
  if (mainWindow.isVisible()) {
    mainWindow.hide()
  }
  else {
    mainWindow.show()
  }
}

function onClickTrayIcon() {
  if (!timerWindow) {
    toggleMainWindow()
  } else {
    closeTimer()
    showSetupAgain(mainWindow)
  }
}

const createTray = () => {
  tray = new Tray(path.join(assetsDirectory, 'tray-icon.png'))
  tray.on('right-click', onClickTrayIcon)
  tray.on('double-click', onClickTrayIcon)
  tray.on('click', onClickTrayIcon)
}

function createWindows() {
  createWindow()
  createTray()
  globalShortcut.register('CommandOrControl+Shift+K', () => {
    if (!timerWindow) {
      toggleMainWindow()
    }
  })
  globalShortcut.register('CommandOrControl+Shift+;', () => {
    copyActiveMobsters()
  })
}
function copyActiveMobsters() {
  mainWindow.webContents.send('copy-active-mobsters')
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindows)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
