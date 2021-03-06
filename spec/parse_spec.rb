
#
# spec'ing maboroshi.js
#
# Mon Jan  3 09:43:53 JST 2022
#

require 'spec_helpers.rb'


describe 'MaboStringParser' do

  describe '.parse' do

    it 'parses' do

      t = evaluate("return MaboStringParser.parse('foo bar');")

      expect(t).to be_a(Array)
    end

    {

      "foo bar" => [
        { 't' => 'str', 's' => 'foo bar' } ],

      "{;;}" =>
        [{"t"=>"exps", "a"=>[]}],

      '{3d6;""}' =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice", "a"=>[{"t"=>"pos", "n"=>3}, {"t"=>"pos", "n"=>6}]},
            {"t"=>"dqs", "a"=>[]}]}],
      "{\n1d6;\n\"\"\n}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice", "a"=>[{"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>6}]},
            {"t"=>"dqs", "a"=>[]}]}],

      "a {@ status} goblin" =>
        [{"t"=>"str", "s"=>"a "},
         {"t"=>"exps",
          "a"=>
           [{"t"=>"table",
             "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"status"}]}]}]},
         {"t"=>"str", "s"=>" goblin"}],

      "{@ status; 1d6} orc" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"table",
             "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"status"}]}]},
            {"t"=>"cdice", "a"=>[{"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>6}]}]},
         {"t"=>"str", "s"=>" orc"}],

      "{a = 1}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"num", "n"=>1}]}]}],

      "{a = b = 2}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]},
               {"t"=>"num", "n"=>2}]}]}],

      "{TRUE ? 0 : 1 }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heter", "a"=>[
                {"t"=>"boo", "b"=>true}, {"t"=>"num", "n"=>0}]},
               {"t"=>"num", "n"=>1}]}]}],

      "{a ? b : c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heter",
                "a"=>
                 [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]},
                  {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]},
               {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"c"}]}]}]}],

      "{a ? b : c ? d : e}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heter",
                "a"=>
                 [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]},
                  {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]},
               {"t"=>"heter",
                "a"=>
                 [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"c"}]},
                  {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"d"}]}]},
               {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"e"}]}]}]}],

      "{x = a ? b : c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"x"}]}]},
               {"t"=>"exp",
                "a"=>
                 [{"t"=>"heter",
                   "a"=>
                    [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]},
                     {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]},
                  {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"c"}]}]}]}]}],

      "{a || b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]},
               {"t"=>"sop", "s"=>"||"},
               {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]}]}],

      "{a == b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]},
               {"t"=>"sop", "s"=>"=="},
               {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]}]}],

      "{1 > 2}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"num", "n"=>1},
               {"t"=>"sop", "s"=>">"},
               {"t"=>"num", "n"=>2}]}]}],

      "{a >= b < c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]},
               {"t"=>"sop", "s"=>">="},
               {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]},
               {"t"=>"sop", "s"=>"<"},
               {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"c"}]}]}]}],

      "{10 + 1d6 - 2 * 3}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"num", "n"=>10},
               {"t"=>"sop", "s"=>"+"},
               {"t"=>"cdice", "a"=>[
                {"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>6}]},
               {"t"=>"sop", "s"=>"-"},
               {"t"=>"exp",
                "a"=>
                 [{"t"=>"num", "n"=>2},
                  {"t"=>"sop", "s"=>"*"},
                  {"t"=>"num", "n"=>3}]}]}]}],

      "{d6d6}" =>
        [{"t"=>"exps",
          "a"=>[
           {"t"=>"ddice", "a"=>[
            {"t"=>"pos", "n"=>6}, {"t"=>"pos", "n"=>6}]}]}],

      "{2d66}" =>
        [{"t"=>"exps",
          "a"=>[
           {"t"=>"cdice", "a"=>[
            {"t"=>"pos", "n"=>2}, {"t"=>"pos", "n"=>66}]}]}],

      "{2d20kh}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice",
             "a"=>
              [{"t"=>"pos", "n"=>2},
               {"t"=>"pos", "n"=>20},
               {"t"=>"dicehkl", "s"=>"kh"}]}]}],

      "{2d20kl}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice",
             "a"=>
              [{"t"=>"pos", "n"=>2},
               {"t"=>"pos", "n"=>20},
               {"t"=>"dicehkl", "s"=>"kl"}]}]}],

      "{2d20kh1}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice",
             "a"=>
              [{"t"=>"pos", "n"=>2},
               {"t"=>"pos", "n"=>20},
               {"t"=>"dicehkl", "s"=>"kh"},
               {"t"=>"pos", "n"=>1}]}]}],

      "{12d20kl11}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice",
             "a"=>
              [{"t"=>"pos", "n"=>12},
               {"t"=>"pos", "n"=>20},
               {"t"=>"dicehkl", "s"=>"kl"},
               {"t"=>"pos", "n"=>11}]}]}],

      "{4d6kh3}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice",
             "a"=>
              [{"t"=>"pos", "n"=>4},
               {"t"=>"pos", "n"=>6},
               {"t"=>"dicehkl", "s"=>"kh"},
               {"t"=>"pos", "n"=>3}]}]}],

      "{ d(1d6)d(1d8) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ddice",
             "a"=>
              [{"t"=>"par",
                "a"=>
                 [{"t"=>"cdice",
                   "a"=>[{"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>6}]}]},
               {"t"=>"par",
                "a"=>
                 [{"t"=>"cdice",
                   "a"=>[{"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>8}]}]}]}]}],

      "{ (1d6)d(1d8) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"cdice",
             "a"=>
              [{"t"=>"par",
                "a"=>
                 [{"t"=>"cdice",
                   "a"=>[{"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>6}]}]},
               {"t"=>"par",
                "a"=>
                 [{"t"=>"cdice",
                   "a"=>[{"t"=>"pos", "n"=>1}, {"t"=>"pos", "n"=>8}]}]}]}]}],

      "{10 % 3}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"num", "n"=>10},
               {"t"=>"sop", "s"=>"%"},
               {"t"=>"num", "n"=>3}]}]}],

      "{a = @ table}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"table",
                "a"=>[
                 {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"table"}]}]}]}]}],

      "{a = 'a small single quoted string}\"'}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"str", "s"=>"a small single quoted string}\""}]}]}],

      "\n{\n  a = 1;\n  b = 2;\n}\nHello World! {@ table}" =>
        [{"t"=>"str", "s"=>"\n"},
         {"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"num", "n"=>1}]},
            {"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]},
               {"t"=>"num", "n"=>2}]}]},
         {"t"=>"str", "s"=>"\n" + "Hello World! "},
         {"t"=>"exps",
          "a"=>
           [{"t"=>"table",
             "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"table"}]}]}]}],

      "{fun(1, '2', b)}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"fun"},
               {"t"=>"comexps",
                "a"=>
                 [{"t"=>"num", "n"=>1},
                  {"t"=>"str", "s"=>"2"},
                  {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"b"}]}]}]}]}],

      "{a[1]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"comexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{a[1:]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"colexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{a[:2]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"colexps", "a"=>[{"t"=>"num", "n"=>2}]}]}]}],

      "{a[1:2]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"colexps", "a"=>[
                 {"t"=>"num", "n"=>1}, {"t"=>"num", "n"=>2}]}]}]}],

      "{a[1;]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"scolexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{a[;1]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"scolexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{a[;]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>[{"t"=>"vname", "s"=>"a"}, {"t"=>"scolexps", "a"=>[]}]}]}],

      "{a[1;2;3]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"scolexps",
                "a"=>
                 [{"t"=>"num", "n"=>1},
                  {"t"=>"num", "n"=>2},
                  {"t"=>"num", "n"=>3}]}]}]}],

      "{a[1, 2]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"comexps", "a"=>[
                 {"t"=>"num", "n"=>1}, {"t"=>"num", "n"=>2}]}]}]}],

      "{a.b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall", "a"=>[
             {"t"=>"vname", "s"=>"a"}, {"t"=>"vname", "s"=>"b"}]}]}],

      "{a.0}" =>
        [{"t"=>"exps",
          "a"=>[{"t"=>"ocall", "a"=>[
            {"t"=>"vname", "s"=>"a"}, {"t"=>"num", "n"=>0}]}]}],

      "{a.-1}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall", "a"=>[
             {"t"=>"vname", "s"=>"a"}, {"t"=>"num", "n"=>-1}]}]}],

      "{-1}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"num", "n"=>-1}]}],

      "{ 1 + -1 }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"num", "n"=>1},
               {"t"=>"sop", "s"=>"+"},
               {"t"=>"num", "n"=>-1}]}]}],

      "{ () }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"par", "a"=>[]}]}]}],

      "{ (1) }" =>
        [{"t"=>"exps", "a"=>[
          {"t"=>"ocall", "a"=>[{"t"=>"par", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{ (1;) }" =>
        [{"t"=>"exps", "a"=>[
          {"t"=>"ocall", "a"=>[{"t"=>"par", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{ (;1) }" =>
        [{"t"=>"exps", "a"=>[
          {"t"=>"ocall", "a"=>[{"t"=>"par", "a"=>[{"t"=>"num", "n"=>1}]}]}]}],

      "{ (1; 2; 3) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"par",
                "a"=>
                 [{"t"=>"num", "n"=>1},
                  {"t"=>"num", "n"=>2},
                  {"t"=>"num", "n"=>3}]}]}]}],

      "{ a = (1; 2; 3) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"ocall",
                "a"=>
                 [{"t"=>"par",
                   "a"=>
                    [{"t"=>"num", "n"=>1},
                     {"t"=>"num", "n"=>2},
                     {"t"=>"num", "n"=>3}]}]}]}]}],

      "{ [ 1, 'deux' ] }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"list",
                "a"=>[{"t"=>"num", "n"=>1}, {"t"=>"str", "s"=>"deux"}]}]}]}],
      "{ true }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"boo", "b"=>true}]}],

      "{ [] }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"list", "a"=>[]}]}]}],

      "{ [,] }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"list", "a"=>[]}]}]}],

      "{ [, , ,] }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"list", "a"=>[]}]}]}],

      "{ a = [ 1, 'deux', 1 + 2, true ] }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"ocall",
                "a"=>
                 [{"t"=>"list",
                   "a"=>
                    [{"t"=>"num", "n"=>1},
                     {"t"=>"str", "s"=>"deux"},
                     {"t"=>"exp",
                      "a"=>
                       [{"t"=>"num", "n"=>1},
                        {"t"=>"sop", "s"=>"+"},
                        {"t"=>"num", "n"=>2}]},
                     {"t"=>"boo", "b"=>true}]}]}]}]}],

      "{ { ab: 1, cd: 2 } }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"dict",
                "a"=>
                 [[{"t"=>"vname", "s"=>"ab"}, {"t"=>"num", "n"=>1}],
                  [{"t"=>"vname", "s"=>"cd"}, {"t"=>"num", "n"=>2}]]}]}]}],

      "{ {} }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"dict", "a"=>[]}]}]}],

      "{ {,} }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"ocall", "a"=>[{"t"=>"dict", "a"=>[]}]}]}],

      "{ d = { name: 'joe', hp: 10, ac: 15, atk: 3 } }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"d"}]}]},
               {"t"=>"ocall",
                "a"=>
                 [{"t"=>"dict",
                   "a"=>
                    [[{"t"=>"vname", "s"=>"name"}, {"t"=>"str", "s"=>"joe"}],
                     [{"t"=>"vname", "s"=>"hp"}, {"t"=>"num", "n"=>10}],
                     [{"t"=>"vname", "s"=>"ac"}, {"t"=>"num", "n"=>15}],
                     [{"t"=>"vname", "s"=>"atk"}, {"t"=>"num", "n"=>3}]]}]}]}]}],

      "{ 1 * (2 + 3) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"num", "n"=>1},
               {"t"=>"sop", "s"=>"*"},
               {"t"=>"ocall",
                "a"=>
                 [{"t"=>"par",
                   "a"=>
                    [{"t"=>"exp",
                      "a"=>
                       [{"t"=>"num", "n"=>2},
                        {"t"=>"sop", "s"=>"+"},
                        {"t"=>"num", "n"=>3}]}]}]}]}]}],

      "{ a[1] = 'un' }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass",
                "a"=>
                 [{"t"=>"ocall",
                   "a"=>
                    [{"t"=>"vname", "s"=>"a"},
                     {"t"=>"comexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]},
               {"t"=>"str", "s"=>"un"}]}]}],

      "{ a = [ 1, 2 ]; a[1] = 'deux' }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[
                {"t"=>"ocall", "a"=>[{"t"=>"vname", "s"=>"a"}]}]},
               {"t"=>"ocall",
                "a"=>
                 [{"t"=>"list", "a"=>[
                   {"t"=>"num", "n"=>1}, {"t"=>"num", "n"=>2}]}]}]},
            {"t"=>"exp",
             "a"=>
              [{"t"=>"heass",
                "a"=>
                 [{"t"=>"ocall",
                   "a"=>
                    [{"t"=>"vname", "s"=>"a"},
                     {"t"=>"comexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]},
               {"t"=>"str", "s"=>"deux"}]}]}],

      "{ h.age = 2 }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass",
                "a"=>
                 [{"t"=>"ocall",
                   "a"=>[
                    {"t"=>"vname", "s"=>"h"}, {"t"=>"vname", "s"=>"age"}]}]},
               {"t"=>"num", "n"=>2}]}]}],

      %{{ "" }} =>
        [{"t"=>"exps", "a"=>[{"t"=>"dqs", "a"=>[]}]}],

      %{{ "double quoted string" }} =>
        [{"t"=>"exps",
          "a"=>[
           {"t"=>"dqs", "a"=>[{"t"=>"str", "s"=>"double quoted string"}]}]}],

      %{{ "double \\" string" }} =>
        [{"t"=>"exps",
          "a"=>[
           {"t"=>"dqs", "a"=>[{"t"=>"str", "s"=>"double \\\" string"}]}]}],

      %{ a{ "n { 'angry' } goblin" } just entered } =>
        [{"t"=>"str", "s"=>" a"},
         {"t"=>"exps",
          "a"=>
           [{"t"=>"dqs",
             "a"=>
              [{"t"=>"str", "s"=>"n "},
               {"t"=>"exps", "a"=>[{"t"=>"str", "s"=>"angry"}]},
               {"t"=>"str", "s"=>" goblin"}]}]},
         {"t"=>"str", "s"=>" just entered "}],

      "{ 'a' * 3 }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"str", "s"=>"a"},
               {"t"=>"sop", "s"=>"*"},
               {"t"=>"num", "n"=>3}]}]}],

      "{ fun(1, 2, 3) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"ocall",
             "a"=>
              [{"t"=>"vname", "s"=>"fun"},
               {"t"=>"comexps",
                "a"=>
                 [{"t"=>"num", "n"=>1},
                  {"t"=>"num", "n"=>2},
                  {"t"=>"num", "n"=>3}]}]}]}],

    }.each do |k, v|

      it "parses #{k.inspect}" do

        t = evaluate("return MaboStringParser.parse(#{k.inspect});")

        if t != v
          dump_tree(k, 2) rescue dump_tree(k, 3)
          puts; pp t
          exit(1)
        end

        expect(t).to eq(v)
      end
    end
  end
end

