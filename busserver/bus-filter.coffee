 
hashtags =
    east: ["startupbusnyc", "startupbuseast", "startupbusec"]
    south: ["startupbusfl"]
    midwest: ["startupbuschi"]
    mexico: ["startupbusmx","startupbusmexico"]

terms =
    east: ["new york", "nyc", "east coast"]
    south: ["florida", "south east"]
    midwest: ["chicago", "mid west", "midwest"]
    mexico: ["mexico"]
    west: ["west coast", " la "]

users =
    east: "startupbusnyc"
    south: "startupbusfl"
    midwest: "startupbuschi"
    mexico: "startupbusmx"


module.exports = class BusFilter

    createFilterStatement: (joiner) ->
        filterterms = ["startupbus","thestartupbus"]

        for key in Object.keys(hashtags)
            for term in hashtags[key]
                if filterterms.indexOf(term) == -1 then filterterms.push term

         for key in Object.keys(users)
                if filterterms.indexOf(term) == -1 then filterterms.push users[key]

        return filterterms.join(joiner)




    addUnique: (arr,val) ->
        if arr.indexOf(val) > -1 then return
        else arr.push(val)

    addAttributesToTweet: (tweet) =>
        tweet.bus = []

        screenNames = tweet.entities.user_mentions.map (m) -> m.screen_name.toLowerCase()
        hashes = tweet.entities.hashtags.map (m) -> m.text.toLowerCase()
        console.log tweet.user.screen_name, hashes


        for key in Object.keys(users)
            if tweet.user.screen_name.toLowerCase() == users[key]
                @addUnique tweet.bus, key
            else if tweet.in_reply_to_screen_name == users[key]
                @addUnique tweet.bus, key
            else if screenNames.indexOf(users[key]) > -1
                @addUnique tweet.bus, key

        for key in Object.keys(hashtags)
            for hashtag in hashtags[key]
                if hashes.indexOf(hashtag) > -1
                    @addUnique tweet.bus, key

        textLower = tweet.text.toLowerCase()

        for key in Object.keys(terms)
            for term in terms[key]
                if textLower.indexOf(term) > -1
                    @addUnique tweet.bus, key

        if tweet.bus.length == 0
            delete tweet.bus
        return tweet.bus && tweet.bus.length > 0