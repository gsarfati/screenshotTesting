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
    var device, extension, filename, project, regex, screenshot, script;
    extension = 'png';
    script = 'screenshot.js';
    regex = /https?:\/\/([\w\.]+)[:0-9]*\/?(.*)/.exec($scope.url);
    project = "" + regex[1];
    device = $scope.deviceSelected.replace(/\s/g, '_');
    filename = ("" + regex[2] + "." + extension).replace(RegExp("([^\\w|^\\." + extension + "]*)"), '').replace(/(\/)/g, '.').replace(RegExp("(^." + extension + "$)"), "index$1");
    console.log("phantomjs " + script + " " + $scope.url + " " + project + " " + filename + " " + device);
    screenshot = spawn(phantomjs.path, [script, $scope.url, project, filename, device]);
    screenshot.stdout.on('data', function(data) {
      console.log('capture win', filename);
      $scope.screenshotSrc = 'screenshots/' + project + '/current/' + filename;
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
