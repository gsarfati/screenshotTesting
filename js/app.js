angular.module('MyApp', ['ui.router']).config(function($stateProvider, $urlRouterProvider) {
  $stateProvider.state("home", {
    url: "/home",
    templateUrl: "templates/home.html",
    controller: "HomeCtrl"
  });
  return $urlRouterProvider.otherwise("/home");
}).run(function() {});

var binPath, childProcess, fs, gui, path, phantomjs, spawn;

fs = require('fs');

path = require('path');

childProcess = require('child_process');

phantomjs = require('phantomjs');

spawn = childProcess.spawn;

binPath = phantomjs.path;

gui = require('nw.gui');

angular.module('MyApp').controller('HomeCtrl', function($scope, Devices) {
  var replaceSpace;
  $scope.loader = true;
  $scope.url = 'http://toto.com';
  $scope.screenshotSrc = 'none.png';
  $scope.devices = Devices;
  $scope.deviceSelected = Devices[0];
  $scope.nbPixelDiff = 0;
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
    $scope.loader = true;
    extension = 'png';
    script = 'screenshot.js';
    regex = /https?:\/\/([\w\.]+)[:0-9]*\/?(.*)/.exec($scope.url);
    project = "" + regex[1];
    device = $scope.deviceSelected.replace(/\s/g, '_');
    filename = ("" + regex[2] + "." + extension).replace(RegExp("([^\\w|^\\." + extension + "]*)"), '').replace(/(\/)/g, '.').replace(RegExp("(^." + extension + "$)"), "index$1");
    console.log("phantomjs " + script + " " + $scope.url + " " + project + " " + filename + " " + device);
    screenshot = spawn(phantomjs.path, [script, $scope.url, project, filename, device]);
    screenshot.stdout.on('data', function(data) {
      var diff;
      console.log('capture win', filename);
      diff = spawn('coffee', ["testpng.coffee", "screenshots/" + project + "/current/" + filename, "screenshots/" + project + "/expected/" + filename, "screenshots/" + project + "/diff/" + filename, "--writeNbPixelDiff"]);
      return diff.stdout.on('data', function(data) {
        $scope.nbPixelDiff = parseInt(data);
        $scope.loader = false;
        $scope.screenshotSrc = 'data:image/png;base64,' + fs.readFileSync("screenshots/" + project + "/diff/" + filename).toString('base64');
        console.log('imgbase64');
        return $scope.$digest();
      });
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
