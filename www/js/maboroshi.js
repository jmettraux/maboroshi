
// maboroshi.js


//
// MaboDice
////////////////////////////////////////////////////////////////////////////////

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


//
// MaboStringParser
////////////////////////////////////////////////////////////////////////////////

var MaboStringParser = Jaabro.makeParser(function() {

  //
  // parse

  function pbstart(i) { return rex(null, i, /\{\s*/); }
  function pbend(i)   { return str(null, i, '}'); } // keep post space for sqs
  function colon(i) { return str(null, i, ':'); }
  function qmark(i) { return str(null, i, '?'); }
  function semco(i) { return rex(null, i, /;\s*/); }
  function atsig(i) { return rex(null, i, /@\s*/); }

  function parstart(i) { return rex(null, i, /\(\s*/); }
  function parend(i)   { return rex(null, i, /\)\s*/); }

  function nil(i) { return rex('nil', i, /nil|null/i); }
  function boo(i) { return rex('boo', i, /true|false/i); }
  function num(i) { return rex('num', i, /\d+/); }

  function sqstring(i) { return rex('sqs', i, /'([^']|\\')+'/); }
  function dqstring(i) { return rex('dqs', i, /"([^"]|\\")+"/); } // FIXME

  function table(i) { return seq('table', i, atsig, vname); }

  function dice(i) { return rex('dice', i, /\d+[dD]\d+/); }

  //function par(i) { return seq('par', i, parstart, exps, parend); }
  function par(i) { return str('par', i, '()'); } // FIXME

  function val(i) {
    return alt(null, i,
      par, dice, vname, table, sqstring, dqstring, num, boo, nil); }

  function equal(i) { return rex('equ', i, /=/); }

  function vname(i) { return rex('vname', i, /[a-zA-Z][a-zA-Z0-9_]+/); }

  function semod(i) { return rex('sop', i, /%/); }
  function seprd(i) { return rex('sop', i, /[\*\/]/); }
  function sesum(i) { return rex('sop', i, /[+-]/); }
  function selgt(i) { return rex('sop', i, /<=?|>=?/); }
  function seequ(i) { return rex('sop', i, /===?/); }
  function seand(i) { return str('sop', i, '&&'); }
  function seorr(i) { return str('sop', i, '||'); }

  function heter(i) { return seq('heter', i, eorr, qmark, eorr, colon); }
  function heass(i) { return seq('heass', i, vname, equal); }

  function emod(i) { return jseq('exp', i, val, semod); }
  function eprd(i) { return jseq('exp', i, emod, seprd); }
  function esum(i) { return jseq('exp', i, eprd, sesum); }
  function elgt(i) { return jseq('exp', i, esum, selgt); }
  function eequ(i) { return jseq('exp', i, elgt, seequ); }
  function eand(i) { return jseq('exp', i, eequ, seand); }
  function eorr(i) { return jseq('exp', i, eand, seorr); }
  function eter(i) { return seq('exp', i, heter, '*', eorr); }
  function eass(i) { return seq('exp', i, heass, '*', eter); }

  var exp = eass;

  function pbracket(i) { return eseq('exps', i, pbstart, exp, semco, pbend); }

  function str(i) { return rex('sqs', i, /([^{]|\\{)+/); }

  function str_or_pbracket(i) { return alt(null, i, str, pbracket); }

  function string(i) { return seq('string', i, str_or_pbracket, '+'); }
  var root = string;

  //
  // rewrite

  function _rewrite_s(t) { return { t: t.name, s: t.string() }; }

  function rewrite_string(t) {
    return t.subgather().map(rewrite); }

  function rewrite_exps(t) {
    return { t: 'exps', a: t.subgather().map(rewrite) }; }

  function rewrite_exp(t) {
    var a = t.subgather().map(rewrite);
    if (a.length === 1) return a[0];
    return { t: 'exp', a: a }; }

  function rewrite_table(t) {
    return { t: 'table', s: t.lookup('vname').string() }; }

  var rewrite_sqs = _rewrite_s;
  var rewrite_dice = _rewrite_s;
}); // end MaboStringParser


//
// MaboTableSet
////////////////////////////////////////////////////////////////////////////////

var MaboTableSet = (function() {

  "use strict";

  var self = this;

  // protected functions

  //var random = function(max) {
  //  return 1 + Math.floor(Math.random() * (max - 1));
  //};

  var doEvalReference = async function(set, s) {

//clog('doEvalReference()', set, [ s ]);
    var t = set.tables[s];

    if (t) return rollOnListTable(set, t);

    if ( ! s.match(/\.md/)) throw 'unknown table "' + s + '"';

    t = await MaboTableSet.make(s);

    return t.roll();
  };

  var doEvalString = function(set, s) {

//clog('doEvalString()', s);
    if (s.slice(0, 1) === '@') {
      return doEvalReference(set, s.slice(1).trim());
    }

    var d = MaboDice.parse(s);
//clog('doEvalString()', 'd', d);
    if (d) return '' + MaboDice.roll(s);
  }

  var evalString = async function(set, s) {

//clog('evalString()', s);
    var a = [];
    var s1 = s;

    while (true) {
      var m = s1.match(/^(\{[^}]+\})(.*)$/s) || s1.match(/^([^{]+)(.*)$/s);
        // not the /s suffix to the regex!
      if ( ! m) break;
      a.push(m[1]); s1 = m[2];
    }

    var a1 = [];
      //
    for (var i = 0, l = a.length; i < l; i++) { // use a loop not a .map
      var e = a[i];
      var m = e.match(/^\{\s*(.+)\s*\}$/);
      if ( ! m) { a1.push(e); continue; }
      var e1 = await doEvalString(set, m[1]);
      a1.push(e1);
    }

    return a1.join('').replaceAll(/\n\|\n/g, '\n\n');
  };

  var rollOnListTable = function(set, table) {

//clog('rollOnListTable()', table);
    var i = Math.floor(Math.random() * table.entries.length);
    return evalString(set, table.entries[i]);
  };

  var tableSetFunctions = {

    roll: function() {
      var t = this.tables[this.main];
      if ( ! t) return "didn't find table \"" + this.main + '"';
//clog('roll()', t);
      if (t.type === 'string') return evalString(this, t.string);
      return rollOnListTable(this, t);
    }
  };

  var addFunctions = function(table) {

    for (var k in tableSetFunctions) {
      table[k] = tableSetFunctions[k].bind(table); }

    return table;
  };

  var parseMdSplit = function(s) {

    var r = [];
    var t = 'h1';
    var n = null;
    var a = [];
    var m = null;

    s.split(/\r\n|\r|\n/).forEach(function(l) {

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

    var ls = sct.lines.filter(function(l) { return l.trim().length > 0; });

    if ( ! ls.every(function(l) {
      return l.match(/^\d+\.\s+[^\s]/) || l.match(/^\s+[^\s]/); })
    ) return null;

    var m = null;
    var i = -1;
    var r = { name: sct.name, type: sct.type, l: 'ol', entries: [] };
    ls.forEach(function(l) {
      m = l.match(/^\d+\.\s+(.+)$/);
      if (m) { r.entries.push(m[1]); return; }
      m = l.match(/^\s+(.+)$/);
      i = r.entries.length - 1;
      r.entries[i] = r.entries[i] + ' ' + m[1];
    });
    return r;
  };

  var parseMdExpandUl = function(sct) {

//clog('parseMdExpandUl()', sct);
    var x = /^\*\s+(.+)$/;
    var ls = sct.lines.filter(function(l) { return l.trim().length > 0; });

    if ( ! (ls[0] || '').match(x)) return false;
    if ( ! ls.find(function(l) { return l.match(x); })) return false;

    var r = { name: sct.name, type: sct.type, l: 'ul', entries: [] };
    var m, s;

    ls.forEach(function(l) {
      m = l.match(x);
      if (m) {
        r.entries.push(m[1]);
      }
      else {
        var i = r.entries.length - 1;
        r.entries[i] = r.entries[i] + '\n' + l.trimStart();
      }
    });

    return r;
  };

  var parseMdExpandDl = function(sct) {

    var rangeKey = function(l) {
      var m = l.match(/^(\d+)\s*-\s*(\d+)/);
      return m ? (parseInt(m[2], 10) - parseInt(m[1], 10) + 1) : false;
    };
    var stringKey = function(l) {
      return l.match(/^[^:\s]/) ? 1 : false;
    };
    var colonValue = function(l) {
      var m = l.match(/^:\s+([^\s].+)$/);
      return m ? m[1] : false;
    };
    var spaceValue = function(l) {
      var m = l.match(/^\s+([^\s].+)$/);
      return m ? m[1] : false;
    };

    if ( ! sct.lines.find(colonValue)) return false;

    var r = { name: sct.name, type: sct.type, l: 'dl', entries: [] };

    var l, k, v, c, s;

    for (var i = 0, j = sct.lines.length; i < j; i++) {

      l = sct.lines[i];

      k = rangeKey(l) || stringKey(l);
      if (k) {
        if (c) for (var ii = 0; ii < c; ii++) r.entries.push(s);
        c = k;
        s = null;
        continue;
      }

      v = colonValue(l); if (v) { s = s ? s + '\n' + v : v; continue; }
      v = spaceValue(l); if (v) { s = s ? s + ' ' + v : v; continue; }

      return false; // not a <dl>
    }

    for (var ii = 0; ii < c; ii++) r.entries.push(s);

    return r;
  };

  var parseMdExpand = function(sct) {

    return(
      parseMdExpandOl(sct) ||
      parseMdExpandUl(sct) ||
      parseMdExpandDl(sct) ||
      parseMdExpandString(sct));
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

}).apply({}); // end MaboTableSet

