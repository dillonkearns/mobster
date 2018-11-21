See <https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md>
and the documentation for your dependencies for more information.

WARNING! 5 of your dependencies have not yet been upgraded to
support Elm 0.19.

- https://github.com/elm-community/array-extra
- https://github.com/elm-community/html-extra
- https://github.com/ktonon/elm-test-extra
- https://github.com/mdgriffith/elm-color-mixing
- https://github.com/scottcorgan/keyboard-combo

Here are some common upgrade steps that you will need to do manually:

- NoRedInk/elm-json-decode-pipeline
  - [x] Changes uses of Json.Decode.Pipeline.decode to Json.Decode.succeed
- elm/core
  - [x] Replace uses of toString with String.fromInt, String.fromFloat, or Debug.toString as appropriate
- undefined
  - [ ] Read the new documentation here: https://package.elm-lang.org/packages/elm/time/latest/
  - [ ] Replace uses of Date and Time with Time.Posix
- elm/browser
  - [x] Change code using Window.\* to use Browser.Events.onResize
- elm/html

  - [x] If you used Html.program\*, install elm/browser and switch to Browser.element or Browser.document
  - [x] If you used Html.beginnerProgram, install elm/browser and switch Browser.sandbox

  "elm-community/html-extra": "2.2.0",
  "ktonon/elm-test-extra": "1.4.0",
  "elm-community/array-extra": "1.0.2",
  "mdgriffith/elm-color-mixing": "1.1.1",
  "scottcorgan/keyboard-combo": "5.0.0"
