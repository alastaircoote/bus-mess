BusFilter = require "./bus-filter"
Mongo = require "mongodb"
Twitter = require "mtwitter"

twit = new Twitter
    consumer_key: 'b2NpJdJ2tICkD33bzozMiQ'
    consumer_secret: 'MlezhSQJpnqGR4fgkdSrO7LwtY9SVRbZDG4T2l9gg'
    access_token_key: '18059424-AWIsDEeiS1THQKjDScM8iFv6lcaMZsrHzyjoycoQ'
    access_token_secret: 'MbpWbqIR6pPW4mEcDXKV3lPgv3fOcJaRgdFdY7Bc8k'

coll = null
busF = new BusFilter()

doGrab = (lastId) ->
    opts =  {count:100}
    if lastId then opts.max_id = lastId
    twit.search busF.createFilterStatement(" OR "), opts, (err, data) ->
        if lastId then data.statuses = data.statuses[1..]
        data.statuses.forEach (t) ->
            t._id = t.id_str
            busF.addAttributesToTweet(t)
        coll.insert data.statuses,{}, (err,docs) ->
            console.log err
            console.log data.statuses[data.statuses.length-1].created_at
            doGrab(data.statuses[data.statuses.length-1].id_str)



client = new Mongo.Db "bustweets", new Mongo.Server("127.0.0.1",27017), {safe:true}
client.open (err, pcli) =>
    pcli.collection "tweets", (err, c) =>
        coll = c
        doGrab()



