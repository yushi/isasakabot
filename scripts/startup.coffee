# Description:
#   Say startup message
#

module.exports = (robot) ->
  ch = process.env.HUBOT_STARTUP_CHANNEL
  msg = process.env.HUBOT_STARTUP_MESSAGE
  robot.messageRoom ch, msg if ch and msg
