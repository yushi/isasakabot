DigitalOcean = require 'do-wrapper'
key = process.env.HUBOT_VM_DIGITALOCEAN_TOKEN
api = new DigitalOcean key

droplet_name = 'vm-from-hubot'
droplet_img = 5141286 # ubuntu 14.04

module.exports = (robot) ->
  robot.respond /vm on/i, (msg) ->
    if process.env.HUBOT_VM_PERMITTED_USER != msg.message.user.name
      msg.send "#{msg.message.user.name} not permitted"
      return
    msg.send "ok"

    droplet_options =
      ssh_keys: []

    api.keysGetAll (err, resp)->
      if err
        console.log(err)
        msg.send err
        return

      for key in resp.ssh_keys
        console.log(key.name)
        droplet_options.ssh_keys.push(key.id)

      api.dropletsCreateNewDroplet droplet_name, "sgp1", "512mb", 5141286, droplet_options, (err, resp) ->
        if err
          console.log err
          msg.send err
          return

        console.log resp
        msg.send "#{resp.droplet.id} created"

  robot.respond /vm list/i, (msg) ->
    api.dropletsGetAll (err, resp)->
      if err
        msg.send err
        return
      console.log(resp)
      if resp.droplets.length == 0
        msg.send "no vm found"
        return
      for d in resp.droplets
        addr = ""
        for v4net in d.networks.v4
          if v4net.type == "public"
            addr = v4net.ip_address
            break

        msg.send "#{d.id}: #{d.name}(#{addr})"

  robot.respond /vm rm (\d+)/i, (msg) ->
    api.dropletsDeleteDroplet msg.match[1], (err)->
      if err
        console.log err
        msg.send err
        return
      msg.send "removed"

  robot.respond /vm help/i, (msg)->
    msg.send "on/list/rm <id>"
