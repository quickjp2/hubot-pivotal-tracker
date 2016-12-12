// Description
//   A module to enable interactions with pivotal tracker
//
// Configuration:
//   TRACKER_PROEJCT_ID - Your tracker project id
//   TRACKER_API_TOKEN - API token for hubot to use
//
// Commands:
//   hubot create a story titled <title> - creates a new story in the icebox
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
  var pivotalTrackerUrl = "https://www.pivotaltracker.com/services/v5/";
  var TRACKER_PROJECT_ID = process.env.TRACKER_PROJECT_ID;
  var TRACKER_API_TOKEN = process.env.TRACKER_API_TOKEN;

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
      var tracker_user_id = robot.brain.get('TrackerID'+msg.message.user.id)
      data = JSON.stringify({
        current_state:'unstarted',
        estimate:1,
        name:name
      })
      return robot.http(pivotalTrackerUrl + "projects/" + TRACKER_PROJECT_ID + "/stories")
        .header('Content-Type', 'application/json')
        .header('Accept', 'application/json')
        .post(data)(function(err, res, body) {
          if (err){
            robot.emit('error', err);
          } else {
            return msg.res("story created with id:" + body.id + "! Check it out at " + body.url+"!");
          }
        });
    });
  }
}).call(this);
