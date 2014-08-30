
gulp = require 'gulp'
filetree = require 'make-filetree'
watch = require 'gulp-watch'
html = require 'gulp-cirru-html'
reloader = require 'gulp-reloader'
coffee = require 'gulp-coffee'
browserify = require 'browserify'
source = require 'vinyl-source-stream'
buffer = require 'vinyl-buffer'
plumber = require 'gulp-plumber'
rsync = require('rsyncwrapper').rsync
uglify = require 'gulp-uglify'
rename = require 'gulp-rename'
sequence = require 'run-sequence'
prefixer = require 'gulp-autoprefixer'
cssmin = require 'gulp-cssmin'
rimraf = require 'gulp-rimraf'
transform = require 'vinyl-transform'

project = 'Cirru/vertical-coding/index.html'
dev = yes
vendors = ['cirru-color']

gulp.task 'folder', ->
  filetree.make '.',
    coffee:
      'main.coffee': ''
    css:
      'style.css': ''
    cirru:
      'index.cirru': ''
    'README.md': ''
    build: {}
    js: {}

gulp.task 'watch', ->
  reloader.listen()

  gulp
  .src 'cirru/*'
  .pipe watch()
  .pipe plumber()
  .pipe html(data: {dev: yes})
  .pipe gulp.dest('./')
  .pipe reloader(project)

  gulp
  .src 'coffee/**/*.coffee'
  .pipe watch()
  .pipe plumber()
  .pipe (coffee bare: yes)
  .pipe (gulp.dest 'build/js/')

  watch glob: 'build/js/**/*.js', (files) ->
    gulp
    .src './build/js/main.js'
    .pipe plumber()
    .pipe transform (filename) ->
      b = browserify filename
      b.external vendor for vendor in vendors
      b.bundle()
    .pipe gulp.dest('build/')
    .pipe reloader(project)
    return files

gulp.task 'js', ->
  b = browserify debug: no
  b.add './build/js/main'
  b.external vendor for vendor in vendors
  b.bundle()
  .pipe source('main.js')
  .pipe gulp.dest('build/')

gulp.task 'coffee', ->
  gulp
  .src 'coffee/**/*.coffee', base: 'coffee/'
  .pipe (coffee bare: yes)
  .pipe (gulp.dest 'build/js/')

gulp.task 'html', ->
  gulp
  .src 'cirru/*'
  .pipe html(data: {dev: dev})
  .pipe gulp.dest('.')

gulp.task 'jsmin', ->
  b = browserify debug: no
  b.add './build/js/main'
  b.external vendor for vendor in vendors
  b.bundle()
  .pipe source('main.min.js')
  .pipe buffer()
  .pipe uglify()
  .pipe gulp.dest('dist/')

gulp.task 'vendor', ->
  b = browserify debug: no
  b.require vendor for vendor in vendors
  b.bundle()
  .pipe source('vendor.min.js')
  .pipe buffer()
  .pipe uglify()
  .pipe gulp.dest('dist/')

gulp.task 'prefixer', ->
  gulp
  .src 'css/**/*.css', base: 'css/'
  .pipe prefixer()
  .pipe gulp.dest('build/css/')

gulp.task 'cssmin', ->
  gulp
  .src 'build/css/index.css'
  .pipe cssmin()
  .pipe rename(suffix: '.min')
  .pipe gulp.dest('dist/')

gulp.task 'clean', ->
  gulp
  .src ['build/', 'dist/']
  .pipe rimraf()

gulp.task 'dev', ->
  sequence 'clean', ['html', 'coffee', 'vendor'], 'js'

gulp.task 'build', ->
  dev = no
  sequence 'clean',
    ['coffee', 'html'], ['jsmin', 'vendor'],
    'prefixer', 'cssmin'

gulp.task 'rsync', ->
  rsync
    ssh: yes
    src: '.'
    recursive: true
    args: ['--verbose']
    dest: "tiye:~/repo/cirru/vertical-coding"
    deleteAll: yes
    exclude: [
      'bower_components/'
      'node_modules/'
      'cirru/'
      '.gitignore'
      '.npmignore'
      'README.md'
      'coffee/'
      'css/'
      'build/'
      'gulpfile.coffee'
      '*.json'
    ]
  , (error, stdout, stderr, cmd) ->
    if error? then throw error
    if stderr?
      console.error stderr
    else
      console.log cmd