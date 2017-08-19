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
import * as url from 'url'
const osascript = require('node-osascript')
import * as path from 'path'
const assetsDirectory = path.join(__dirname, '../assets')

const onMac = /^darwin/.test(process.platform)
const onWindows = /^win/.test(process.platform)
import { Ipc, ElmIpc } from './ipc'

export class DisplayManager {
  private mainWindow: Electron.BrowserWindow
  private secondaryWindows: Electron.BrowserWindow[]
  private scriptsWindow: Electron.BrowserWindow | null

  constructor(
    private transparencyDisabled: boolean,
    private bugsnag: any,
    private closeTimerFunction: (() => void),
    private ipcHandler: ((ipc: ElmIpc) => void)
  ) {
    this.createMainWindow()
  }

  showMain() {
    if (!this.mainWindow.isVisible()) {
      // this.showMainWindow()
      this.createSecondaryWindows()
    }
  }

  getMainWindow() {
    return this.mainWindow
  }

  hideMain() {
    this.hideMainWindow()
    this.closeSecondaryWindows()
    returnFocus()
  }

  hideMainKeepFocus() {
    this.hideMainWindow()
    this.closeSecondaryWindows()
  }

  toggleMain() {
    if (this.mainWindow.isVisible()) {
      this.hideMain()
    } else {
      this.showMain()
    }
  }

  newTransparentOnTopWindow(
    additionalOptions: Electron.BrowserWindowConstructorOptions
  ) {
    const transparentWindowDefaultOptions: Electron.BrowserWindowConstructorOptions = {
      transparent: !this.transparencyDisabled,
      frame: false,
      alwaysOnTop: true
    }
    return new BrowserWindow({
      ...transparentWindowDefaultOptions,
      ...additionalOptions
    })
  }

  private hideMainWindow() {
    this.mainWindow.hide()
  }

  private createSecondaryWindows() {
    let displays: Electron.Display[] = screen
      .getAllDisplays()
      .filter(display => display.id !== screen.getPrimaryDisplay().id)
    this.secondaryWindows = displays.map(display =>
      this.createSecondaryWindow(display)
    )

    this.showAllWhenReady(this.mainWindow, this.secondaryWindows)
  }

  private showAllWhenReady(
    mainWindow: Electron.BrowserWindow,
    windows: Electron.BrowserWindow[]
  ): void {
    let readyToDisplay = windows.map(window => {
      return { id: window.id, ready: false }
    })
    windows.forEach(window => {
      window.once('ready-to-show', () => {
        if (window) {
          let entry = readyToDisplay.find(({ id }) => id === window.id)
          entry && (entry.ready = true)
          if (readyToDisplay.every(({ ready }) => ready)) {
            mainWindow.show()
            windows.forEach(window => window.show())
          }
        }
      })
    })
  }

  private showAll() {
    this.mainWindow.show()
    this.secondaryWindows.forEach(window => window.show())
  }

  private closeSecondaryWindows() {
    this.secondaryWindows.forEach(secondaryWindow => secondaryWindow.close())
    this.secondaryWindows = []
  }

  createSecondaryWindow(display: Electron.Display) {
    let secondaryWindow: Electron.BrowserWindow = this.newTransparentOnTopWindow(
      {
        frame: false,
        alwaysOnTop: true,
        focusable: false,
        show: false,
        ...display.bounds
      }
    )
    secondaryWindow.loadURL(
      url.format({
        pathname: path.join(__dirname, '../blocker.html'),
        protocol: 'file:',
        slashes: true
      })
    )

    return secondaryWindow
  }

  showScripts() {
    this.scriptsWindow = new BrowserWindow({
      width: 1000,
      height: 800,
      frame: true,
      icon: `${assetsDirectory}/icon.ico`,
      show: false
    })
    this.scriptsWindow.loadURL(
      url.format({
        pathname: path.join(__dirname, '../script-install-instructions.html'),
        protocol: 'file:',
        slashes: true
      })
    )
    this.scriptsWindow.once('ready-to-show', () => {
      if (this.scriptsWindow) {
        this.hideMainKeepFocus()
        this.scriptsWindow.show()
      }
    })

    this.scriptsWindow.on('closed', () => {
      this.scriptsWindow = null
      this.showMain()
    })
  }

  private createMainWindow() {
    this.mainWindow = this.newTransparentOnTopWindow({
      icon: `${assetsDirectory}/icon.ico`,
      show: false
    })

    this.mainWindow.once('ready-to-show', () => {
      // this.mainWindow && this.mainWindow.show()
      this.createSecondaryWindows()
    })

    this.mainWindow.webContents.on('crashed', () => {
      this.bugsnag.notify('crashed', 'mainWindow crashed')
    })
    this.mainWindow.on('unresponsive', () => {
      this.bugsnag.notify('unresponsive', 'mainWindow unresponsive')
    })
    setTimeout(() => {
      this.mainWindow.setAlwaysOnTop(true) // delay to workaround https://github.com/electron/electron/issues/8287
    }, 1000)
    this.mainWindow.maximize()

    screen.on('display-metrics-changed', () => {
      this.mainWindow.maximize()
    })

    let prodUrl = url.format({
      pathname: path.join(__dirname, '../setup.prod.html'),
      protocol: 'file:'
    })
    let devUrl = url.format({
      hostname: 'localhost',
      pathname: 'setup.dev.html',
      port: '8080',
      protocol: 'http',
      slashes: true
    })
    let nodeDevEnv = process.env.NODE_ENV === 'dev'

    this.mainWindow.loadURL(nodeDevEnv ? devUrl : prodUrl)

    Ipc.setupIpcMessageHandler(this.ipcHandler)

    ipcMain.on('timer-done', (event: any, timeElapsed: any) => {
      this.closeTimerFunction()
      this.mainWindow.webContents.send('timer-done', timeElapsed)
      this.showMain()
    })

    ipcMain.on('break-done', (event: any, timeElapsed: any) => {
      this.closeTimerFunction()
      this.mainWindow.webContents.send('break-done', timeElapsed)
      this.showMain()
    })

    ipcMain.on('transparent-hover-stop', (event: any) => {
      this.secondaryWindows.forEach(secondaryWindow =>
        secondaryWindow.webContents.send('transparent-hover-stop')
      )
    })
    ipcMain.on('transparent-hover-start', (event: any) => {
      this.secondaryWindows.forEach(secondaryWindow =>
        secondaryWindow.webContents.send('transparent-hover-start')
      )
    })

    this.mainWindow.on('closed', function() {
      app.quit()
    })
  }
}

function returnFocus() {
  if (onMac) {
    returnFocusMac()
  }
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
  osascript.execute(returnFocusOsascript, function(
    err: any,
    result: any,
    raw: any
  ) {
    if (err) {
      return console.error(err)
    }
    console.log(result, raw)
  })
}
