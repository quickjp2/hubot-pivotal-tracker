// Description
//   A module to enable interactions with pivotal tracker
//
// Configuration:
//   TRACKER_PROEJCT_ID - Your tracker project id
//   TRACKER_URL - The url to the API version desired
//
// Commands:
//   hubot set my pt team to id:<PT_team_id> - Associates the slack user with a PT team
//   hubot what is my pt team id? - Retrieves the pt team id you are set to use (DM)
//   hubot what is my pt token? - Retrieves the api token hubot has on file for you (DM)
//   hubot set my pt api token to:<API Token> - Associates the slack user with a API token
//   hubot create me a story titled <title> - creates a new story in the icebox
//   hubot what stories are undelivered this week - lists all stories (FUTURE)
//   hubot start story <story_id> - starts the story
//   hubot deliver story <story_id> - finishes the story
//   hubot add me to pt team id:<PT_team_id> using token:<API_Token> - Associates the user with both a team and token
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
      // robot.send({room: msg.envelope.user.id}, "Using "+tracker_user_token+" as your token...");
      var url = pivotalTrackerUrl + "projects/" + robot.brain.get('TrackerTeamID'+msg.message.user.id) + "/stories"
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
    robot.respond(/start story (\d+)/i, function(msg){
      var storyID = msg.match[1];
      var tracker_user_token = robot.brain.get('TrackerToken'+msg.message.user.id)
      data = JSON.stringify({
        current_state:'started'
      })
      // robot.send({room: msg.envelope.user.id}, "Using "+tracker_user_token+" as your token...");
      var url = pivotalTrackerUrl + "projects/" + robot.brain.get('TrackerTeamID'+msg.message.user.id) +
        "/stories/" + storyID
      robot.logger.debug(url)
      return robot.http(url)
        .header('Content-Type', 'application/json')
        .header('X-TrackerToken',tracker_user_token)
        .put(data)(function(err, res, body) {
          if (err){
            robot.logger.error(err);
          } else {
            var response = JSON.parse(body);
            robot.logger.debug(body)
            return msg.reply("story " + response['id'] + "is now "+response['current_state']+"!");
          }
        });
    });
    robot.respond(/deliver story (\d+)/i, function(msg){
      var storyID = msg.match[1];
      var tracker_user_token = robot.brain.get('TrackerToken'+msg.message.user.id)
      data = JSON.stringify({
        current_state:'delivered'
      })
      // robot.send({room: msg.envelope.user.id}, "Using "+tracker_user_token+" as your token...");
      var url = pivotalTrackerUrl + "projects/" + robot.brain.get('TrackerTeamID'+msg.message.user.id) +
        "/stories/" + storyID
      robot.logger.debug(url)
      return robot.http(url)
        .header('Content-Type', 'application/json')
        .header('X-TrackerToken',tracker_user_token)
        .put(data)(function(err, res, body) {
          if (err){
            robot.logger.error(err);
          } else {
            var response = JSON.parse(body);
            robot.logger.debug(body)
            return msg.reply("story " + response['id'] + "is now "+response['current_state']+"!");
          }
        });
    });
    robot.respond(/add me to pt team id:\s?(\w+) using token:\s?(\w+)/i, function(msg){
      var ptid = msg.match[1];
      var token = msg.match[2];
      robot.brain.set('TrackerTeamID'+msg.message.user.id,ptid)
      robot.brain.set('TrackerToken'+msg.message.user.id,token)
      // return robot.http(pivotalTrackerUrl+"me")
      //   .header('Content-Type', 'application/json')
      //   .header('X-TrackerToken',token)
      //   .get()(function(err,res,body){
      //     if (err){
      //       robot.logger.error(err);
      //     } else {
      //       var response = JSON.parse(body);
      //       robot.logger.debug(body);
      //       if ( ptid == null){
      //         robot.logger.debug("Check 1..."+response['id']);
      //         PTUserID = response['id'];
      //         robot.brain.set('TrackerID'+slackUserID,PTUserID)
      //       } else {
      //         for (project of repsonse['projects']){
      //           if (project['project_id'] == trackerTeamID){
      //             robot.logger.debug("Check 2..."+response['id']);
      //             PTUserID = response['id'];
      //             robot.brain.set('TrackerID'+slackUserID,PTUserID)
      //           }
      //         }
      //         robot.logger.debug("Check 3..."+response['id']);
      //         PTUserID = response['id'];
      //         robot.brain.set('TrackerID'+slackUserID,PTUserID)
      //       }
      //   }.then(function(){
      //     robot.send({room: msg.envelope.user.id}, "I have set your token to "+
      //       robot.brain.get('TrackerToken'+msg.message.user.id)+". Welcome to PT team "+
      //       robot.brain.get('TrackerTeamID'+msg.message.user.id)+"! Your PT ID is "+
      //       robot.brain.get('TrackerID'+msg.message.user.id));
      //   )}});
    });
    robot.respond(/set my pt api token to:\s?(.+)/i, function(msg){
      var token = msg.match[1];
      var slackUserID = msg.message.user.id;
      var PTUserID;
      var trackerTeamID = robot.brain.get('TrackerTeamID'+slackUserID);
      robot.brain.set('TrackerToken'+slackUserID,token);
      robot.http(pivotalTrackerUrl+"me")
        .header('Content-Type', 'application/json')
        .header('X-TrackerToken',token)
        .get()(function(err, res, body) {
          if (err){
            robot.logger.error(err);
          } else {
            var response = JSON.parse(body);
            robot.logger.debug(body);
            if ( trackerTeamID == null){
              robot.logger.debug("Check 1..."+response['id']);
              PTUserID = response['id'];
              robot.brain.set('TrackerID'+slackUserID,PTUserID)
              return robot.send({room: slackUserID}, "I have set your token to "+
                robot.brain.get('TrackerToken'+slackUserID)+". Your PT ID is "+
                robot.brain.get('TrackerID'+slackUserID));
            } else {
              for (project of repsonse['projects']){
                if (project['project_id'] == trackerTeamID){
                  robot.logger.debug("Check 2..."+response['id']);
                  PTUserID = response['id'];
                  robot.brain.set('TrackerID'+slackUserID,PTUserID)
                  return robot.send({room: slackUserID}, "I have set your token to "+
                    robot.brain.get('TrackerToken'+slackUserID)+". Your PT ID is "+
                    robot.brain.get('TrackerID'+slackUserID));
                }
              }
              robot.logger.debug("Check 3..."+response['id']);
              PTUserID = response['id'];
              robot.brain.set('TrackerID'+slackUserID,PTUserID)
              return robot.send({room: slackUserID}, "I have set your token to "+
                robot.brain.get('TrackerToken'+slackUserID)+". Your PT ID is "+
                robot.brain.get('TrackerID'+slackUserID));
            }
          }
        });
    });
    robot.respond(/what is my pt token?/i, function(msg){
      var tracker_user_token = robot.brain.get('TrackerToken'+msg.message.user.id)
      return robot.send({room: msg.envelope.user.id}, "Using "+tracker_user_token+" as your team id...");
    });
    robot.respond(/what is my pt project id?/i, function(msg){
      var tracker_user_token = robot.brain.get('TrackerTeamID'+msg.message.user.id)
      return robot.send({room: msg.envelope.user.id}, "Using "+tracker_user_token+" as your token...");
    });
    robot.respond(/set my pt project to id:(\d+)/i, function(msg){
      var token = msg.match[1];
      robot.brain.set('TrackerTeamID'+msg.message.user.id,token)
      return robot.send({room: msg.envelope.user.id}, "I have set your pt project to "+robot.brain.get('TrackerTeamID'+msg.message.user.id));
    });
  }
  var fetchPTUserID = function(robot, slackUserID) {
    var trackerTeamID = robot.brain.get('TrackerTeamID'+slackUserID);
    var trackerToken = robot.brain.get('TrackerToken'+slackUserID);
    if ( trackerToken == null){
      return null;
    } else {
      robot.logger.debug(pivotalTrackerUrl)
      return robot.http(pivotalTrackerUrl+"me")
        .header('Content-Type', 'application/json')
        .header('X-TrackerToken',trackerToken)
        .get()(function(err, res, body) {
          if (err){
            robot.logger.error(err);
          } else {
            var response = JSON.parse(body);
            robot.logger.debug(body);
            if ( trackerTeamID == null){
              robot.logger.debug(response['id']);
              return (response['id']);
            } else {
              // for (project of repsonse['projects']){
              //   if (project['project_id'] == trackerTeamID){
              //     return project['id'];
              //   }
              // }
              robot.logger.debug(response['id']);
              return (response['id']);
            }
          }
        });
    }
  };
}).call(this);
