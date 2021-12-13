
// maboroshi.js


var Dice = (function() {

  "use strict";

  var self = this;

  var elt = null;

  // protected functions

  // public functions

  this.parse = function(s) {

    var s1 = '' + s;
    var a = [];

    while(s1.length > 0) {
      var m = s1.match(/^(\d*)d(\d+)(.*)$/);
      if ( ! m) break;
      var c = m[1]; c = (c === '') ? 1 : parseInt(m[1], 10);
      var d = parseInt(m[2], 10);
      a.push({ c: c, d: d });
      s1 = m[3];
    }

    return a;
  };

  this.roll = function(s) {
  };

  // done.

  return this;

}).apply({}); // end Dice

