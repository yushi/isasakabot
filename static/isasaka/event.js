var isasakaEventApp = angular.module('isasakaEventApp', []);

isasakaEventApp.controller('EventCtrl', function ($scope, $location, $http) {
  $scope.event_name = $location.search().event;
  if(!$scope.event_name){ return; }

  $scope.adding_column = false
  $scope.adding_user = false
  $scope.editing_cell = false

  $scope.column_text = null;
  $scope.new_user = null;

  $scope.load = function(){
    $http.get('/hubot/event/' + $scope.event_name).success(function(data){
      $scope.owner = data.owner;
      $scope.headers = data.header;
      $scope.userdata = {}
      for(var username in data.users){
        $scope.userdata[username] = []
        for(var i in data.users[username]){
          $scope.userdata[username].push({
            'msg': data.users[username][i],
            'cell_txt': data.users[username][i],
            'editing': false,
            'name': username,
            'idx': i
          })
        }
      }
      $scope.data = data;
    });
  }

  $scope.add_column = function(){
    $scope.adding_column = false;
    if($scope.column_text == null){
      return;
    }
    $http.post('/hubot/event/' + $scope.event_name,
               {'type': 'add_column',
                'data': $scope.column_text
              }).success(function(){
                $scope.column_text = '';
                $scope.load();
              });
  }

  $scope.add_user = function(){
    $scope.adding_user = false;
    if($scope.new_user == null){
      return;
    }
    $http.post('/hubot/event/' + $scope.event_name,
               {'type': 'add_user',
                'data': $scope.new_user
              }).success(function(){
                $scope.new_user = '';
                $scope.load();
              });
  }

  $scope.edit_cell = function(data){
    data.editing = false;
    if(data.msg === data.cell_txt){
      return;
    }
    $http.post('/hubot/event/' + $scope.event_name,
               {'type': 'edit_cell',
                'data': {
                  'name': data.name,
                  'idx': data.idx,
                  'txt': data.cell_txt
                }
              }).success(function(){
                data.cell_text = '';
                $scope.load();
              });
  }

  $scope.load();
});
