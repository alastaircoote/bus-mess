define ["d3"], (d3) ->
    class MajorCategories
        constructor: (@el) ->
            @svg = d3.select(@el[0]).append("svg")
            
            @resize()


        resize: () ->
            @dimensions =
                width: $(window).width()
                height: $(window).height()

            @dimensions.center = 
                x: @dimensions.width / 2
                y: @dimensions.height / 2

            @dimensions.height = @dimensions.height * 0.8

            @smallestEdge = $(window).height()
            if $(window).width() < @smallestEdge then @smallestEdge = $(window).width()


        receiveAddition: (newObj) =>
            doIt = (preventUpdate) =>
                existingTotal = 1
                for node in @nodes
                    existingTotal += Math.sqrt(node.count) /2

                @chargedNodes = []

                for node in @nodes
                    
                    if newObj.bus.indexOf(node.key) > -1
                        if !preventUpdate then node.count = node.count + 1
                        @chargedNodes.push(node)

                        if newObj.user
                            img = newObj.user.profile_image_url.replace("_normal","")
                            node.img.attr("xlink:href", "/imgpassthrough?img=#{img}")


                    node.radius = (@smallestEdge / existingTotal) * ((Math.sqrt(node.count) / 2) * 0.6)
                    
                    node.tweetText.text(node.count + " tweets")

                    node.labelText.style("font-size", node.radius / 5).attr("y", node.radius * 0.65)
                    node.tweetText.style("font-size", node.radius / 9).attr("y", node.radius * 0.82)
                    
                    node.textBack.attr("r", node.radius*2).attr("cy",node.radius*2.3)

                    node.clipCircle.attr "r", node.radius
                    node.borderCircle.attr "r", node.radius

                    @applyImageSize(node.img.attr("width"),node.img.attr("height"),node.radius,node.img)

                    @force.charge((d) => 
                        if @chargedNodes.indexOf(d) > -1 then return -Math.pow(d.radius, 2.0) * 1.5
                        else return -Math.pow(d.radius, 2.0)/4)
                    @charged = true

                    @force.start()

            if newObj.user

                img = newObj.user.profile_image_url.replace("_normal","")
                
                $("<img>").attr("src","/imgpassthrough?img=#{img}").load () ->
                    doIt()

            else doIt(true)


        setInitials:(data) =>
            @nodes = []
            @svg.selectAll("g").remove()
            overallTotal = 0

            for key, val of data
                overallTotal += Math.sqrt(val.count) / 2
                @nodes.push
                    key: key
                    count: val.count
                    lastTweet: val.lastTweet
                    #radius: val.count

            for node in @nodes
                node.radius = (@smallestEdge / overallTotal) * ((Math.sqrt(node.count) / 2) * 0.6)

            @createDefinitions()


            @draw()

        createDefinitions: () =>
            @defs = @svg.append("defs")




        draw: () =>

        
            @force = d3.layout.force()
              .size([$(window).width(),$(window).height()])
              .on("tick",@tick)
              #.on("tick", (e) =>
              #  @groups.attr "transform", (d) -> "translate(" +  d.x + "," + d.y + ")")
              .nodes(@nodes)
              .charge((d) -> -Math.pow(d.radius, 2.0) / 4)
              .gravity(-0.01)


            self = this
            @baseG = @svg.append("g").attr("id","major-categories")
            #@onResize()

            @groups = @baseG.selectAll(".major")
                .data(@nodes)
                .enter()
                .append("g")
                
                #.attr("fill",(d) -> "url(#bg_#{d.key})")
                .each (d) ->

                    g = d3.select(this)


                    circleClip = self.defs.append("clipPath")
                        .attr("id", "circle_#{d.key}")

                    d.clipCircle = circleClip.append("circle")
                        .attr("r", d.radius)

                    g.on "click", (e) =>
                        self.receiveAddition({bus:[d.key]})
                
                    img = d.lastTweet.user.profile_image_url.replace("_normal","")
                
                    $("<img>").attr("src","/imgpassthrough?img=#{img}").load () ->
                        d.img = g.append("image")
                            .attr("xlink:href", "/imgpassthrough?img=#{img}")
                            .attr("preserveAspectRatio","defer none slice")
                            .style("clip-path", "url(#circle_#{d.key})")


                        self.applyImageSize(this.width,this.height,d.radius,d.img)


                        g.append("circle")
                            .attr("r", d.radius)
                            #.attr("class","border")

                        d.borderCircle = g.append("circle")
                            .attr("r", d.radius)
                            .attr("class","border")
                       
                        d.textBack = g.append("circle")
                            .attr("r", (d) -> d.radius*2)
                            #.attr("x",0)
                            .attr("cy",d.radius*2.3)
                            .style("clip-path", "url(#circle_#{d.key})")
                            .style("fill","rgba(0,0,0,0.8)")

                        d.labelText = g.append("text")
                            .text((d) -> d.key)
                            .attr("text-anchor","middle")
                            .style("font-size", (d) -> d.radius / 5)
                            .attr("y", (d) -> d.radius * 0.65)
                    
                        d.tweetText = g.append("text")
                            .text((d) -> d.count + " tweets")
                            .attr("text-anchor","middle")
                            .style("font-size", (d) -> d.radius / 9)
                            .attr("y",(d) ->d.radius * 0.82)


                    #self.createCircle(d,g)
  
            @force.start()


        applyImageSize: (width,height,radius,img) ->
            iwidth = radius * 2
            iheight = radius * 2

            if width < height
                iheight = iheight / (width/height)
            else
                iwidth = iwidth / (height/width)

            img.attr("width",iwidth)
                .attr("height",iheight)
                .attr("x",-radius)
                .attr("y",-(iheight/2))

        
        tick: (e) =>
           
            if e.alpha < 0.09 && @chargedNodes
                @force.stop()
                @force.charge((d) -> -Math.pow(d.radius, 2.0) / 4)
                @chargedNodes = null
                @force.start()

            @groups.attr "transform", (d) =>
                


                d.x = d.x + (@dimensions.center.x - d.x) * (0.1 +  0.02) * e.alpha
                d.y = d.y + (@dimensions.center.y - d.y) * (0.1 + 0.02) * e.alpha



                "translate(" +  d.x + "," + d.y + ")"

                
            @groups.select("circle").attr "r", (d) ->
                return
                if d.isUpdated 
                    console.log "upd"
                    return d.radius * 10
                return d.radius
                
       