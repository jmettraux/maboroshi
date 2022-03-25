
// maboroshi.js


//
// MaboStringParser
////////////////////////////////////////////////////////////////////////////////

var MaboStringParser = Jaabro.makeParser(function() {

  //
  // parse

  function colon(i) { return rex(null, i, /\s*:\s*/); }
  function qmark(i) { return rex(null, i, /\s*\?\s*/); }
  function semco(i) { return rex(null, i, /\s*;\s*/); }
  function atsig(i) { return rex(null, i, /\s*@\s*/); }
  function equal(i) { return rex(null, i, /\s*=(?!=)\s*/); }
  function dot(i) { return rex(null, i, /\s*\./); }

  function comma(i) { return rex(null, i, /\s*,\s*/); }

  function nil(i) { return rex('nil', i, /nil|null/i); }
  function boo(i) { return rex('boo', i, /true|false/i); }
  function num(i) { return rex('num', i, /-?\d+/); }
  function pos(i) { return rex('pos', i, /\d+/); }

  function ppbstart(i) { return rex(null, i, /\{\s*/); }
  function ppbend(i)   { return rex(null, i, /\s*\}\s*/); }

  function pbstart(i) { return rex(null, i, /\{[;\s]*/); }
  function pbend(i)   { return rex(null, i, /[;\s]*\}/); }

  function parstart(i) { return rex(null, i, /\s*\(\s*/); }
  function parend(i)   { return rex(null, i, /\s*\)\s*/); }

  var castart = parstart;
  var caend = parend; // for now...

  function sqstart(i) { return rex(null, i, /\[\s*/); }
  function sqend(i)   { return rex(null, i, /\s*\]\s*/); }

  function vname(i) { return rex('vname', i, /[a-zA-Z][a-zA-Z0-9_]*/); }

  function sqstring(i) { return rex('sqs', i, /'([^']|\\')+'/); }

  function dqstr(i) { return rex('dqstr', i, /(\\{|\\"|[^"{])+/); }
  function dqelt(i) { return alt(null, i, dqstr, pbracket); }
  function dqstart(i) { return rex(null, i, /\s*"/); }
  function dqend(i) { return rex(null, i, /"\s*/); }

  function dqstring(i) { return seq('dqs', i, dqstart, dqelt, '*', dqend); }

  function table(i) { return seq('table', i, atsig, exp); }

  function comexps(i)  { return jseq('comexps', i, exp, comma); }

  function coexp(i) { return seq(null, i, exp_qmark, colon); }
  function colexps(i) {return seq('colexps', i, coexp, '+', exp_qmark); }

  function scolexp(i) { return seq(null, i, exp_qmark, semco); }
  function scolexps(i) {return seq('scolexps', i, scolexp, '+', exp_qmark); }
  function scolexpz(i) {return jseq('scolexps', i, exp_qmark, semco); }

  function sqexps(i) { return alt(null, i, scolexps, colexps, comexps); }

  function num_or_vname(i) { return alt(null, i, num, vname); }

  function doidx(i) { return seq(null, i, dot, num_or_vname); }
  function caidx(i) { return seq(null, i, castart, comexps, caend); }
  function sqidx(i) { return seq(null, i, sqstart, sqexps, sqend); }

  function index(i) { return alt(null, i, sqidx, caidx, doidx); }

  function diced(i) { return rex(null, i, /[dD]/); }

  function pos_or_par(i) { return alt(null, i, pos, par); }

  function ddic(i) { return seq(null, i, diced, pos_or_par); }
  function ddice(i) { return rep('ddice', i, ddic, 1); }

  function dicekhl(i) { return rex('dicehkl', i, /k[hl]/i); }
  function dicek(i) { return seq('dicek', i, dicekhl, pos_or_par, '?'); }

  function cdice(i) {
    return seq('cdice', i, pos_or_par, diced, pos_or_par, dicek, '?'); }

  function dice(i) { return alt(null, i, cdice, ddice); }

  function dentry(i) { return seq('dentry', i, vname, colon, exp); }
  function dentry_qmark(i) { return rep(null, i, dentry, 0, 1); }

  function dict(i) {
    return eseq('dict', i,
      ppbstart, dentry_qmark, comma, ppbend); }

  function exp_qmark(i) { return rep(null, i, exp, 0, 1); }

  function list(i) { return eseq('list', i, sqstart, exp_qmark, comma, sqend); }

  function par(i) { return seq('par', i, parstart, scolexpz, parend); }

  function obj(i) { return alt(null, i, vname, par, list, dict); }
  function ocall(i) { return seq('ocall', i, obj, index, '*'); }

  function val(i) {
    return alt(null, i,
      dice, boo, nil, ocall, num, table, sqstring, dqstring); }

  function semod(i) { return rex('sop', i, /\s*%\s*/); }
  function seprd(i) { return rex('sop', i, /\s*[\*\/]\s*/); }
  function sesum(i) { return rex('sop', i, /\s*[+-]\s*/); }
  function selgt(i) { return rex('sop', i, /\s*(<=?|>=?)\s*/); }
  function seequ(i) { return rex('sop', i, /\s*===?\s*/); }
  function seand(i) { return rex('sop', i, /\s*&&\s*/); }
  function seorr(i) { return rex('sop', i, /\s*\|\|\s*/); }

  function heter(i) { return seq('heter', i, eorr, qmark, eorr, colon); }
  function heass(i) { return seq('heass', i, ocall, equal); }

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

  function str(i) { return rex('str', i, /([^{]|\\{)+/s); }

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
  function _rewrite_str(t) {
    return { t: 'str', s: t.string() }; }
  function _rewrite_sub(t) {
    return t.subgather().map(rewrite); }
  function _rewrite_nsub(t) {
    return { t: t.name, a: t.subgather().map(rewrite) }; }

  var rewrite_string = _rewrite_sub;

  var rewrite_comexps = _rewrite_nsub;
  var rewrite_colexps = _rewrite_nsub;
  var rewrite_scolexps = _rewrite_nsub;
  var rewrite_exps = _rewrite_nsub;

  function rewrite_par(t) {
    return { t: 'par', a: rewrite(t.sublookup('scolexps')).a }; };

  function rewrite_exp(t) {

    var a = t.subgather().map(rewrite);

    if (a.length === 1) return a[0];
    return { t: 'exp', a: a }; }

  var rewrite_heass = _rewrite_nsub;
  var rewrite_heter = _rewrite_nsub;

  var rewrite_table = _rewrite_nsub;

  function rewrite_num(t) {
    return { t: 'num', n: parseInt(t.string(), 10) }; }
  function rewrite_boo(t) {
    return { t: 'boo', b: t.string().toLowerCase() === 'true' }; }

  function rewrite_pos(t) {
    return { t: 'pos', n: parseInt(t.string(), 10) }; }

  var rewrite_dqstr = _rewrite_str;
  var rewrite_dqs = _rewrite_nsub;

  var rewrite_str = _rewrite_str;

  function rewrite_sqs(t) {
    return { t: 'str', s: t.string().slice(1, -1) }; }
  var rewrite_sop = _rewrite_st;
  var rewrite_vname = _rewrite_s;

  function rewrite_dicehkl(t) {
    return { t: 'dicehkl', s: t.string().toLowerCase() }; }

  var rewrite_dicek = _rewrite_nsub;

  function rewrite_cdice(t) {
    var a = t.subgather().map(rewrite);
    var a1 = a.slice(0, 2);
    if (a[2]) a1 = a1.concat(a[2].a);
    return { t: 'cdice', a: a1 };
  }

  var rewrite_ddice = _rewrite_nsub;

  var rewrite_ocall = _rewrite_nsub;

  var rewrite_list = _rewrite_nsub;

  var rewrite_dentry = _rewrite_sub;
  var rewrite_dict = _rewrite_nsub;

}); // end MaboStringParser


//
// MaboTableSet
////////////////////////////////////////////////////////////////////////////////

var MaboTableSet = (function() {

  "use strict";

  var self = this;

  // protected functions

  var alast = function(arr) { return arr.slice(-1)[0]; };
  var abody = function(arr) { return arr.slice(0, arr.length - 1); };

  var random = function(max) {
    return 1 + Math.floor(Math.random() * (max - 1)); };

  var evals = {};

  evals._getRoot = function(set) {
    return set.parent ? evals._getRoot(set.parent) : set.vars; };

  evals.dict = function(set, n) {
    return n.a.reduce(
      function(r, kv) {
        //var kn = kv[0]; var k = evalNode(set, kn);
        var k = kv[0].s;
        r[k] = evalNode(set, kv[1]);
        return r; },
      {}); };

  evals.list = function(set, n) {
    return n.a.map(function(nn) { return evalNode(set, nn); }); };

  evals._exps = function(set, n) {
    return {
      t: n.t,
      a: n.a.map(function(nn) { return evalNode(set, nn); }) }; };

  evals.comexps = evals._exps;
  evals.colexps = evals._exps;
  evals.scolexps = evals._exps;

  evals.exps = function(set, n) {
    var r = null;
    n.a.forEach(function(nn) { r = evalNode(set, nn); });
    return r; };
  evals.par = evals.exps;

  evals.str = function(set, n) {
    return n.s; };

  evals.dqs = function(set, n) {
    return n.a.map(function(nn) { return '' + evalNode(set, nn); }).join(''); };

  evals.vname = function(set, n) {
    if (n.s.match(/^[A-Z][A-Z0-9_]*$/)) {
      var root = set; while (root.parent) root = root.parent;
      return evals._getRoot(set).vars[n.s];
    }
    else {
      var s = set;
      while (true) {
        if (s.vars.hasOwnProperty(n.s)) return s.vars[n.s];
        s = s.parent; if ( ! s) break;
      }
      return null;
    }
  };

  var aviComexps = function(value, index) {
    if ((typeof value) === 'function') {
      return value.apply(null, index.a);
    }
    var i = index.a[0];
    if (i < 0) i = value.length + i;
    var l = index.a[1];
    if (Array.isArray(value) && l !== undefined) {
      if (l < 0) l = value.length + l;
      var a = []; for (i; i < l; i++) { a.push(value[i]); }
      return a;
    }
    return value[i];
  };
  var aviColexps = function(value, index) {
    var inc = index.a[2] || 1;
    var a = [];
    for (var i = index.a[0], l = i + index.a[1]; i < l; i = i + inc) {
      a.push(value[i]);
    }
    return a;
  };
  var aviScolexps = function(value, index) {
    return index.a.map(function(i) { return value[i]; });
  };
  var isT = function(t, o) {
    if (typeof o !== 'object') return false;
    if (o.t !== t) return false;
    return true;
  };
  var applyOcallIndex = function(value, index) {
    if (isT('comexps', index)) return aviComexps(value, index);
    if (isT('colexps', index)) return aviColexps(value, index);
    if (isT('scolexps', index)) return aviScolexps(value, index);
    return value;
  };

  var fetchString = function(n) {
    if (n.s) return n.s;
    var s = null;
    if (n.a) n.a.forEach(function(nn) { s = s || fetchString(nn); });
    return s;
  };

  evals.ocall = function(set, n) {
    return n.a
      .map(function(nn) { return evalNode(set, nn); })
      .reduce(function(r, i) { return applyOcallIndex(r, i); });
  };

  evals.table = async function(set, n) {
    var s = evalNode(set, n.a[0]) || fetchString(n);
    var t = set.tables[s];
    if (t) return rollOnListTable(set, t);
    if ( ! s.match(/\.md/)) throw 'unknown table "' + n.s + '"';
    t = await MaboTableSet.make(n.s);
    t.parent = set;
    return t.roll();
  };

  evals.ddice = function(set, n) {
    return parseInt(
      n.a.reduce(function(r, e) { return r + random(evalNode(set, e)); }, ''),
      10);
  };

  evals.cdice = function(set, n) {
//cjog(n);
    var c = evalNode(set, n.a[0]);
    var d = evalNode(set, n.a[1]);
    var rs = []; for (var i = 0; i < c; i++) rs.push(random(d));
    var k = n.a[2]; k = k && k.s;
    var kc = n.a[3]; kc = kc && evalNode(set, kc);
//cjog(c, d, k, kc);
    if (k === 'kh') rs = rs.sort().reverse().slice(0, kc || 1);
    else if (k === 'kl') rs = rs.sort().slice(0, kc || 1);
    return rs.reduce(function(a, b) { return a + b; }, 0);
  };

  evals.num = function(set, n) {
    return n.n; };
  evals.boo = function(set, n) {
    return n.b; };
  evals.pos = evals.num;

  evals.prd = function(set, n) {
    var mod = 1;
    var r = 1;
    for (var i = 0, l = n.a.length; i < l; i++) {
      var e = n.a[i];
      if (e.t === 'sop') {
        mod = e.s === '*' ? 1 : -1;
      }
      else {
        var ee = evalNode(set, e);
        if (typeof r === 'number' && typeof ee !== 'number') {
          r = ee;
        }
        else if (typeof r === 'string' && typeof ee === 'number') {
          var r0 = r;
          r = '';
          for (var j = 0; j < ee; j++) { r = r + r0; }
        }
        else {
          r = r * Math.pow(evalNode(set, e), mod);
        }
      }
    }
    return r;
  }

  evals.sum = function(set, n) {
//clog('evals.sum', n);
    var mod = 1;
    var r;
    for (var i = 0, l = n.a.length; i < l; i++) {
      var e = n.a[i];
      if (i === 0) {
        r = evalNode(set, e);
      }
      else if (e.t === 'sop') {
        mod = (e.s === '+') ? 1 : -1;
      }
      else if (Array.isArray(r)) {
        var ee = evalNode(set, e);
        if (Array.isArray(ee)) { r = r.concat(ee); }
        else { r.push(ee); }
      }
      else if (typeof r === 'object') {
        var ee = evalNode(set, e);
        Object.assign(r, ee);
      }
      else if (typeof r === 'string') {
        r = r + evalNode(set, e);
      }
      else {
        var r1 = evalNode(set, e);
        if (typeof r1 !== 'number') r = (i === 0 ? '' : '' + r) + r1;
        else r = r + mod * evalNode(set, e);
      }
    }
    return r;
  };

  evals.lgt = function(set, n) {
    var c = {};
    var r = true;
    for (var i = 0, l = n.a.length; r && i + 2 < l; i = i + 2) {
      var a = c[i] || evalNode(set, n.a[i]); c[i] = a;
      var b = c[i + 2] || evalNode(set, n.a[i + 2]); c[i + 2] = b;
      var op = n.a[i + 1].s;
      if (op === '>') r = a > b;
      else if (op === '>=') r = a >= b;
      else if (op === '<') r = a < b;
      else if (op === '<=') r =  a <= b;
    };
    return r;
  };

  evals._op = function(set, n) {
    var op = n.a[1].s;
    if (op === '%') return evals.mod(set, n);
    if (op === '+' || op === '-') return evals.sum(set, n);
    if (op === '/' || op === '*') return evals.prd(set, n);
    if (op.match(/^>=?|<=?$/)) return evals.lgt(set, n);
    throw "evals. op " + op + " not implemented."; };

  evals._setVal = function(set, n, val) {
//clog('_setVal()', 'n', n, 'val', val);
    var ocn = n.a[0]; // ocall node
    var cns = abody(ocn.a);
    var kn = alast(ocn.a);
//clog('_setVal()', 'kn', kn);
    //var k = evalNode(set, kn);
//clog('_setVal()', 'kn', kn, 'k', k);

    if (cns.length < 1) {
      var k = kn.s;
      var c = k.match(/^[A-Z][A-Z0-9_]*$/) ? evals._getRoot(set) : set.vars;
      c[k] = val;
    }
    else {
      var ocn1 = { t: 'ocall', a: cns };
//clog('_setVal()', 'ocn1', ocn1);
      var c = evalNode(set, ocn1);
//clog('_setVal()', 'c', c);
      if (kn.t === 'comexps') {
        var ces = kn.a.map(function(nn) { return evalNode(set, nn); });
//clog('_setVal()', 'ces', ces);
        var ks = ces[0];
        var ke = ces[1] || ces[0] + 1;
        if (typeof ke === 'number') {
          for (var i = ks; i < ke; i++) c[i] = val;
        }
        else {
          c[ks] = val;
        }
      }
      else if (kn.t === 'scolexps') {
        kn.a.forEach(function(nn) {
          var i = evalNode(set, nn); c[i] = val; }); }
      else if (kn.t === 'vname') {
        c[kn.s] = val;
      }
      else {
        throw `evals._setVal() TODO implement for ${JSON.stringify(kn)}`;
      }
    }
  };

  evals._ass = function(set, n) {
    var val = evalNode(set, alast(n.a));
    abody(n.a).forEach(function(nn) { evals._setVal(set, nn, val); });
    return val;
  };

  evals._ter = function(set, n) {
    var con = n.a[0].a[0];
    var the = n.a[0].a[1];
    var els = n.a[1];
    return evalNode(set, con) ? evalNode(set, the) : evalNode(set, els);
  };

  evals.exp = function(set, n) {
    if (n.a[0].t === 'heass') return evals._ass(set, n);
    if (n.a[0].t === 'heter') return evals._ter(set, n);
    return evals._op(set, n);
  };

  var evalNode = function(set, n) {

    if ( ! set.parent) for (var k in funcs) {
      if ( ! set.vars.hasOwnProperty(k)) set.vars[k] = funcs[k];
    }

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

    var r = { main: null, tables: {}, vars: {}, parent: null };
    parseMdSplit(s).forEach(function(section) {
      if (section.type === 'h1' && ! r.main) r.main = section.name;
      r.tables[section.name] = parseMdExpand(section);
    });

    return r;
  };

  var funcs = {}; // filled below...

  // public functions

  this.funcs = funcs;

  this.debugEval = function(s) {

    var t = MaboStringParser.parse(s);
    if ( ! t) throw "Failed to parse " + JSON.stringify(s);

    var h = arguments[1] || { vars: {} };

    return [
      evalNode(h, t[0]),
      h ];
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


MaboTableSet.funcs.parseInt = function(s) {
  return parseInt(s, 10);
};

MaboTableSet.funcs.sprintf = function() {
  var s = arguments[0];
  var args = Array.from(arguments).slice(1);
  var r = '';
  var m, a0, a;
  while (s.length > 0) {
    m = s.match(/^([^%]*)(.*)$/);
    r = r + m[1];
    s = m[2];
    m = s.match(/^(%%|%-?\+?\d*[sdj])(.*)$/);
    if (m && m[1] === '%%') {
      r = r + '%';
      s = m[2];
    }
    else if (m) {
      a0 = args.shift(); a = '' + a0;
      var min = !! m[1].match(/^%-/);
      var plu = !! m[1].match(/\+\d/);
      var wid = m[1].match(/\d+/); wid = wid && parseInt(wid, 10);
      if (m[1].endsWith('j')) {
        a = JSON.stringify(a0);
      }
      else if (m[1].endsWith('d')) {
        if (plu && a0 >= 0) a = '+' + a0;
        if (wid) a = a[min ? 'padEnd' : 'padStart'](wid, ' ');
      }
      else if (m[1].endsWith('s')) {
        if (wid) a = a[min ? 'padEnd' : 'padStart'](wid, ' ');
      }
      //else {
      //}
      r = r + a;
      s = m[2];
    }
  }
  return r;
};

