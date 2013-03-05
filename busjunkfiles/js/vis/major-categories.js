// Generated by CoffeeScript 1.3.3
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["d3"], function(d3) {
    var MajorCategories;
    return MajorCategories = (function() {

      function MajorCategories(el) {
        this.el = el;
        this.tick = __bind(this.tick, this);

        this.draw = __bind(this.draw, this);

        this.createDefinitions = __bind(this.createDefinitions, this);

        this.setInitials = __bind(this.setInitials, this);

        this.receiveAddition = __bind(this.receiveAddition, this);

        this.svg = d3.select(this.el[0]).append("svg");
        this.resize();
      }

      MajorCategories.prototype.resize = function() {
        this.dimensions = {
          width: $(window).width(),
          height: $(window).height()
        };
        this.dimensions.center = {
          x: this.dimensions.width / 2,
          y: this.dimensions.height / 2
        };
        this.dimensions.height = this.dimensions.height * 0.8;
        this.smallestEdge = $(window).height();
        if ($(window).width() < this.smallestEdge) {
          return this.smallestEdge = $(window).width();
        }
      };

      MajorCategories.prototype.receiveAddition = function(newObj) {
        var doIt, img,
          _this = this;
        doIt = function(preventUpdate) {
          var existingTotal, img, node, _i, _j, _len, _len1, _ref, _ref1, _results;
          existingTotal = 1;
          _ref = _this.nodes;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            node = _ref[_i];
            existingTotal += Math.sqrt(node.count) / 2;
          }
          _this.chargedNodes = [];
          _ref1 = _this.nodes;
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            node = _ref1[_j];
            if (newObj.bus.indexOf(node.key) > -1) {
              if (!preventUpdate) {
                node.count = node.count + 1;
              }
              _this.chargedNodes.push(node);
              node.lastTweet = newObj;
              if (newObj.user) {
                img = newObj.user.profile_image_url.replace("_normal", "");
                node.img.attr("xlink:href", "/imgpassthrough?img=" + img);
              }
            }
            node.radius = (_this.smallestEdge / existingTotal) * ((Math.sqrt(node.count) / 2) * 0.6);
            node.tweetText.text(node.count + " tweets");
            node.labelText.style("font-size", node.radius / 5).attr("y", node.radius * 0.65);
            node.tweetText.style("font-size", node.radius / 9).attr("y", node.radius * 0.82);
            node.textBack.attr("r", node.radius * 2).attr("cy", node.radius * 2.3);
            node.clipCircle.attr("r", node.radius);
            node.borderCircle.attr("r", node.radius);
            _this.applyImageSize(node.img.attr("width"), node.img.attr("height"), node.radius, node.img);
            _this.force.charge(function(d) {
              if (_this.chargedNodes.indexOf(d) > -1) {
                return -Math.pow(d.radius, 2.0) * 1.5;
              } else {
                return -Math.pow(d.radius, 2.0) / 4;
              }
            });
            _this.charged = true;
            _results.push(_this.force.start());
          }
          return _results;
        };
        if (newObj.user) {
          img = newObj.user.profile_image_url.replace("_normal", "");
          return $("<img>").attr("src", "/imgpassthrough?img=" + img).load(function() {
            return doIt();
          });
        } else {
          return doIt(true);
        }
      };

      MajorCategories.prototype.setInitials = function(data) {
        var key, node, overallTotal, val, _i, _len, _ref;
        this.nodes = [];
        this.svg.selectAll("g").remove();
        overallTotal = 0;
        for (key in data) {
          val = data[key];
          overallTotal += Math.sqrt(val.count) / 2;
          this.nodes.push({
            key: key,
            count: val.count,
            lastTweet: val.lastTweet
          });
        }
        _ref = this.nodes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          node = _ref[_i];
          node.radius = (this.smallestEdge / overallTotal) * ((Math.sqrt(node.count) / 2) * 0.6);
        }
        this.createDefinitions();
        return this.draw();
      };

      MajorCategories.prototype.createDefinitions = function() {
        return this.defs = this.svg.append("defs");
      };

      MajorCategories.prototype.draw = function() {
        var self;
        this.force = d3.layout.force().size([$(window).width(), $(window).height()]).on("tick", this.tick).nodes(this.nodes).charge(function(d) {
          return -Math.pow(d.radius, 2.0) / 4;
        }).gravity(-0.01);
        self = this;
        this.baseG = this.svg.append("g").attr("id", "major-categories");
        this.groups = this.baseG.selectAll(".major").data(this.nodes).enter().append("g").each(function(d) {
          var circleClip, g, img,
            _this = this;
          g = d3.select(this);
          circleClip = self.defs.append("clipPath").attr("id", "circle_" + d.key);
          d.clipCircle = circleClip.append("circle").attr("r", d.radius);
          g.on("click", function(e) {
            return self.receiveAddition({
              bus: [d.key]
            });
          });
          img = d.lastTweet.user.profile_image_url.replace("_normal", "");
          return $("<img>").attr("src", "/imgpassthrough?img=" + img).load(function() {
            d.img = g.append("image").attr("xlink:href", "/imgpassthrough?img=" + img).attr("preserveAspectRatio", "defer none slice").style("clip-path", "url(#circle_" + d.key + ")");
            self.applyImageSize(this.width, this.height, d.radius, d.img);
            g.append("circle").attr("r", d.radius);
            d.borderCircle = g.append("circle").attr("r", d.radius).attr("class", "border");
            d.textBack = g.append("circle").attr("r", function(d) {
              return d.radius * 2;
            }).attr("cy", d.radius * 2.3).style("clip-path", "url(#circle_" + d.key + ")").style("fill", "rgba(0,0,0,0.8)");
            d.labelText = g.append("text").text(function(d) {
              return d.key;
            }).attr("text-anchor", "middle").style("font-size", function(d) {
              return d.radius / 5;
            }).attr("y", function(d) {
              return d.radius * 0.65;
            });
            return d.tweetText = g.append("text").text(function(d) {
              return d.count + " tweets";
            }).attr("text-anchor", "middle").style("font-size", function(d) {
              return d.radius / 9;
            }).attr("y", function(d) {
              return d.radius * 0.82;
            });
          });
        });
        return this.force.start();
      };

      MajorCategories.prototype.applyImageSize = function(width, height, radius, img) {
        var iheight, iwidth;
        iwidth = radius * 2;
        iheight = radius * 2;
        if (width < height) {
          iheight = iheight / (width / height);
        } else {
          iwidth = iwidth / (height / width);
        }
        return img.attr("width", iwidth).attr("height", iheight).attr("x", -radius).attr("y", -(iheight / 2));
      };

      MajorCategories.prototype.tick = function(e) {
        var _this = this;
        if (e.alpha < 0.09 && this.chargedNodes) {
          this.force.stop();
          this.force.charge(function(d) {
            return -Math.pow(d.radius, 2.0) / 4;
          });
          this.chargedNodes = null;
          this.force.start();
        }
        this.groups.attr("transform", function(d) {
          d.x = d.x + (_this.dimensions.center.x - d.x) * (0.1 + 0.02) * e.alpha;
          d.y = d.y + (_this.dimensions.center.y - d.y) * (0.1 + 0.02) * e.alpha;
          return "translate(" + d.x + "," + d.y + ")";
        });
        return this.groups.select("circle").attr("r", function(d) {
          return;
          if (d.isUpdated) {
            console.log("upd");
            return d.radius * 10;
          }
          return d.radius;
        });
      };

      return MajorCategories;

    })();
  });

}).call(this);
