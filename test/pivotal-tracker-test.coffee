Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'

expect = chai.expect

helper = new Helper('../src/pivotal-tracker.js')

describe 'pivotal-tracker', ->
  beforeEach ->
    nock.disableNetConnect()
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  context "create a story", ->

  context "example tests", ->
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
