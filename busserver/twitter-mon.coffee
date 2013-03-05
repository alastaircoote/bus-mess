Twitter = require "mtwitter"
Mongo = require "mongodb"

twit = new Twitter
    consumer_key: 'b2NpJdJ2tICkD33bzozMiQ'
    consumer_secret: 'MlezhSQJpnqGR4fgkdSrO7LwtY9SVRbZDG4T2l9gg'
    access_token_key: '18059424-AWIsDEeiS1THQKjDScM8iFv6lcaMZsrHzyjoycoQ'
    access_token_secret: 'MbpWbqIR6pPW4mEcDXKV3lPgv3fOcJaRgdFdY7Bc8k'


module.exports = class Monitor

    constructor: () ->
    
    filter: (@terms) =>
        console.log "Filtering for #{terms}..."
        @setTwitterStream()

    setTwitterStream: () =>
        twit.stream "statuses/filter", {track: @terms}, (@twitterStream) =>
            @twitterStream.on "error", (err) ->
                console.log err
                throw err
            @twitterStream.on "data", (data) =>
                if @streamAlter 
                    toInsert = @streamAlter(data)
                    #console.log toInsert.bus || "none"
                    #if !toInsert then return

                data._id = data.id_str
                @mongoCollection.insert data, (err, docs) ->
                    if err then console.log err
                    else console.log "Tweet saved"

