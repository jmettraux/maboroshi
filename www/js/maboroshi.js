
// maboroshi.js


var MaboDice = (function() {

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

    return a.length < 1 ? null : a;
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


var MaboTableSet = (function() {

  "use strict";

  var self = this;

  // protected functions

  var tableFunctions = {

    roll: function() {
      clog(this);
      return 'nada'; },
  };

  var addFunctions = function(table) {

    for (var k in tableFunctions) {
      table[k] = tableFunctions[k].bind(table); }

    return table;
  };

  var parseMdSplit = function(s) {

    var r = [];
    var t = 'h1';
    var n = null;
    var a = [];
    var m = null;

    s.split(/\r\n|\r|\n/).forEach(function(l) {

      if (l.trim().length < 1) return;

      m = l.match(/^(#+)\s+(.+)$/);
      if (m) {
        if (n) { r.push({ name: n, type: t, lines: a }); n = null; a = []; }
        t = m[1].length > 1 ? 'h2' : 'h1'; n = m[2];
        return;
      }

      a.push(l);
    });
    r.push({ name: n, type: t, lines: a }); // over.

    return r;
  };

  var parseMdExpandString = function(sct) {
    return { type: 'string', string: sct.lines.join('\n') };
  };

  var parseMdExpandOl = function(sct) {
    var m = null;
    var i = -1;
    var r = { name: sct.name, type: sct.type, l: 'ol', entries: [] };
    sct.lines.forEach(function(l) {
      m = l.match(/^\d+\.\s+(.+)$/);
      if (m) { r.entries.push(m[1]); return; }
      m = l.match(/^\s+(.+)$/);
      i = r.entries.length - 1;
      r.entries[i] = r.entries[i] + ' ' + m[1];
    });
    return r;
  };

  var parseMdExpandDl = function(sct) {
    var r = { name: sct.name, type: sct.type, l: 'dl', entries: [] };
    var m, c; var s = '';
    sct.lines.forEach(function(l) {
      m = l.match(/^(\d+)\s*-\s*(\d+)/);
      if (m) {
        if (c) {
          s = s.trimStart();
          for (var i = 0; i < c; i++) { r.entries.push(s); };
          s = '';
        }
        var i = parseInt(m[1]); var j = parseInt(m[2]);
        c = j - (i - 1);
        return;
      }
      m = l.match(/^:\s+(.+)$/);
      if (m) {
        s = s + '\n' + m[1];
        return;
      }
      m = l.match(/^([^:\s].*)$/);
      if (m) {
        if (c) {
          s = s.trimStart();
          for (var i = 0; i < c; i++) { r.entries.push(s); };
          s = '';
        }
        c = 1;
        return;
      }
      s = s + ' ' + l.trimStart();
    });
    s = s.trimStart(); for (var i = 0; i < c; i++) r.entries.push(s);
    return r;
  };

  var isMdOl = function(l) {
    return l.match(/^\d+\.\s+[^\s]/) || l.match(/^\s+[^\s]/);
  };
  var isMdDl = function(l) {
    return l.match(/^[^\s]/) || l.match(/^:\s+[^\s]/) || l.match(/^\s+[^\s]+/);
  };

  var parseMdExpand = function(sct) {
    if (sct.lines.every(isMdOl)) return parseMdExpandOl(sct);
    if (sct.lines.every(isMdDl)) return parseMdExpandDl(sct);
    return parseMdExpandString(sct);
  };

  var parseMd = function(s) {

    var r = { main: null, tables: {} };
    parseMdSplit(s).forEach(function(section) {
      if (section.type === 'h1') r.main = section.name;
      r.tables[section.name] = parseMdExpand(section);
    });

    return r;
  };

  // public functions

  this.doMake = function(uri, s) {

    return addFunctions(parseMd(s));
  };

  this.make = async function(uri) {

    var res = await fetch(uri);

    if ( ! res.ok) {
      throw new Error(`HTTP ${res.status} ${res.statusText} for ${uri}`);
    }

    var s = await res.text();

    return self.doMake(uri, s);
  };

  // done.

  return this;

}).apply({}); // end Table

