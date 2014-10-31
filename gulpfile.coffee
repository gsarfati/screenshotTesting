sh              = require 'shelljs'
gulp            = require 'gulp'
concat          = require 'gulp-concat'
jade            = require 'gulp-jade'
coffee          = require 'gulp-coffee'

gulp.task 'coffee', (done) ->
  gulp.src  "./src/coffee/**/*.coffee"
    .pipe coffee bare: true
    .pipe concat 'app.js'
    .pipe gulp.dest './js'
    .on 'end', done
  return

gulp.task 'index', (done) ->
  gulp.src "./src/index.jade"
    .pipe jade pretty: true, doctype: 'html'
    .pipe gulp.dest __dirname
    .on 'end', done
  return

gulp.task 'jade', (done) ->
  gulp.src "./src/jade/**.jade"
    .pipe jade pretty: true, doctype: 'html'
    .pipe gulp.dest __dirname + '/templates'
    .on 'end', done
  return

gulp.task 'watch', ['build'], ->
  gulp.watch "./src/coffee/**/*.coffee", ['coffee']
  gulp.watch "./src/jade/**/*.jade", ['jade']
  gulp.watch "./src/index.jade", ['index']
  return

gulp.task 'build', ['coffee', 'jade', 'index']
