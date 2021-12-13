
// maboroshi.js


var Dice = (function() {

  "use strict";

  var self = this;

  var elt = null;

  // protected functions

  var parseDice = function(s) {

    var m = s.match(/^\s*(\d*)d(\d+)(.*)$/);
    if ( ! m) return null;
    var c = m[1]; c = (c === '') ? 1 : parseInt(m[1], 10);
    var d = parseInt(m[2], 10);

    return [ { c: c, d: d }, m[m.length - 1] ];
  };

  var parseOperation = function(s) {

    var m = s.match(/^\s*(\+)\s*(.*)$/);
    if ( ! m) return null;

    return [ m[1], m[m.length - 1] ];
  };

  var parseNumber = function(s) {

    var m = s.match(/^\s*(\d+)\s*(.*)$/);
    if ( ! m) return null;

    return [ parseInt(m[1], 10), m[m.length - 1] ];
  };

  // public functions

  this.parse = function(s) {

    var s1 = '' + s;
    var a = [];

    while(s1.length > 0) {

      var r = parseDice(s1) || parseOperation(s1) || parseNumber(s1);
      if ( ! r) break;

      a.push(r[0]);
      s1 = r[1];
    }

    return a;
  };

  this.roll = function(s) {
  };

  // done.

  return this;

}).apply({}); // end Dice

