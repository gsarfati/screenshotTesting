angular.module 'MyApp', [
  'ui.router'
]

.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider

  .state "home",
    url: "/home"
    templateUrl: "templates/home.html"
    controller: "HomeCtrl"
 
  $urlRouterProvider.otherwise "/home"

.run ->