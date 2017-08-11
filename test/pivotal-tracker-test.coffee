Helper = require('hubot-test-helper')
chai = require('chai')
nock = require('nock')
sinon = require('sinon')
chai.use = require('sinon-chai')

expect = chai.expect

helper = new Helper('../src/pivotal-tracker.coffee')
PROJECT_ID = 7654321

process.env.TRACKER_PROJECT_ID = PROJECT_ID
process.env.TRACKER_URL = 'https://www.pivotaltracker.com/services/v5/'

describe 'pivotal-tracker', ->
  room = null
  beforeEach ->
    nock.disableNetConnect()
    nock('https://www.pivotaltracker.com/services/v5')
      .matchHeader('X-TrackerToken','abcdefg123hijklmnop456789')
      .get('/me')
      .times(6)
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
          project_id:PROJECT_ID,
          project_name: "Learn About the Force",
          project_color: "8100ea",
          favorite:false,
          role: "owner",
          last_viewed_at: "2016-12-06T12:00:00Z"
        },
        {
          kind: "membership_summary",
          id:109,
          project_id:PROJECT_ID+1,
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
      .get('/projects/'+PROJECT_ID)
      .reply(200,
        {
          id: PROJECT_ID
          point_scale: "0,1,2,3",
          point_scale_is_custom: false
        })
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
      .post('/projects/'+PROJECT_ID+'/stories',{current_state:'unstarted',estimate:1,name:'need to make something simple',labels:['this is a test']})
      .times(2)
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
        labels:["this is a test"],
        created_at:"2016-12-09T22:35:24Z",
        updated_at:"2016-12-09T22:35:24Z",
        url:"https://www.pivotaltracker.com/story/show/123456789"})
      .put('/stories/123456789',{current_state:"started"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"started"})
      .put('/stories/123456789',{current_state:"delivered"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"delivered"})
      .put('/stories/123456789',{ owner_ids:[101]})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"delivered"})
      .get('/stories/123456789')
      .times(2)
      .reply(200,
        {kind:"story",
        id:123456789,
        project_id: PROJECT_ID,
        owner_ids: [],
        current_state:"delivered"})
      .put('/stories/123456789',{current_state:"finished"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"finished"})
      .put('/stories/123456789',{estimate: 2})
      .reply(200,
        {kind:"story",
        id:123456789,
        estimate: 2})
      .put('/stories/123456789',{current_state:"accepted"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"accepted"})
      .put('/stories/123456789',{current_state:"rejected"})
      .reply(200,
        {kind:"story",
        id:123456789,
        current_state:"rejected"})
      .get('/projects/'+PROJECT_ID+'/stories?date_format=millis&filter=current_state%3Aunstarted%2Cstarted%2Cfinished%2Cdelivered%20and%20owner%3A101')
      .times(3)
      .reply(200,
        [{kind:"story",
        id:123456789,
        project_id: PROJECT_ID,
        name:"need to make something simple",
        current_state:"started",
        owner_ids:[101]},
        {kind:"story",
        id:123456781,
        project_id: PROJECT_ID,
        name:"need to make something simple 2",
        current_state:"unstarted",
        owner_ids:[102]}])
      .get('/projects/7654322/stories?date_format=millis&filter=current_state%3Aunstarted%2Cstarted%2Cfinished%2Cdelivered%20and%20owner%3A101')
      .times(3)
      .reply(200,
        [{kind:"story",
        id:123456782,
        project_id: PROJECT_ID+1,
        name:"need to make something simple 3",
        current_state:"started",
        owner_ids:[101]},
        {kind:"story",
        id:123456783,
        project_id: PROJECT_ID+1,
        name:"need to make something simple 4",
        current_state:"unstarted",
        owner_ids:[102]}])
      .get('/projects/'+PROJECT_ID+'/epics')
      .times(1)
      .reply(200,
        [{
          id: 555,
          kind: "epic",
          created_at: "2017-05-09T12:00:00Z",
          updated_at: "2017-05-09T12:00:00Z",
          project_id: PROJECT_ID,
          name: "Sanitation",
          url: "http://localhost/epic/show/555",
          label: {
            id: 2017,
            project_id:PROJECT_ID,
            kind: "label",
            name: "sanitation",
            created_at: "2017-05-09T12:00:00Z",
            updated_at: "2017-05-09T12:00:00Z"
          }
        },
        {
          id: 8,
          kind: "epic",
          created_at: "2017-05-09T12:00:00Z",
          updated_at: "2017-05-09T12:00:00Z",
          project_id: PROJECT_ID,
          name: "Maintenance",
          url: "http://localhost/epic/show/8",
          label: {
            id: 2011,
            project_id: PROJECT_ID,
            kind: "label",
            name: "mnt",
            created_at: "2017-05-09T12:00:00Z",
            updated_at: "2017-05-09T12:00:00Z"
          }
        }])
      .get('/projects/' + PROJECT_ID + '/labels')
      .times(1)
      .reply(200,
        [{
          kind: "label",
          id: 2011,
          project_id: PROJECT_ID,
          name: "mnt",
          created_at: 1494331200000,
          updated_at: 1494331200000
        },{
          kind: "label",
          id: 2017,
          project_id: PROJECT_ID,
          name: "sanitation",
          created_at: 1494331200000,
          updated_at: 1494331200000
        }])
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
  context "interacts with stories and", ->
    it 'responds to default create story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create me a story titled need to make something simple').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot create me a story titled need to make something simple']
            ['hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!']
          ]
    it 'responds to partial create story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create story labeled this is a test titled need to make something simple').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot create story labeled this is a test titled need to make something simple']
            ['hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!']
          ]
    it 'responds to full create story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create story project 7654321 labeled this is a test titled need to make something simple').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot create story project 7654321 labeled this is a test titled need to make something simple']
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
    it 'adds an owner to a story', ->
      @room.user.say('alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot create me a story titled need to make something simple').then =>
          @room.user.say('alice', '@hubot add me as owner to story 123456789').then =>
            expect(@room.messages).to.eql [
              ['alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789']
              ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
              ['alice', '@hubot create me a story titled need to make something simple']
              ['hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!']
              ['alice', '@hubot add me as owner to story 123456789']
              ['hubot', '@alice you are now an owner for story 123456789']
            ]
    # it 'adds a seperate owner to a story', ->
    #   @room.user.say('alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789').then =>
    #     @room.user.say('alice', '@hubot add bob as owner story 123456789').then =>
    #       expect(@room.messages).to.eql [
    #         ['alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789']
    #         ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
    #         ['alice', '@hubot add bob as owner story 123456789']
    #         ['hubot', '@alice bob is now an owner for story 123456789']
    #       ]
    it 'finishes a story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot finish story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot finish story 123456789']
            ['hubot', '@alice story 123456789 is now finished']
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
    it 'accepts a story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot accept story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot accept story 123456789']
            ['hubot', '@alice story 123456789 is now accepted :thumbs_up:']
          ]
    it 'rejects a story', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot reject story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot reject story 123456789']
            ['hubot', '@alice story 123456789 is now rejected :thumbs_down:']
          ]
    it 'gives points to a story', ->
      @room.user.say('alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot 2 points for story 123456789').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id:7654321 using token:abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot 2 points for story 123456789']
            ['hubot', '@alice 2 points given to 123456789']
          ]
    it 'shows you your stories', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot show me my stories!').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot show me my stories!']
            ['hubot', {"room": "alice"}]
            ['hubot', '{\n \"1\": \"need to make something simple - ID: 123456789, State: started, Project: 7654321\",\n \"2\": \"need to make something simple 2 - ID: 123456781, State: unstarted, Project: 7654321\",\n \"3\": \"need to make something simple 3 - ID: 123456782, State: started, Project: 7654322\",\n \"4\": \"need to make something simple 4 - ID: 123456783, State: unstarted, Project: 7654322\"\n}']
          ]

  context "Extras!", ->
    it 'shows a list of projects you are apart of', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot show me my projects').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot show me my projects']
            ['hubot', {"room": "alice"}]
            ['hubot', '{\n \"Learn About the Force\": 7654321,\n \"Death Star\": 7654322\n}']
          ]
    it 'shows a list of epics in a project', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot show epics in project 7654321').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot show epics in project 7654321']
            ['hubot', '{\n \"Sanitation\": {\n  "id": 555,\n  "label": "sanitation",\n  "url": "http://localhost/epic/show/555"\n },\n \"Maintenance\": {\n  "id": 8,\n  "label": "mnt",\n  "url": "http://localhost/epic/show/8"\n }\n\}']
          ]
    it 'shows the labels of project', ->
      @room.user.say('alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789').then =>
        @room.user.say('alice', '@hubot show labels in project 7654321').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot add me to pt project id: 7654321 using token: abcdefg123hijklmnop456789']
            ['hubot', 'I have set your token to abcdefg123hijklmnop456789. Welcome to pt project 7654321! Your pt ID is 101']
            ['alice', '@hubot show labels in project 7654321']
            ['hubot', '[\n \"mnt\",\n \"sanitation\"\n]']
          ]
  #   it 'responds to hello', ->
  #     @room.user.say('alice', '@hubot hello').then =>
  #       expect(@room.messages).to.eql [
  #         ['alice', '@hubot hello']
  #         ['hubot', '@alice hello!']
  #       ]

  #   it 'hears orly', ->
  #     @room.user.say('bob', 'just wanted to say orly').then =>
  #       expect(@room.messages).to.eql [
  #         ['bob', 'just wanted to say orly']
  #         ['hubot', 'yarly']
  #       ]

#  it 'answers what stories need to be deleived this week', ->
#    expect(@robot.respond).to.have.been.calledWith(//)
