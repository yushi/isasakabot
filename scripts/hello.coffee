# Description:
#   Test command to develop hubot script
#
# Commands:
#   hubot hello - ユーザー名とともにhelloメッセージを出力します
#   hubot reg <keywords> <message> - 反応するメッセージを登録します
#   hubot unreg <message> - 反応するメッセージを削除します
#   hubot list keywords - 反応するキーワードを出力します
#   hubot list msg <keywords> - 指定キーワードに対してのメッセージを出力します
module.exports = (robot) ->
  robot.respond /hello/i, (msg) ->
    msg.send "こんにちわ #{msg.message.user.name} さん!"

  robot.hear /(.*)/i, (msg) ->
    if not /^hubot/.test(msg.match[1])
      for key of robot.brain.data._private
        result = msg.match[1].match(key)

        if result
          # messages = robot.brain.data[key]
          messages = robot.brain.get(key)
          rnd = Math.floor Math.random() * messages.length
          msg.send messages[rnd]

#    key = msg.match[1]
#    if robot.brain.data[key]
#      messages = robot.brain.data[key]
#
#      rnd = Math.floor Math.random() * messages.length
#      msg.send messages[rnd]

  robot.respond /reg (.*) (.*)/i, (msg) ->
    key = msg.match[1]
 
    if not robot.brain.get(key)
      robot.brain.set(key, [])
 
    # robot.brain.data[key].push(msg.match[2])
    robot.brain.get(key).push(msg.match[2])
    robot.brain.save()
 
    msg.send "\"#{key}\" に \"#{msg.match[2]}\" を登録しました"

  robot.respond /unreg (.*)/i, (msg) ->
    for key of robot.brain.data._private
      if msg.match[1] in robot.brain.get(key)
        robot.brain.get(key).pop(msg.match[1])
        msg.send "\"#{key}\" から \"#{msg.match[1]}\" を削除しました"

      elise if robot.brain.get(key).length == 0
        robot.brain.remove(key)

      robot.brain.save()

  robot.respond /list keywords/i, (msg) ->
    msg.send "\"#{Object.keys(robot.brain.data._private)}\""

  robot.respond /list msg (.*)/i, (msg) ->
    msg.send "\"#{robot.brain.get(msg.match[1])}\""
