# Description:
#   HORESASE DANSI
#
# Commands:
#   MISAWA <text>... - Search image url by <text>
#   MISAWA RELOAD - Reload database
http = require 'http'

data_url = 'http://horesase-boys.herokuapp.com/meigens.json'
data = []

update_db = ()->
  body = ''
  http.get data_url, (res)->
    if res.statusCode != 200
      return

    res.on 'data', (chunk)->
      body += chunk

    res.on 'end', ()->
      try
        data = JSON.parse(body)
      catch
        return

_all_matched = (re, list)->
  for i in list
    return true if i.match(re)
  return false

_search = (re, src)->
  matched = []
  for i in src
    targets = []
    targets.push(i['title']) if i['title']
    targets.push(i['body']) if i['body']
    targets.push(i['character']) if i['character']
    matched.push(i) if _all_matched(re, targets)
  return matched

search = (keywords)->
  all = data
  for kw in keywords
    all = _search(new RegExp(kw), all)
  return all

module.exports = (robot) ->
  robot.hear /^M(?:ISAWA)?$/i, (msg) ->
    entry = data[Math.floor(Math.random() * data.length)]
    if entry
      msg.send "#{entry.title} by #{entry.character}"
      msg.send entry.image
    else
      msg.send 'Sorry, Not found.'

  robot.hear /^M(?:ISAWA)? (.*)/i, (msg) ->
    matched = search(msg.match[1].split(' '))
    entry = matched[Math.floor(Math.random() * matched.length)]
    if entry
      msg.send "#{entry.title} by #{entry.character}"
      msg.send entry.image
    else
      msg.send 'Sorry, Not found.'

  robot.hear /^MISAWA RELOAD$/i, ()->
    update_db()

# initial load
update_db()
