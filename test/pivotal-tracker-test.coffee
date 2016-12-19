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
    nock('https://www.pivotaltracker.com/services/v5')
      .matchHeader('X-TrackerToken','abcdefg123hijklmnop456789')
      .get('/me')
      .reply(200,
        {api_token: "VadersToken",
        created_at: "2016-12-06T12:00:05Z",
        email: "vader@deathstar.mil",
        has_google_identity: false,
        id:101,
        initials: "DV",
        kind: "me",
        name: "Darth Vader",
        projects:[{
          kind: "membership_summary",
          id:108,
          project_id:98,
          project_name: "Learn About the Force",
          project_color: "8100ea",
          favorite:false,
          role: "owner",
          last_viewed_at: "2016-12-06T12:00:00Z"
        },
        {
          kind: "membership_summary",
          id:101,
          project_id:99,
          project_name: "Death Star",
          project_color: "8100ea",
          favorite:false,
          role: "member",
          last_viewed_at: "2016-12-06T12:00:00Z"
        }
        ],
        receives_in_app_notifications: true,
        time_zone:{
          kind: "time_zone",
          olson_name: "America/Los_Angeles",
          offset: "-08:00"
        },
        updated_at: "2016-12-06T12:00:10Z",
        username: "vader"})
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
      .put('/projects/'+PROJECT_ID+'/stories/123456789',{current_state:"started"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"started"})
      .put('/projects/'+PROJECT_ID+'/stories/123456789',{current_state:"delivered"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"delivered"})
      .get('/projects/'+PROJECT_ID+'/stories?date_format=millis&filter=current_state%3Aunstarted%2Cstarted%2Cfinished%2Cdelivered')
      .reply(200,
        [{kind:"story",
        id:123456789,
        name:"need to make something simple",
        current_state:"started",
        owner_ids:[101]},
        {kind:"story",
        id:123456781,
        name:"need to make something simple 2",
        current_state:"unstarted",
        owner_ids:[102]}])
    @room = helper.createRoom()
    @robot =
      respond: sinon.spy()

  afterEach ->
    @room.destroy()
    nock.cleanAll()

  context "sets pt environment", ->
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
    it 'tries to fetch the PT id for a user', ->
      @room.user.say('alice', '@hubot fetch my pt id').then =>
        expect(@room.messages).to.eql [
          ['alice', '@hubot fetch my pt id']
          ['hubot', 'well this is awkward...you don\'t have a token set yet...']
        ]
  context "interacts with stories", ->
    it 'responds to create a story after adding a user', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create me a story titled need to make something simple').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot create me a story titled need to make something simple']
            ['hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!']
          ]
    it 'starts a story', ->
      @room.user.say('alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot start story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot start story 123456789']
            ['hubot', '@alice story 123456789 is now started']
          ]
    it 'delivers a story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot deliver story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot deliver story 123456789']
            ['hubot', '@alice story 123456789 is now delivered']
          ]
    it 'shows you your stories', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot show me my stories!').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot show me my stories!']
            ['hubot', {"1": "need to make something simple: ID: 123456789, State: started"}]
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
