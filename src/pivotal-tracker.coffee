# Description
#   A module to enable interactions with pivotal tracker
#
# Configuration:
#   TRACKER_PROEJCT_ID - Your tracker project id
#   TRACKER_API_TOKEN - API token for hubot to use
#
# Commands:
#   hubot create a story titled <title> - creates a new story in the icebox
#   hubot what stories are undelivered this week - lists all stories
#   hubot start story <story_id> - starts the story
#   hubot finish story <story_id> - finishes the story
#
# Notes:
#   
#
# Author:
#   JP Quicksall <john.quicksall1@t-mobile.com>

module.exports = (robot) ->
  robot.respond /hello/, (res) ->
    res.reply "hello!"

  robot.hear /orly/, (res) ->
    res.send "yarly"
