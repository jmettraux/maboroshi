
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
      var m = s1.match(/^(\d+)d(\d+)(.*)$/);
      if ( ! m) break;
      a.push({ c: parseInt(m[1], 10), d: parseInt(m[2], 10) });
      s1 = m[3];
    }

    return a;
  };

  this.roll = function(s) {
  };

  // done.

  return this;

}).apply({}); // end Dice

