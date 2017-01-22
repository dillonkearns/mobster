'use strict';

var gulp = require('gulp');
var electron = require('electron-connect').server.create();

gulp.task('dev', function () {
  electron.start();
  gulp.watch(['src/elm.js'], electron.reload);
});
