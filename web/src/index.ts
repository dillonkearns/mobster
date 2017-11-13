import * as Elm from './Main'
declare var gtag: any

let app = Elm.Main.fullscreen({ os: navigator.platform })

app.ports.trackEvent.subscribe(function(data) {
  console.log('trackEvent', data)
  gtag('event', data.name, {
    event_category: data.category,
    event_label: data.label
  })
})
