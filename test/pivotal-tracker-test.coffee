Helper = require('hubot-test-helper')
chai = require 'chai'
nock = require 'nock'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

helper = new Helper('../src/pivotal-tracker.coffee')
PROJECT_ID = 7654321

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
    # beforeEach ->
    #     .get('/me')
    #     .reply(200,
    #       {api_token: "VadersToken",
    #       created_at: "2016-12-06T12:00:05Z",
    #       email: "vader@deathstar.mil",
    #       has_google_identity: false,
    #       id:101,
    #       initials: "DV",
    #       kind: "me",
    #       name: "Darth Vader",
    #       projects:[{
    #         kind: "membership_summary",
    #         id:108,
    #         project_id:98,
    #         project_name: "Learn About the Force",
    #         project_color: "8100ea",
    #         favorite:false,
    #         role: "owner",
    #         last_viewed_at: "2016-12-06T12:00:00Z"
    #       },
    #       {
    #         kind: "membership_summary",
    #         id:101,
    #         project_id:99,
    #         project_name: "Death Star",
    #         project_color: "8100ea",
    #         favorite:false,
    #         role: "member",
    #         last_viewed_at: "2016-12-06T12:00:00Z"
    #       }
    #       ],
    #       receives_in_app_notifications: true,
    #       time_zone:{
    #         kind: "time_zone",
    #         olson_name: "America/Los_Angeles",
    #         offset: "-08:00"
    #       },
    #       updated_at: "2016-12-06T12:00:10Z",
    #       username: "vader"})
    it 'sets an API token', ->
      @room.user.say('alice', '@hubot set my pt api token to:abcdefg123hijklmnop456789').then =>
        expect(@room.messages).to.eql [
          ['alice','@hubot set my pt api token to:abcdefg123hijklmnop456789']
          ['hubot','I have set your token to abcdefg123hijklmnop456789. Your PT ID is 101']
        ]
    it 'remembers an API token', ->
      @room.user.say('alice', '@hubot set my pt api token to:abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot what is my pt token?').then =>
          expect(@room.messages).to.eql [
            ['alice','@hubot set my pt api token to:abcdefg123hijklmnop456789']
            ['hubot','I have set your token to abcdefg123hijklmnop456789. Your PT ID is 101']
            ['alice', '@hubot what is my pt token?']
            ['hubot', 'Using abcdefg123hijklmnop456789 as your token...']
          ]
    it 'sets a PT project ID', ->
      @room.user.say('alice', '@hubot set my pt project to id:7654321').then =>
        expect(@room.messages).to.eql [
          ['alice','@hubot set my pt project to id:7654321']
          ['hubot','I have set your pt project to 7654321']
        ]
    it 'remembers a PT project ID', ->
      @room.user.say('alice', '@hubot set my pt project to id:7654321').then =>
        @room.user.say('alice', '@hubot what is my pt project id?').then =>
          expect(@room.messages).to.eql [
            ['alice','@hubot set my pt project to id:7654321']
            ['hubot','I have set your pt project to 7654321']
            ['alice', '@hubot what is my pt project id?']
            ['hubot', 'Using 7654321 as your pt project...']
          ]
    it 'responds to create a story after adding a user', ->
      nock('https://www.pivotaltracker.com/services/v5')
        .matchHeader('X-TrackerToken','abcdefg123hijklmnop456789')
        .post('/projects/'+PROJECT_ID+'/stories',{current_state:'unstarted',estimate:1,name:'need to make something simple'})
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
          url:"https://www.pivotaltracker.com/story/show/123456789"})
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create me a story titled need to make something simple').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot create me a story titled need to make something simple']
            ['hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!']
          ]
  context "updates stories", ->
    it 'starts a story', ->
      storyID = 123456789
      storyState = 'started'
      nock('https://www.pivotaltracker.com/services/v5')
        #.matchHeader('X-TrackerToken','abcdefg123hijklmnop456789')
        .put('/projects/'+PROJECT_ID+'/stories/123456789',{current_state:"started"})
        .reply(200,
          {kind:"story",
          id:123456789,
          current_state:"started"})
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot start story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot start story 123456789']
            ['hubot', '@alice story 123456789 is now started']
          ]

    it 'delivers a story', ->
      storyID = 123456789
      storyState = 'delivered'
      nock('https://www.pivotaltracker.com/services/v5')
        .matchHeader('X-TrackerToken','abcdefg123hijklmnop456789')
        .put('/projects/'+PROJECT_ID+'/stories/'+storyID,{current_state:storyState})
        .reply(200,
          {kind:"story",
          id:storyID,
          current_state:storyState})
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot deliver story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot deliver story 123456789']
            ['hubot', '@alice story 123456789 is now delivered']
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
