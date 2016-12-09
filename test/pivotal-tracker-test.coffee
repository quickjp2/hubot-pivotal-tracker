Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/pivotal-tracker.coffee')

describe 'pivotal-tracker', ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  it 'responds to hello', ->
    @room.user.say('alice', '@hubot hello').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot hello']
        ['hubot', '@alice hello!']
      ]

  it 'hears orly', ->
    @room.user.say('bob', 'just wanted to say orly').then =>
      expect(@room.messages).to.eql [
        ['bob', 'just wanted to say orly']
        ['hubot', 'yarly']
      ]

#  it 'answers what stories need to be deleived this week', ->
#    expect(@robot.respond).to.have.been.calledWith(//)
