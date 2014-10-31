angular.module('MyApp', ['ui.router']).config(function($stateProvider, $urlRouterProvider) {
  $stateProvider.state("home", {
    url: "/home",
    templateUrl: "templates/home.html",
    controller: "HomeCtrl"
  });
  return $urlRouterProvider.otherwise("/home");
}).run(function() {});

var binPath, childProcess, fs, path, phantomjs, spawn;

fs = require('fs');

path = require('path');

childProcess = require('child_process');

phantomjs = require('phantomjs');

spawn = childProcess.spawn;

binPath = phantomjs.path;

angular.module('MyApp').controller('HomeCtrl', function($scope, Devices) {
  var replaceSpace;
  $scope.url = 'http://localhost:8100/#/tab/friends';
  $scope.filename = 'screenshot.png';
  $scope.project = 'localhost';
  $scope.screenshotSrc = 'none.png';
  $scope.devices = Devices;
  $scope.deviceSelected = Devices[0];
  replaceSpace = function(str1) {
    var index, letter, str2, _i, _len;
    str2 = '';
    for (index = _i = 0, _len = str1.length; _i < _len; index = ++_i) {
      letter = str1[index];
      str2 += letter === ' ' ? '_' : letter;
    }
    return str2;
  };
  return $scope.screenshot = function() {
    var screenshot;
    console.log('capture en cours');
    console.log('phamtomjs screenshot.js ' + $scope.url + ' ' + $scope.project + ' ' + $scope.filename);
    screenshot = spawn(phantomjs.path, ['screenshot.js', $scope.url, $scope.project, $scope.url + $scope.filename, replaceSpace($scope.deviceSelected)]);
    screenshot.stdout.on('data', function(data) {
      console.log('capture win', data);
      $scope.screenshotSrc = 'screenshots/' + $scope.project + '/current/' + $scope.filename;
      return $scope.$digest();
    });
    return screenshot.stderr.on('data', function(data) {
      return console.log('capture fail', data);
    });
  };
});

angular.module('MyApp').factory('Devices', function() {
  var devices;
  return devices = ["Desktop", "iPhone 5"];
});
