fs            = require 'fs'
path          = require 'path'
childProcess  = require 'child_process'
phantomjs     = require 'phantomjs'
spawn         = childProcess.spawn
binPath       = phantomjs.path

angular.module 'MyApp'

.controller 'HomeCtrl', ($scope, Devices) ->

  $scope.url = 'http://localhost:8100/#/tab/friends'
  $scope.filename = 'screenshot.png'
  $scope.project = 'localhost'
  $scope.screenshotSrc = 'none.png' 
  $scope.devices = Devices
  $scope.deviceSelected = Devices[0]
  replaceSpace = (str1) ->
    str2 = ''
    for letter, index in str1
     str2 += if letter is ' ' then '_' else letter
    str2
  $scope.screenshot =  ->
    console.log 'capture en cours'
    console.log 'phamtomjs screenshot.js '+$scope.url+' '+$scope.project+' '+$scope.filename
    screenshot = spawn phantomjs.path, [
      'screenshot.js'
      $scope.url
      $scope.project
      $scope.filename
      replaceSpace $scope.deviceSelected
    ]

    screenshot.stdout.on 'data', (data) ->
      console.log 'capture win', data
      $scope.screenshotSrc = 'screenshots/'+ $scope.project + '/current/' + $scope.filename
      $scope.$digest()
      # swith data
      #   'screendiff' :

    screenshot.stderr.on 'data', (data) ->
      console.log 'capture fail', data
