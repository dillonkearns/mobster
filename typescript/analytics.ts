import * as ua from 'universal-analytics'
const packageJson = require('../package.json')
const version: string = packageJson.version
const isLocal = require('electron-is-dev')
import { screen } from 'electron'

interface AnalyticsEvent {
  category: string
  action: string
  label: string
  value: any
}

const googleAnalyticsId = 'UA-104160912-1'

function screenResolutions() {
  return screen
    .getAllDisplays()
    .map(({ bounds }) => `${bounds.width}x${bounds.height}`)
    .join(' ')
}

export class Analytics {
  analytics: ua.Visitor

  constructor() {
    require('machine-uuid')((uuid: string) => {
      if (isLocal) {
        this.analytics = ua('')
      } else {
        this.analytics = ua(googleAnalyticsId, uuid)
      }
      this.analytics.set('sr', screenResolutions()) // screenResolution
      this.analytics.set('ua', `${process.platform} ${require('os').release()}`)
      this.analytics.set('an', 'Mobster') // appName
      this.analytics.set('av', version) // appVersion
      this.trackPage('/', { sc: 'start' }) // sessionControl
    })
  }

  endSession() {
    this.trackPage('/quit', { sc: 'end' })
  }

  trackPage(path: string, options?: ua.PageviewParams) {
    this.analytics.pageview({ dp: path, ...options }).send()
  }

  trackEvent(event: AnalyticsEvent) {
    const { category, action, label, value } = event
    this.analytics.event(category, action, label, value).send()
  }

  trackEventParams(event: {
    ec: string
    ea: string
    el: string | undefined
    ev: number | undefined
  }) {
    this.analytics.event(event).send()
  }
}
