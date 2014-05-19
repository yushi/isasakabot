isasakaEventApp = angular.module("isasakaEventApp", [])
isasakaEventApp.controller "EventCtrl", ($scope, $location, $http) ->
  $scope.event_name = $location.search().event
  return  unless $scope.event_name
  $scope.adding_column = false
  $scope.adding_user = false
  $scope.editing_cell = false
  $scope.column_text = null
  $scope.new_user = null
  $scope.load = ->
    $http.get("/hubot/event/" + $scope.event_name).success (data) ->
      $scope.owner = data.owner
      $scope.headers = data.header
      $scope.userdata = {}
      for username of data.users
        $scope.userdata[username] = []
        for i of data.users[username]
          $scope.userdata[username].push
            msg: data.users[username][i]
            cell_txt: data.users[username][i]
            editing: false
            name: username
            idx: i

      $scope.data = data


  $scope.add_column = ->
    $scope.adding_column = false
    return  unless $scope.column_text?
    $http.post("/hubot/event/" + $scope.event_name,
      type: "add_column"
      data: $scope.column_text
    ).success ->
      $scope.column_text = ""
      $scope.load()


  $scope.add_user = ->
    $scope.adding_user = false
    return  unless $scope.new_user?
    $http.post("/hubot/event/" + $scope.event_name,
      type: "add_user"
      data: $scope.new_user
    ).success ->
      $scope.new_user = ""
      $scope.load()


  $scope.edit_cell = (data) ->
    data.editing = false
    return  if data.msg is data.cell_txt
    $http.post("/hubot/event/" + $scope.event_name,
      type: "edit_cell"
      data:
        name: data.name
        idx: data.idx
        txt: data.cell_txt
    ).success ->
      data.cell_text = ""
      $scope.load()


  $scope.load()

