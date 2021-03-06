# Description
#   A module to enable interactions with pivotal tracker
#
# Configuration:
#   TRACKER_URL - The url to the API version desired
#
# Commands:
#   hubot set my pt project to id:<PT_project_id> - Associates the slack user with a PT project
#   hubot what is my pt project id? - Retrieves the pt project id you are set to use (DM)
#   hubot what is my pt token? - Retrieves the api token hubot has on file for you (DM)
#   hubot set my pt api token to:<API Token> - Associates the slack user with a API token
#   hubot create me a story titled <title> - creates a new story
#   hubot create me a story that's labeled <label1(, label 2...)> titled <title> - creates a new story with labels
#   hubot create story project <project_id> labeled <label1(, label 2...)> titled <title> - full create story
#   hubot what stories are undelivered this week - lists all stories (FUTURE)
#   hubot <start|finish|deliver|accept|reject> story <story_id> - sets the story state
#   hubot add me as owner to story <story_id> - add yourself as a story owner
#   hubot fetch my pt id - send you your pt id (DM)
#   hubot show me my stories! - lists the stories assigned to you (DM)
#   hubot show me my projects - lists the projects you are apart of
#   hubot show epics in project <project_id> - Lists the epics in a project
#   hubot show labels in project <project_id> - Lists the labels in a project
#   hubot add me to pt project id:<PT_team_id> using token:<API_Token> - Associates the user with both a team and token
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

createStory = (robot, msg, token, title, project, labels = null) ->
  data = {
    current_state: 'unstarted',
    estimate: 1,
    name: title
    }
  if labels?
    data['labels'] = labels
  robot.logger.debug(data)
  url = "#{pivotalTrackerUrl}projects/#{project}/stories"
  robot.logger.debug(url)
  robot.http(url)
    .header('Content-Type', 'application/json')
    .header('X-TrackerToken', token)
    .post(JSON.stringify(data)) (err, res, body) ->
      if err
        robot.logger.error err
      else
        response = JSON.parse body
        robot.logger.debug body
        msg.reply "story created with id:" + response['id'] +
          "! Check it out at " + response['url'] + "!"

module.exports = (robot) ->
  robot.respond /hello/i, (msg) ->
    msg.reply "hello!"

  robot.hear /orly/i, (msg) ->
    msg.send "yarly"

# Log my PT user ID
  robot.respond /fetch my pt id/i, (msg) ->
    token = robot.brain.get 'TrackerToken' + msg.message.user.id
    slackUserID = msg.message.user.id
    if token == null
      robot.send { room: msg.message.user.id }, "well this is awkward...you don't have a token set yet..."
    else
      robot.http(pivotalTrackerUrl + "me")
        .header('Content-Type', 'application/json')
        .header('X-TrackerToken', token)
        .get() (err, res, body) ->
          if err
            robot.logger.debug err
          else
            response = JSON.parse body
            robot.logger.debug body
            PTUserID = response['id']
            robot.brain.set('TrackerID' + slackUserID, PTUserID)
            robot.send { room: msg.message.user.id }, "Your ID is set to "+
              robot.brain.get('TrackerID' + slackUserID, PTUserID)
# Get and set your PT api token
  robot.respond /what is my pt token?/i, (msg) ->
    tracker_user_token = robot.brain.get 'TrackerToken' + msg.message.user.id
    robot.send { room: msg.message.user.id }, "Using " + tracker_user_token + " as your token..."

  robot.respond /set my pt api token to:\s?(\w+)/i, (msg) ->
    token = msg.match[1]
    slackUserID = msg.message.user.id
    robot.brain.set 'TrackerToken' + slackUserID, token
    robot.http(pivotalTrackerUrl + "me")
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          PTUserID = response['id']
          robot.brain.set('TrackerID' + slackUserID, PTUserID)
          robot.send { room: slackUserID }, "I have set your token to "+
            robot.brain.get('TrackerToken' + slackUserID) + ". Your PT ID is " +
            robot.brain.get('TrackerID' + slackUserID)

# Get and set your PT Project ID
  robot.respond /what is my pt project id?/i, (msg) ->
    tracker_projectID = robot.brain.get 'TrackerProjectID' + msg.message.user.id
    robot.send { room: msg.message.user.id }, "Using #{tracker_projectID} as your pt project..."

  robot.respond /set my pt project to id:(\d+)/i, (msg) ->
    projectID = msg.match[1]
    slackUserID = msg.message.user.id
    robot.brain.set 'TrackerProjectID' + slackUserID, projectID
    robot.send { room: slackUserID }, "I have set your pt project to " +
      robot.brain.get 'TrackerProjectID' + slackUserID

# One liners for the win!
  robot.respond /add me to pt project id:\s?(\w+) using token:\s?(\w+)/i, (msg) ->
    tracker_projectID = msg.match[1]
    token = msg.match[2]
    slackUserID = msg.message.user.id
    robot.brain.set 'TrackerProjectID' + slackUserID, tracker_projectID
    robot.brain.set 'TrackerToken' + slackUserID, token
    robot.http(pivotalTrackerUrl + "me")
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          PTUserID = response['id']
          robot.brain.set('TrackerID' + slackUserID, PTUserID)
          robot.send { room: slackUserID }, "I have set your token to " +
            robot.brain.get('TrackerToken' + msg.message.user.id) + ". Welcome to pt project " +
            robot.brain.get('TrackerProjectID' + msg.message.user.id) + "! Your pt ID is " +
            robot.brain.get('TrackerID' + msg.message.user.id)

  robot.respond /add me as owner to story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    owners = []
    owners.push(robot.brain.get('TrackerID' + slackUserID))
    url = "#{pivotalTrackerUrl}stories/#{storyID}"
    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          owners.push.apply(owners, response['owner_ids'])
          data = JSON.stringify { owner_ids: owners }
          robot.http(url)
            .header('Content-Type', 'application/json')
            .header('X-TrackerToken', token)
            .put(data) (err, res, body) ->
              if err
                robot.logger.debug err
              else
                response = JSON.parse body
                robot.logger.debug body
                msg.reply "you are now an owner for story #{response['id']}"

# Oh the stories!!!!
  robot.respond /start story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    owners = []
    owners.push(robot.brain.get('TrackerID' + slackUserID))
    data = JSON.stringify { current_state: 'started', owner_ids: owners }
    url = "#{pivotalTrackerUrl}stories/#{storyID}"
    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .put(data) (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story " + response['id'] + " is now " + response['current_state']
  robot.respond /finish story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    data = JSON.stringify { current_state: 'finished' }
    url = "#{pivotalTrackerUrl}stories/#{storyID}"
    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .put(data) (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story " + response['id'] + " is now " + response['current_state']

  robot.respond /deliver story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    data = JSON.stringify { current_state: 'delivered' }
    url = "#{pivotalTrackerUrl}stories/#{storyID}"

    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .put(data) (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story " + response['id'] + " is now " + response['current_state']
  robot.respond /accept story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    data = JSON.stringify { current_state: 'accepted' }
    url = "#{pivotalTrackerUrl}stories/#{storyID}"

    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .put(data) (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story #{response['id']} is now #{response['current_state']} :thumbs_up:"
  robot.respond /reject story (\d+)/i, (msg) ->
    storyID = msg.match[1]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    data = JSON.stringify { current_state: 'rejected' }
    url = "#{pivotalTrackerUrl}stories/#{storyID}"

    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .put(data) (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          msg.reply "story #{response['id']} is now #{response['current_state']} :thumbs_down:"
  # Let's comment!
  robot.respond /comment on story (\d+):\s?(.*)/ig, (msg) ->
    storyID = msg.match[1]
    comment = msg.match[2]
    slackUserID = msg.message.user.id
    tracker_projectID = robot.brain.get 'TrackerProjectID' + slackUserID
    token = robot.brain.get 'TrackerToken' + slackUserID
    data = JSON.stringify { text: comment }
    url = "#{pivotalTrackerUrl}stories/#{storyID}"
    robot.logger.debug url
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.debug err
        else
          response = JSON.parse body
          robot.logger.debug body
          commentUrl = "#{pivotalTrackerUrl}projects/#{response['project_id']}/stories/#{storyID}/comments"
          # msg.send "Sending comment to url: #{commentUrl}"
          robot.http(commentUrl)
            .header('Content-Type', 'application/json')
            .header('X-TrackerToken', token)
            .post(data) (err, res, body) ->
              if err
                robot.logger.debug err
              else
                response = JSON.parse body
                robot.logger.debug body
                msg.send "Comment added with ID: #{response['id']}"

  # Give points to stories
  robot.respond /(\d) points for story (\d*)/, (msg) ->
    points = parseFloat(msg.match[1], 10)
    storyID = msg.match[2]
    slackUserID = msg.message.user.id
    projectID = ""
    token = robot.brain.get 'TrackerToken' + slackUserID
    data = JSON.stringify { estimate: points }
    point_scale = []
    # Get story's project
    url = "#{pivotalTrackerUrl}stories/#{storyID}"
    robot.http(url)
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.debug err
          msg.reply "Unable to locate the story's project..."
          return
        else
          response1 = JSON.parse body
          projectID = response1['project_id']
          robot.logger.debug body
          # Get that project's point scale
          robot.http("#{pivotalTrackerUrl}projects/#{projectID}")
            .header('X-TrackerToken', token)
            .get() (err, res, body) ->
              if err
                robot.logger.debug err
                msg.reply "Unable to locate the project's point scale..."
                return
              else
                response2 = JSON.parse body
                robot.logger.debug body
                # Check points against scale
                # msg.reply "#{response['point_scale'].split(',')}"
                for point in response2['point_scale'].split(',')
	                point_scale.push parseFloat(point, 10 )
                unless points in point_scale
                  msg.reply "Potter, thats not in #{response2['point_scale']}"
                  return
                # Update points of story
                robot.http("#{pivotalTrackerUrl}projects/#{projectID}/stories/#{storyID}")
                  .header('X-TrackerToken', token)
                  .header('Content-Type', 'application/json')
                  .put(data) (err, res, body) ->
                    if err
                      robot.logger.debug err
                      msg.reply "Unable to update the story..."
                      return
                    else
                      response3 = JSON.parse body
                      robot.logger.debug body
                      msg.reply "#{response3['estimate']} points given to #{response3['id']}"

  # Use provided labels with default project
  robot.respond /create[mea\s]*story[tha's\s]+labeled (.*\w*) titled (.*\w*)/i, (msg) ->
    name = msg.match[2]
    labels = msg.match[1].split ", "
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    project = robot.brain.get 'TrackerProjectID' + slackUserID
    createStory robot, msg, token, name, project, labels

  # Use provided project, label(s) and title
  robot.respond /create[mea\s]*story[in\s]+project (\d+)[tha's\s]+labeled (.*\w*) titled (.*\w*)/i, (msg) ->
    name = msg.match[3]
    labels = msg.match[2].split ","
    project = msg.match[1]
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    createStory robot, msg, token, name, project, labels

  # Use default project with no labels
  robot.respond /create[mea\s]+story titled (.*\w*)/i, (msg) ->
    name = msg.match[1]
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    project = robot.brain.get 'TrackerProjectID' + slackUserID
    createStory robot, msg, token, name, project

  # Let's do something cool and output the stories
  robot.respond /show[mea\s]*my stories[!]?/i, (msg) ->
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    # tracker_projectID = robot.brain.get 'TrackerProjectID'+slackUserID
    # url = pivotalTrackerUrl+"projects/"+tracker_projectID+"/stories"
    my_stories = {}
    i = 1
    requests = 0
    robot.logger.debug "Vars: token:#{robot.brain.get('TrackerID'+slackUserID)}"
    robot.http(pivotalTrackerUrl + "me")
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.error err
        else
          me = JSON.parse body
          robot.logger.debug body
          for project in me['projects']
            requests++
            url = "#{pivotalTrackerUrl}projects/#{project['project_id']}/stories"
            robot.logger.debug(url)
            robot.http(url + "?date_format=millis&filter=current_state:unstarted,started,finished,delivered%20and%20owner:#{robot.brain.get('TrackerID'+slackUserID)}")
              .header('Content-Type', 'application/json')
              .header('X-TrackerToken', token)
              .get() (err, res, body) ->
                if err
                  robot.logger.error err
                else
                  requests--
                  stories = JSON.parse body
                  robot.logger.debug body
                  for story in stories
                    my_stories[i] = story['name'] +
                                    " - ID: #{story['id']}" +
                                    ", State: #{story['current_state']}" +
                                    ", Project: #{story['project_id']}"
                    i = i + 1
                  if requests == 0
                    robot.logger.debug my_stories
                    msg.send { room: slackUserID }, JSON.stringify(my_stories, null, 1)

  robot.respond /show[mea\s]*my projects/i, (msg) ->
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    my_projects = {}
    robot.http(pivotalTrackerUrl + "me")
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.error err
        else
          me = JSON.parse body
          robot.logger.debug body
          for project in me['projects']
            my_projects[project['project_name']] = project['project_id']
          robot.logger.debug my_projects
          msg.send { room: slackUserID }, JSON.stringify(my_projects, null, 1)

  robot.respond /show epics in project (.*)\??/i, (msg) ->
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    project = msg.match[1]
    my_epics = {}
    url = "#{pivotalTrackerUrl}projects/#{project}/epics"
    robot.logger.debug(url)
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.error err
        else
          epics = JSON.parse body
          robot.logger.debug body
          for epic in epics
            my_epics[epic['name']] = {}
            my_epics[epic['name']]['id'] = epic['id']
            my_epics[epic['name']]['label'] = epic['label']['name']
            my_epics[epic['name']]['url'] = epic['url']
          robot.logger.debug my_epics
          msg.send JSON.stringify(my_epics, null, 1)
  robot.respond /show labels in project (.*)\??/i, (msg) ->
    slackUserID = msg.message.user.id
    token = robot.brain.get 'TrackerToken' + slackUserID
    project = msg.match[1]
    my_labels = []
    url = "#{pivotalTrackerUrl}projects/#{project}/labels"
    robot.logger.debug(url)
    robot.http(url)
      .header('Content-Type', 'application/json')
      .header('X-TrackerToken', token)
      .get() (err, res, body) ->
        if err
          robot.logger.error err
        else
          labels = JSON.parse body
          robot.logger.debug body
          for label in labels
            my_labels.push label.name
          robot.logger.debug my_labels
          msg.send JSON.stringify(my_labels, null, 1)
