requirejs.config
    shim:
        "d3":
            exports: "d3"
    paths:
        "d3":"//d3js.org/d3.v3.min"
        "jquery": "//code.jquery.com/jquery-1.9.1.min"
        "socket.io": "/socket.io/socket.io"

require ["d3","vis/major-categories", "jquery", "socket.io"], (d3, MajorCategories, $, io) ->
    majors = new MajorCategories $("#svg-holder")

    socket = io.connect "/"

    socket.on "tweet", (data) ->
        majors.receiveAddition(data)

    socket.on "initialData", (data) ->
        majors.setInitials(data)
       