# hubot-pivotal-tracker

A module to enable interactions with pivotal tracker

See [`src/pivotal-tracker.coffee`](src/pivotal-tracker.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-pivotal-tracker --save`

Then add **hubot-pivotal-tracker** to your `external-scripts.json`:

```json
[
  "hubot-pivotal-tracker"
]
```

Ensure that `TRACKER_URL` is set in your environment.

## Chat set-up

Each person needs to set their API token and their PT project ID before hubot can send on their behalf. They can set each individually or at the same time. See the Commands section in the header comments in [`pivotal-tracker.coffee`](src/pivotal-tracker.coffee).

Once set up is done, you can enjoy chat access to Pivtoal Tracker!

## Sample interaction

```
'alice', '@hubot create me a story titled need to make something simple'
'hubot', '@alice story created with id:123456789! Check it out at https://www.pivotaltracker.com/story/show/123456789!'

'bob', '@hubot deliver story 123456789'
'hubot', '@bob story 123456789 is now delivered'
```

## NPM Module

https://www.npmjs.com/package/hubot-pivotal-tracker
