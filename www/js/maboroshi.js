
// maboroshi.js


var Dice = (function() {

  "use strict";

  var self = this;

  // protected functions

  var parseDice = function(s) {

    var m = s.match(/^\s*(\d*)d(\d+)(.*)$/);
    if ( ! m) return null;
    var c = m[1]; c = (c === '') ? 1 : parseInt(m[1], 10);
    var d = parseInt(m[2], 10);

    return [ { c: c, d: d }, m[m.length - 1] ];
  };

  var parseOperation = function(s) {

    var m = s.match(/^\s*([-+])\s*(.*)$/);
    if ( ! m) return null;

    return [ m[1], m[m.length - 1] ];
  };

  var parseNumber = function(s) {

    var m = s.match(/^\s*(-?\d+)\s*(.*)$/);
    if ( ! m) return null;

    return [ parseInt(m[1], 10), m[m.length - 1] ];
  };

  var random = function(max) {
    return 1 + Math.floor(Math.random() * (max - 1));
  };

  // public functions

  this.parse = function(s) {

    var s1 = '' + s;
    var a = [];

    while(s1.length > 0) {

      var r =
        parseDice(s1) || parseNumber(s1) || parseOperation(s1);
      if ( ! r) break;

      var l = a.slice(-1)[0];

      var r0 = r[0];
      if (typeof r0 === 'number' && r0 < 0 && typeof l !== 'string') {
        a.push('+');
      }
      a.push(r0);

      s1 = r[1];
    }

    return a;
  };

  this.roll = function(s) {

    var ds = self.parse(s);

    var a = []

    ds.forEach(function(e) {

      var r = e;

      if (typeof e === 'number') {
      }
      else if (typeof e === 'string') {
      }
      else {
        r = 0; for (var i = 0; i < e.c; i++) { r = r + random(e.d); }
      }

      a.push(r);
    });

    var r = null;
    var op = 'cat';

    a.forEach(function(e) {

      if (typeof e === 'number') {
        if (op === 'cat') {
          r = parseInt('' + (r || '') + e, 10);
        }
        else if (op === '+') {
          r = (r || 0) + e;
          op = 'cat';
        }
        else if (op === '-') {
          r = (r || 0) - e;
          op = 'cat';
        }
        else if (typeof op === 'string') {
          r = r || 0;
          if (op === '+') { r = r + e; }
          else { r = r - e; }
          op = 'cat';
        }
      }
      else if (typeof e === 'string') {
        op = e;
      }
    });

    return r;
  };

  // done.

  return this;

}).apply({}); // end Dice


var Table = (function() {

  "use strict";

  var self = this;

  // protected functions

  var tableFunctions = {

    roll: function() {
      clog(self);
      return 'nada'; },
  };

  var addFunctions = function(table) {

    return Object.assign(table, tableFunctions);
  };

  var parseMd = function(s) {

    var a = [];

    s
      .split(/\r\n|\r|\n/)
      .forEach(function(l) {
        var l = l.trim(); if (l.length < 1) return;
        var m = l.match(/^\d+\.\s+(.+)$/);
        if (m) { a.push(m[1]); }
        else { var la = a.slice(-1)[0]; if (la) a[a.length - 1] = la + ' ' + l; }
      });

    return { table: a };
  };

  // public functions

  this.doMake = function(uri, s) {

    return addFunctions(parseMd(s));
  };

  this.make = function(uri) {
    // TODO
  };

  // done.

  return this;

}).apply({}); // end Table

