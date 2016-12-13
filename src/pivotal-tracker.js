// Description
//   A module to enable interactions with pivotal tracker
//
// Configuration:
//   TRACKER_PROEJCT_ID - Your tracker project id
//   TRACKER_URL - The url to the API version desired
//
// Commands:
//   hubot add me to pt using token:<API Token> - Associates the slack user with a API token
//   hubot create me a story titled <title> - creates a new story in the icebox
//   hubot what stories are undelivered this week - lists all stories
//   hubot start story <story_id> - starts the story
//   hubot finish story <story_id> - finishes the story
//
// Notes:
//   - Newly created stories are always placed in the backlog. This is forced by the Pivotal Tracker API
//
// Author:
//   JP Quicksall <john.quicksall1@t-mobile.com>
(function(){
// Package variables
  var http, https;

  http = require('http');
  https = require('https');

// Global Variables
  var pivotalTrackerUrl = process.env.TRACKER_URL;
  var TRACKER_PROJECT_ID = process.env.TRACKER_PROJECT_ID;

// hubot message functions
  module.exports = function(robot) {
// Example scripts
    robot.respond(/hello/, function(msg){
      return msg.reply("hello!");
    });
    robot.hear(/orly/, function(msg){
      return msg.send("yarly");
    });
// Create a story
    robot.respond(/create me[\sa]{1,3}story titled (.*\w*)/i, function(msg){
      var name = msg.match[1];
      var tracker_user_token = robot.brain.get('TrackerToken'+msg.message.user.id)
      data = JSON.stringify({
        current_state:'unstarted',
        estimate:1,
        name:name
      })
      robot.send({room: msg.envelope.user.id}, "Using "+tracker_user_token+" as your token...");
      var url = pivotalTrackerUrl + "projects/" + TRACKER_PROJECT_ID + "/stories"
      robot.logger.debug(url)
      return robot.http(url)
        .header('Content-Type', 'application/json')
        .header('X-TrackerToken',tracker_user_token)
        .post(data)(function(err, res, body) {
          if (err){
            robot.logger.error(err);
          } else {
            var response = JSON.parse(body);
            robot.logger.debug(body)
            return msg.reply("story created with id:" + response['id'] + "! Check it out at " + response['url']+"!");
          }
        });
    });
    robot.respond(/add me to pt using token:(.+)/i, function(msg){
      var token = msg.match[1];
      robot.brain.set('TrackerToken'+msg.message.user.id,token)
      return msg.reply("I have set your token to "+robot.brain.get('TrackerToken'+msg.message.user.id))
    });
  }
}).call(this);
