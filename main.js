const electron = require('electron')
const {ipcMain} = require('electron')
// Module to control application life.
const app = electron.app
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow

const path = require('path')
const url = require('url')

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow, timerWindow

const timerHeight = 130

function positionWindowLeft(window) {
  let bounds = electron.screen.getPrimaryDisplay().bounds
  let width = 150;
  window.setPosition(0, bounds.height - timerHeight);
}

function positionWindowRight(window) {
  let bounds = electron.screen.getPrimaryDisplay().bounds
  let width = 150;
  window.setPosition(bounds.width - width, bounds.height - timerHeight);
}

function startTimer(flags) {
  let width = 150;
  timerWindow = new BrowserWindow({transparent: true, frame: false, alwaysOnTop: true,
    width: width, height: timerHeight})

  positionWindowLeft(timerWindow)

  ipcMain.once('timer-flags', (event) => {
    event.returnValue = flags
  })


  timerWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'timer.html'),
    protocol: 'file:',
    slashes: true
  }))


  ipcMain.on('timer-mouse-hover', (event) => {
    [x, y] = timerWindow.getPosition()
    if (x === 0) {
      positionWindowRight(timerWindow)
    } else {
      positionWindowLeft(timerWindow)
    }
  })
}

function closeTimer() {
  if (timerWindow) {
    timerWindow.close()
    timerWindow = null
  }
}

function showSetupAgain(setupWindow) {
  setupWindow.setAlwaysOnTop(true)
  setupWindow.maximize()
  setupWindow.show()
}

function createWindow () {
  mainWindow = new BrowserWindow({transparent: true, frame: false,
    width: 350, height: 250})

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

  ipcMain.on('timer-done', (event) => {
    closeTimer()
    showSetupAgain(mainWindow)
  })


  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })


}

function createWindows() {
  createWindow()
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
