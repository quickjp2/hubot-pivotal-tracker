Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

helper = new Helper('../src/pivotal-tracker.js')
PROJECT_ID = 7654321
if process.env.PROJECT_ID
  PROJECT_ID = process.env.PROJECT_ID

process.env.TRACKER_PROJECT_ID = PROJECT_ID

describe 'pivotal-tracker', ->
  beforeEach ->
    nock.disableNetConnect()
    @room = helper.createRoom()
    @robot =
      respond: sinon.spy()

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  context "create a story", ->
    it 'sets an API token', ->
      @room.user.say('alice', '@hubot add me to pt using token:abcdefg123hijklmnop456789').then =>
        expect(@room.messages).to.eql [
          ['alice','@hubot add me to pt using token:abcdefg123hijklmnop456789']
          ['hubot','@alice I have set your token to abcdefg123hijklmnop456789']
        ]

    it 'responds to create a story', ->
      pt = nock('https://www.pivotaltracker.com/services/v5')
        .log(console.log)
        .matchHeader('X-TrackerToken','abcdefg123hijklmnop456789')
        .post('/projects/'+PROJECT_ID.toString()+'/stories',{current_state:'unstarted',estimate:1,name:'need to make something simple'})
        .reply(200,
          {kind:"story",
          id:123456789,
          project_id: PROJECT_ID,
          name:"need to make something simple",
          story_type:"feature",
          current_state:"unstarted",
          estimate:1,
          requested_by_id:1234567,
          owner_ids:[],
          labels:[],
          created_at:"2016-12-09T22:35:24Z",
          updated_at:"2016-12-09T22:35:24Z",
          url:"https://www.pivotaltracker.com/story/show/123456789"});
      @room.user.say('alice', '@hubot add me to pt using token:abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create me a story titled need to make something simple').then =>
          expect(@room.messages).to.eql [
            ['alice','@hubot add me to pt using token:abcdefg123hijklmnop456789']
            ['hubot','@alice I have set your token to abcdefg123hijklmnop456789']
            ['alice', '@hubot create me a story titled need to make something simple']
            ['hubot', 'Using abcdefg123hijklmnop456789 as your token...']
            ['hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!']
          ]

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
