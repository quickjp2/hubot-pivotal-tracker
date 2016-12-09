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

// hubot message functions
  module.exports = function(robot) {
    robot.respond(/hello/, function(msg){
      return msg.reply("hello!");
    });
    robot.hear(/orly/, function(msg){
      return msg.send("yarly");
    });
  }
}).call(this);
