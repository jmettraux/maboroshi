
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
        { 't' => 'sqs', 's' => 'foo bar' } ],

      "a {@ status} goblin" => [
        {"t"=>"sqs", "s"=>"a "},
        {"t"=>"exps", "a"=>[{"t"=>"table", "s"=>"status"}]},
        {"t"=>"sqs", "s"=>" goblin"}],

      "{@ status; 1d6} orc" => [
        {"t"=>"exps", "a"=> [
          {"t"=>"table", "s"=>"status"},
          {"t"=>"dice", 'c' => 1, 'd' => 6 } ] },
        {"t"=>"sqs", "s"=>" orc"}],

      "{a = 1}" => [
        {"t"=>"exps", "a"=> [
          {"t"=>"exp", "a"=> [
            {"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
            {"t"=>"num", "n"=>1}]}]}],

      "{a = b = 2}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"b"}]},
               {"t"=>"num", "n"=>2}]}]}],

      "{a ? b : c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heter",
                "a"=>
                 [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"a"}]},
                  {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]}]},
               {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"c"}]}]}]}],

      "{a ? b : c ? d : e}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heter",
                "a"=>
                 [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"a"}]},
                  {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]}]},
               {"t"=>"heter",
                "a"=>
                 [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"c"}]},
                  {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"d"}]}]},
               {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"e"}]}]}]}],

      "{x = a ? b : c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"x"}]},
               {"t"=>"exp",
                "a"=>
                 [{"t"=>"heter",
                   "a"=>
                    [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"a"}]},
                     {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]}]},
                  {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"c"}]}]}]}]}],

      "{a || b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"sop", "s"=>"||"},
               {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]}]}]}],

      "{a == b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"sop", "s"=>"=="},
               {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]}]}]}],

      "{a >= b < c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"sop", "s"=>">="},
               {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]},
               {"t"=>"sop", "s"=>"<"},
               {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"c"}]}]}]}],

      "{10 + 1d6 - 2 * 3}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"num", "n"=>10},
               {"t"=>"sop", "s"=>"+"},
               {"t"=>"dice", 'c' => 1, 'd' => 6 },
               {"t"=>"sop", "s"=>"-"},
               {"t"=>"exp",
                "a"=>
                 [{"t"=>"num", "n"=>2},
                  {"t"=>"sop", "s"=>"*"},
                  {"t"=>"num", "n"=>3}]}]}]}],

      "{d6d6}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "ds"=>[6, 6]}]}],

      "{2d66}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "c"=>2, "d"=>66}]}],

      "{2d20kh}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "c"=>2, "d"=>20, "kh"=>1}]}],
      "{2d20kl}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "c"=>2, "d"=>20, "kl"=>1}]}],
      "{2d20kh1}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "c"=>2, "d"=>20, "kh"=>1}]}],
      "{12d20kl11}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "c"=>12, "d"=>20, "kl"=>11}]}],
      "{4d6kh3}" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dice", "c"=>4, "d"=>6, "kh"=>3}]}],

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
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"table", "s"=>"table"}]}]}],

      "{a = 'a small single quoted string}\"'}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"sqs", "s"=>"'a small single quoted string}\"'"}]}]}],

      "\n{\n  a = 1;\n  b = 2;\n}\nHello World! {@ table}" =>
        [{"t"=>"sqs", "s"=>"\n"},
         {"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"num", "n"=>1}]},
            {"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"b"}]},
               {"t"=>"num", "n"=>2}]}]},
         {"t"=>"sqs", "s"=>"\n" + "Hello World! "},
         {"t"=>"exps", "a"=>[{"t"=>"table", "s"=>"table"}]}],

      "{fun(1, '2', b)}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"fun"},
               {"t"=>"caidx",
                "a"=>
                 [{"t"=>"comexps",
                   "a"=>
                    [{"t"=>"num", "n"=>1},
                     {"t"=>"sqs", "s"=>"'2'"},
                     {"t"=>"vcall", "a"=>[{"t"=>"iden", "s"=>"b"}]}]}]}]}]}],

      "{a[1]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"sqidx",
                "a"=>[{"t"=>"comexps", "a"=>[{"t"=>"num", "n"=>1}]}]}]}]}],

      "{a[1:2]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"sqidx",
                "a"=>
                 [{"t"=>"colexps",
                   "a"=>[{"t"=>"num", "n"=>1}, {"t"=>"num", "n"=>2}]}]}]}]}],

      "{a[1;2;3]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"sqidx",
                "a"=>
                 [{"t"=>"scolexps",
                   "a"=>
                    [{"t"=>"num", "n"=>1},
                     {"t"=>"num", "n"=>2},
                     {"t"=>"num", "n"=>3}]}]}]}]}],

      "{a[1, 2]}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"sqidx",
                "a"=>
                 [{"t"=>"comexps",
                   "a"=>[{"t"=>"num", "n"=>1}, {"t"=>"num", "n"=>2}]}]}]}]}],

      "{a.b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"doidx", "a"=>[{"t"=>"iden", "s"=>"b"}]}]}]}],

      "{a.0}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"doidx", "a"=>[{"t"=>"num", "n"=>0}]}]}]}],

      "{a.-1}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"vcall",
             "a"=>
              [{"t"=>"iden", "s"=>"a"},
               {"t"=>"doidx", "a"=>[{"t"=>"num", "n"=>-1}]}]}]}],

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

      "{ (1; 2; 3) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"par",
             "a"=>
              [{"t"=>"num", "n"=>1},
               {"t"=>"num", "n"=>2},
               {"t"=>"num", "n"=>3}]}]}],

      "{ a = (1; 2; 3) }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"par",
                "a"=>
                 [{"t"=>"num", "n"=>1},
                  {"t"=>"num", "n"=>2},
                  {"t"=>"num", "n"=>3}]}]}]}],

      "{ [ 1, 'deux' ] }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"list", "a"=>[
             {"t"=>"num", "n"=>1},
             {"t"=>"sqs", "s"=>"'deux'"}]}]}],

      "{ true }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"boo", "b"=>true}]}],

      "{ [] }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"list", "a"=>[]}]}],

      "{ a = [ 1, 'deux', 1 + 2, true ] }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"a"}]},
               {"t"=>"list",
                "a"=>
                 [{"t"=>"num", "n"=>1},
                  {"t"=>"sqs", "s"=>"'deux'"},
                  {"t"=>"exp",
                   "a"=>
                    [{"t"=>"num", "n"=>1},
                     {"t"=>"sop", "s"=>"+"},
                     {"t"=>"num", "n"=>2}]},
                  {"t"=>"boo", "b"=>true}]}]}]}],

      "{ { ab: 1, cd: 2 } }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"dict",
             "a"=>
              [[{"t"=>"iden", "s"=>"ab"}, {"t"=>"num", "n"=>1}],
               [{"t"=>"iden", "s"=>"cd"}, {"t"=>"num", "n"=>2}]]}]}],

      "{ {} }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dict", "a"=>[]}]}],
      "{ {,} }" =>
        [{"t"=>"exps", "a"=>[{"t"=>"dict", "a"=>[]}]}],

      "{ d = { name: 'joe', hp: 10, ac: 15, atk: 3 } }" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"iden", "s"=>"d"}]},
               {"t"=>"dict",
                "a"=>
                 [[{"t"=>"iden", "s"=>"name"}, {"t"=>"sqs", "s"=>"'joe'"}],
                  [{"t"=>"iden", "s"=>"hp"}, {"t"=>"num", "n"=>10}],
                  [{"t"=>"iden", "s"=>"ac"}, {"t"=>"num", "n"=>15}],
                  [{"t"=>"iden", "s"=>"atk"}, {"t"=>"num", "n"=>3}]]}]}]}],

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

