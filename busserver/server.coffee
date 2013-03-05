TwitterMonitor = require "./twitter-mon"
BusFilter = require "./bus-filter"
Mongo = require "mongodb"

async = require "async"
express = require "express"
app = express()
server = require("http").createServer(app)
io = require("socket.io").listen(server).set("log level", 2)
url = require "url"
http = require "http"

app.use(express.static(__dirname+"/../busjunkfiles"))

app.get "/imgpassthrough", (req,res) ->
    parsed = url.parse(req.query.img)
    get = http.request parsed, (remRes) ->
        remRes.pipe(res,{end:true})

    req.pipe(get,{end:true})



server.listen(4545)
return

monitor = new TwitterMonitor()

initials = {}

grabInitialFigures = (coll) ->

    async.each ["east","west","mexico","south","midwest"], (key,cb) ->
        initials[key] = {}
        cursor = coll.find({bus:key}, {limit:1}).sort({id:-1})
        cursor.count (err,count) ->
            initials[key].count = count
            cursor.toArray (err,docs) ->
                initials[key].lastTweet = docs[0]
                cb()
    , (err) ->
        io.sockets.on "connection", (socket) ->
            socket.emit "initialData", initials



client = new Mongo.Db "bustweets", new Mongo.Server("127.0.0.1",27017), {safe:true}
client.open (err, pcli) =>
    pcli.collection "tweets", (err, coll) =>
        #@mongoCollection = coll
        monitor.mongoCollection = coll
        grabInitialFigures(coll)

busF = new BusFilter()



monitor.streamAlter = (data) ->
    pass = busF.addAttributesToTweet(data)
    if !pass then return

    if data.bus
        for key in data.bus
            initials[key].count++
            initials[key].lastTweet = data

    io.sockets.emit "tweet", data

monitor.filter(busF.createFilterStatement(","))


