import * as ua from 'universal-analytics'
const packageJson = require('../package.json')
const version: string = packageJson.version
const isLocal = require('electron-is-dev')

interface AnalyticsEvent {
  category: string
  action: string
  label: string
  value: any
}

const googleAnalyticsId = 'UA-104160912-1'

export class Analytics {
  analytics: ua.Visitor

  constructor() {
    require('machine-uuid')((uuid: string) => {
      if (isLocal) {
        this.analytics = ua('')
      } else {
        this.analytics = ua(googleAnalyticsId, uuid)
      }
      this.analytics.set('ua', `${process.platform} ${require('os').release()}`)
      this.analytics.set('appVersion', version)
      this.trackPage('/')
    })
  }

  trackPage = (path: string) => {
    this.analytics.pageview(path).send()
  }

  trackEvent = (event: AnalyticsEvent) => {
    const { category, action, label, value } = event
    this.analytics.event(category, action, label, value).send()
  }

  trackEventParams = (event: {
    ec: string
    ea: string
    el: string | undefined
    ev: number | undefined
  }) => {
    this.analytics.event(event).send()
  }
}
