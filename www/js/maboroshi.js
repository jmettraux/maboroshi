
// maboroshi.js


//
// MaboStringParser
////////////////////////////////////////////////////////////////////////////////

var MaboStringParser = Jaabro.makeParser(function() {

  //
  // parse

  function pbstart(i) { return rex(null, i, /\{\s*/); }
  function pbend(i)   { return str(null, i, '}'); } // keep post space for sqs
  function colon(i) { return rex(null, i, /\s*:\s*/); }
  function qmark(i) { return rex(null, i, /\s*\?\s*/); }
  function semco(i) { return rex(null, i, /\s*;\s*/); }
  function atsig(i) { return rex(null, i, /\s*@\s*/); }
  function equal(i) { return rex(null, i, /\s*=(?!=)\s*/); }

  function parstart(i) { return rex(null, i, /\(\s*/); }
  function parend(i)   { return rex(null, i, /\)\s*/); }

  function nil(i) { return rex('nil', i, /nil|null/i); }
  function boo(i) { return rex('boo', i, /true|false/i); }
  function num(i) { return rex('num', i, /\d+/); }

  function sqstring(i) { return rex('sqs', i, /'([^']|\\')+'/); }
  function dqstring(i) { return rex('dqs', i, /"([^"]|\\")+"/); } // FIXME

  function tname(i) { return rex('tname', i, /[^;}]+/); } // FIXME
  function table(i) { return seq('table', i, atsig, tname); }

  function ddice(i) { return rex('ddice', i, /([dD]\d+)+/); }
  function cdice(i) { return rex('cdice', i, /\d+[dD]\d+/); }
  function dice(i) { return alt('dice', i, cdice, ddice); }

  //function par(i) { return seq('par', i, parstart, exps, parend); }
  function par(i) { return str('par', i, '()'); } // FIXME

  function val(i) {
    return alt(null, i,
      par, dice, vname, table, sqstring, dqstring, num, boo, nil); }

  function vname(i) { return rex('vname', i, /[a-zA-Z][a-zA-Z0-9_]*/); }

  function semod(i) { return rex('sop', i, /\s*%\s*/); }
  function seprd(i) { return rex('sop', i, /\s*[\*\/]\s*/); }
  function sesum(i) { return rex('sop', i, /\s*[+-]\s*/); }
  function selgt(i) { return rex('sop', i, /\s*(<=?|>=?)\s*/); }
  function seequ(i) { return rex('sop', i, /\s*===?\s*/); }
  function seand(i) { return rex('sop', i, /\s*&&\s*/); }
  function seorr(i) { return rex('sop', i, /\s*\|\|\s*/); }

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

  function _rewrite_void(t) {};

  function _rewrite_s(t) {
    return { t: t.name, s: t.string() }; }
  function _rewrite_st(t) {
    return { t: t.name, s: t.string().trim() }; }
  function _rewrite_sub(t) {
    return t.subgather().map(rewrite); }
  function _rewrite_nsub(t) {
    return { t: t.name, a: t.subgather().map(rewrite) }; }

  var rewrite_string = _rewrite_sub;

  function rewrite_exps(t) {
    return { t: 'exps', a: t.subgather().map(rewrite) }; }

  function rewrite_exp(t) {

    var a = t.subgather().map(rewrite);

    if (a.length === 1) return a[0];
    return { t: 'exp', a: a }; }

  var rewrite_heass = _rewrite_nsub;
  var rewrite_heter = _rewrite_nsub;

  function rewrite_table(t) {
    return { t: 'table', s: t.lookup('tname').string() }; }

  function rewrite_num(t) {
    return { t: 'num', n: parseInt(t.string(), 10) }; }

  var rewrite_sqs = _rewrite_s;
  var rewrite_vname = _rewrite_s;
  var rewrite_sop = _rewrite_st;

  function rewrite_cdice(t) {
    var m = t.string().match(/^(\d+)[dD](\d+)$/);
    return { t: 'dice', c: parseInt(m[1], 10), d: parseInt(m[2], 10) }; }

  function rewrite_ddice(t) {
    var ds = t.string()
      .split(/[dD]/)
      .slice(1)
      .map(function(e) { return parseInt(e, 10); });
    return { t: 'dice', ds: ds }; }

  function rewrite_dice(t) { return rewrite(t.children[0]); }

}); // end MaboStringParser


//
// MaboTableSet
////////////////////////////////////////////////////////////////////////////////

var MaboTableSet = (function() {

  "use strict";

  var self = this;

  // protected functions

  var random = function(max) {
    return 1 + Math.floor(Math.random() * (max - 1)); };

  var evals = {};

  evals.exps = function(set, n) {
    var r = null;
    n.a.forEach(function(nn) { r = evalNode(set, nn); });
    return r; };

  evals.sqs = function(set, n) {
    return n.s; };

  evals.table = async function(set, n) {
    var t = set.tables[n.s];
    if (t) return rollOnListTable(set, t);
    if ( ! n.s.match(/\.md/)) throw 'unknown table "' + n.s + '"';
    t = await MaboTableSet.make(n.s);
    return t.roll(); };

  evals.dice = function(set, n) {
    if (n.ds) {
      r = '';
      n.ds.forEach(function(d) { r = r + random(d); });
      return parseInt(r, 10);
    }
    var r = 0;
    for (var i = 0; i < n.c; i++) { r = r + random(n.d); }
    return r; };

  evals.num = function(set, n) {
    return n.n; }

  evals.sum = function(set, n) {
//clog('evals.sum', n);
    var mod = 1;
    var r = 0;
    for (var i = 0, l = n.a.length; i < l; i++) {
      var e = n.a[i];
      if (e.t === 'sop') mod = e.s === '+' ? 1 : -1;
      else r = r + mod * evalNode(set, e);
    }
    return r;
  };

  evals._op = function(set, n) {
    var op = n.a[1].s;
    if (op === '%') return evals.mod(set, n);
    if (op === '+' || op === '-') return evals.sum(set, n);
    if (op === '/' || op === '*') return evals.prd(set, n);
    if (op.match(/^>=?|<=?$/)) return evals.lgt(set, n);
    throw "evals. op " + op + " not implemented."; };

  evals._ass = function(set, n) {
    var l = n.a.length;
    var vnames = [];
    for (var i = 0; i < l; i++) {
      var nn = n.a[i]; if (nn.t !== 'heass') break;
      vnames.push(nn.a[0].s);
    }
    var val = evalNode(set, n.a[l - 1]);
    var root = set; while(root.parent) root = root.parent;
    vnames.forEach(function(vn) {
      if (vn.match(/^[A-Z][A-Z0-9_]*$/)) set.vars[vn] = val;
      else root.vars[vn] = val;
    });
    return val; };

  evals.exp = function(set, n) {
    if (n.a[0].t === 'heass') return evals._ass(set, n);
    return evals._op(set, n); };

  var evalNode = function(set, n) {

//clog('evalNode()', n);
    var ev = evals[n.t];
    if ( ! ev) throw "evals." + n.t + " not implemented.";
    return ev(set, n);
  };

  var evalString = async function(set, s) {

//clog('evalString()', s);
    var t = MaboStringParser.parse(s);
    if ( ! t) throw "failed to parse \"" + s + "\"";

    var a1 = [];
      //
    for (var i = 0, l = t.length; i < l; i++) {
      a1.push(await evalNode(set, t[i]));
    }

    return a1.join('');
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

      if (l.trimStart().startsWith('<!--')) return;

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
        var v = l.trimStart(); v = v === '|' ? '' : v;
        r.entries[i] = r.entries[i] + '\n' + v;
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
      if (section.type === 'h1' && ! r.main) r.main = section.name;
      r.tables[section.name] = parseMdExpand(section);
    });

    return r;
  };

  // public functions

  this.debugEval = function(s) {

    var t = MaboStringParser.parse(s);
    var h = arguments[1] || { vars: {} };

    return [ evalNode(h, t[0]), h ];
  };

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

