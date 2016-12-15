# Description
#   A module to enable interactions with pivotal tracker
#
# Configuration:
#   TRACKER_PROEJCT_ID - Your tracker project id
#   TRACKER_URL - The url to the API version desired
#
# Commands:
#   hubot set my pt team to id:<PT_team_id> - Associates the slack user with a PT team
#   hubot what is my pt team id? - Retrieves the pt team id you are set to use (DM)
#   hubot what is my pt token? - Retrieves the api token hubot has on file for you (DM)
#   hubot set my pt api token to:<API Token> - Associates the slack user with a API token
#   hubot create me a story titled <title> - creates a new story in the icebox
#   hubot what stories are undelivered this week - lists all stories (FUTURE)
#   hubot start story <story_id> - starts the story
#   hubot deliver story <story_id> - finishes the story
#   hubot add me to pt team id:<PT_team_id> using token:<API_Token> - Associates the user with both a team and token
#
# Notes:
#   - Newly created stories are always placed in the backlog. This is forced by the Pivotal Tracker API
#
# Author:
#   JP Quicksall <john.quicksall1@t-mobile.com>\
http = require 'http'
https = require 'https'

# Global Variables
pivotalTrackerUrl = process.env.TRACKER_URL

module.exports = (robot) ->
  robot.respond /hello/i, (msg) ->
    msg.reply "hello!"

  robot.hear /orly/i, (msg) ->
    msg.send "yarly"

# Get and set your PT api token
  robot.respond /what is my pt token?/i, (msg) ->
    tracker_user_token = robot.brain.get 'TrackerToken'+msg.message.user.id
    robot.send {room: msg.message.user.id}, "Using "+tracker_user_token+" as your token..."

  robot.respond /set my pt api token to:\s?(\w+)/i, (msg) ->
    token = msg.match[1]
    slackUserID = msg.message.user.id
    robot.brain.set 'TrackerToken'+slackUserID, token
    robot.send {room: slackUserID}, "I have set your token to "+
      robot.brain.get('TrackerToken'+slackUserID)+". Your PT ID is 101"# +
#       robot.brain.get('TrackerID'+slackUserID)

# Get and set your PT Project ID
  robot.respond /what is my pt project id?/i, (msg) ->
    tracker_projectID = robot.brain.get 'TrackerProjectID'+msg.message.user.id
    robot.send {room: msg.message.user.id}, "Using "+tracker_projectID+" as your pt project..."

  robot.respond /set my pt project to id:(\d+)/i, (msg) ->
    projectID = msg.match[1]
    slackUserID = msg.message.user.id
    robot.brain.set 'TrackerProjectID'+slackUserID, projectID
    robot.send {room: slackUserID}, "I have set your pt project to "+
      robot.brain.get 'TrackerProjectID'+slackUserID

# One liners for the win!
  robot.respond /add me to pt project id:\s?(\w+) using token:\s?(\w+)/i, (msg) ->
    tracker_projectID = msg.match[1]
    token = msg.match[2]
    slackUserID = msg.message.user.id
    robot.brain.set 'TrackerProjectID'+slackUserID, tracker_projectID
    robot.brain.set 'TrackerToken'+slackUserID, token
    robot.send {room: slackUserID}, "I have set your token to "+
      robot.brain.get('TrackerToken'+msg.message.user.id)+". Welcome to pt project "+
      robot.brain.get('TrackerProjectID'+msg.message.user.id)+"! Your pt ID is 101"#+
#      robot.brain.get('TrackerID'+msg.message.user.id)

# Oh the stories!!!!
  robot.respond /start story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID'+slackUserID
    token = robot.brain.get 'TrackerToken'+slackUserID
    data = JSON.stringify { current_state: 'started'}
    url = pivotalTrackerUrl+"projects/"+tracker_projectID+"/stories/"+storyID

    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken',token)
      .put(data) (err, res, body) ->
        if err
          robbot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story" + response['id'] + "is now "+ response['current_state']

  robot.respond /deliver story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID'+slackUserID
    token = robot.brain.get 'TrackerToken'+slackUserID
    data = JSON.stringify { current_state: 'delivered'}
    url = pivotalTrackerUrl+"projects/"+tracker_projectID+"/stories/"+storyID

    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken',token)
      .put(data) (err, res, body) ->
        if err
          robbot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story" + response['id'] + "is now "+ response['current_state']

  robot.respond /create me[\sa]{1,3}story titled (.*\w*)/i, (msg) ->
    name = msg.match[1]
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken'+slackUserID
    tracker_projectID = robot.brain.get 'TrackerProjectID'+slackUserID
    data = JSON.stringify {
      current_state: 'unstarted',
      estimate: 1,
      name: name
      }
    url = pivotalTrackerUrl+"projects/"+tracker_projectID+"/stories"
    robot.logger.debug(url)
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken',token)
      .post(data) (err, res, body) ->
        if err
          robot.logger.error err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story created with id:"+response['id']+
            "! Check it out at "+response['url']+"!"
