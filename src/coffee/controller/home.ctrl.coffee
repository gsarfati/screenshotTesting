fs            = require 'fs'
path          = require 'path'
childProcess  = require 'child_process'
phantomjs     = require 'phantomjs'
spawn         = childProcess.spawn
binPath       = phantomjs.path

angular.module 'MyApp'

.controller 'HomeCtrl', ($scope, Devices) ->

  $scope.url = 'http://localhost:8100/#/tab/friends'
  $scope.screenshotSrc = 'none.png' 
  $scope.devices = Devices
  $scope.deviceSelected = Devices[0]

  replaceSpace = (str1) ->
    str2 = ''
    for letter, index in str1
     str2 += if letter is ' ' then '_' else letter
    str2
  $scope.screenshot =  ->
    extension = 'png'
    script = 'screenshot.js'
    regex = ///https?:\/\/([\w\.]+)[:0-9]*\/?(.*)///.exec $scope.url
    project = "#{regex[1]}"
    device = $scope.deviceSelected.replace ///\s///g, '_'
    filename = "#{regex[2]}.#{extension}"
    .replace /// ([^\w|^\.#{extension}]*) ///, ''
    .replace /// (\/) ///g, '.'
    .replace /// (^.#{extension}$) ///, "index$1"
    # console.log project
    # console.log filename
    # console.log regex
    # console.log 'capture en cours'
    # console.log 'phamtomjs screenshot.js '+$scope.url+' '+project+' '+filename
    console.log "phantomjs #{script} #{$scope.url} #{project} #{filename} #{device}"
    screenshot = spawn phantomjs.path, [
      script
      $scope.url
      project
      filename
      device
    ]

    screenshot.stdout.on 'data', (data) ->
      console.log 'capture win', filename
      $scope.screenshotSrc = 'screenshots/'+ project + '/current/' + filename
      $scope.$digest()
      # swith data
      #   'screendiff' :

    screenshot.stderr.on 'data', (data) ->
      console.log 'capture fail', data
