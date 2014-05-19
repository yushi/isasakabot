# Description:
#   Notify informations
#

brain_key = 'events'

get_memo = (robot, name)->
  root = robot.brain.get(brain_key)
  return new EventMemo robot, name, {} unless root
  return new EventMemo robot, name, {} if name not in (key for key of root)
  return new EventMemo robot, name, root[name]

class EventMemo
  constructor: (@robot, @name, @data)->

  exists: ()->
    return (key for key of @data).length > 0

  update: ()->
    @robot.logger.info('update called for ', @name, @data)
    root = @robot.brain.get brain_key
    root = {} unless root
    root[@name] = @data
    @robot.brain.set brain_key, root
    @robot.brain.save()

  del: ()->
    @robot.logger.info('del called for ', @name, @data)
    root = @robot.brain.get brain_key
    return unless root
    delete root[@name]
    @robot.brain.set brain_key, root
    @robot.brain.save()

  owner: (owner)->
    @data.owner = owner if owner
    @data.owner

  header: (h)->
    @data.header = h
    @data.header

  users: (u)->
    @data.users = u
    @data.users

  add_column: (name) ->
    @data.header.push name
    for username, val of @data.users
      val.push ''

  add_user: (name) ->
    val = ('' for _ in @data.header)
    @robot.logger.info @data.header, val
    @data.users[name] = val

  edit_header: (idx, txt) ->
    @data.header[idx] = txt

  edit_cell: (name, idx, txt) ->
    @data.users[name][idx] = txt

module.exports = (robot) ->
  robot.respond /event add ([^ ]*) ?(.*)/, (msg) ->
    event_name = msg.match[1]
    users = {}
    if msg.match[2]
      for user in msg.match[2].split(/\s+/)
        users[user] = []
    owner = msg.message.user.name

    memo = get_memo robot, event_name

    if memo.exists()
      msg.reply "sorry #{event_name} already exists."
      return

    memo.owner owner
    memo.header []
    memo.users users
    memo.update()
    url = "#{process.env.HEROKU_URL}/isasaka/event.html#?event=#{event_name}"
    msg.reply url

  robot.respond /event del ([^ ]*)/, (msg) ->
    event_name = msg.match[1]
    user = msg.message.user.name

    memo = get_memo robot, event_name

    unless memo.exists()
      msg.reply "event #{event_name} not found."
      return

    if memo.owner() != user
      msg.reply "you are not #{memo.owner()}. ignored."
      return

    memo.del()
    msg.reply "#{event_name} removed."

  robot.router.get '/hubot/event/:name', (req, res) ->
    event_name = req.params.name

    memo = get_memo robot, event_name
    res.send(JSON.stringify(memo.data))
    return

  robot.router.post '/hubot/event/:name', (req, res) ->
    event_name = req.params.name
    memo = get_memo robot, event_name

    switch req.body.type
      when 'add_column'
        column = req.body.data
        memo.add_column column
        memo.update()
        res.send 200
      when 'add_user'
        name = req.body.data
        memo.add_user name
        memo.update()
        res.send 200
      when 'edit_header'
        idx = req.body.data.idx
        txt = req.body.data.txt
        memo.edit_header idx, txt
        memo.update()
        res.send 200
      when 'edit_cell'
        name = req.body.data.name
        idx = req.body.data.idx
        txt = req.body.data.txt
        memo.edit_cell name, idx, txt
        memo.update()
        res.send 200
