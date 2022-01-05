
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
            {"t"=>"heass", "a"=>[{"t"=>"vname", "s"=>"a"}]},
            {"t"=>"num", "n"=>1}]}]}],

      "{a = b = 2}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"vname", "s"=>"a"}]},
               {"t"=>"heass", "a"=>[{"t"=>"vname", "s"=>"b"}]},
               {"t"=>"num", "n"=>2}]}]}],

      "{a ? b : c}" => [
        {"t"=>"exps", "a"=> [
          {"t"=>"exp", "a"=> [
            {"t"=>"heter", "a"=>[
              {"t"=>"vname", "s"=>"a"}, {"t"=>"vname", "s"=>"b"}]},
            {"t"=>"vname", "s"=>"c"}]}]}],

      "{a ? b : c ? d : e}" => [
        {"t"=>"exps",
         "a"=>
          [{"t"=>"exp",
            "a"=>
             [{"t"=>"heter",
               "a"=>[{"t"=>"vname", "s"=>"a"}, {"t"=>"vname", "s"=>"b"}]},
              {"t"=>"heter",
               "a"=>[{"t"=>"vname", "s"=>"c"}, {"t"=>"vname", "s"=>"d"}]},
              {"t"=>"vname", "s"=>"e"}]}]}],

      "{x = a ? b : c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"vname", "s"=>"x"}]},
               {"t"=>"exp",
                "a"=>
                 [{"t"=>"heter",
                   "a"=>[{"t"=>"vname", "s"=>"a"}, {"t"=>"vname", "s"=>"b"}]},
                  {"t"=>"vname", "s"=>"c"}]}]}]}],

      "{a || b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"sop", "s"=>"||"},
               {"t"=>"vname", "s"=>"b"}]}]}],

      "{a == b}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"sop", "s"=>"=="},
               {"t"=>"vname", "s"=>"b"}]}]}],

      "{a >= b < c}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"vname", "s"=>"a"},
               {"t"=>"sop", "s"=>">="},
               {"t"=>"vname", "s"=>"b"},
               {"t"=>"sop", "s"=>"<"},
               {"t"=>"vname", "s"=>"c"}]}]}],

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
              [{"t"=>"heass", "a"=>[{"t"=>"vname", "s"=>"a"}]},
               {"t"=>"table", "s"=>"table"}]}]}],

      "{a = 'a small single quoted string}\"'}" =>
        [{"t"=>"exps",
          "a"=>
           [{"t"=>"exp",
             "a"=>
              [{"t"=>"heass", "a"=>[{"t"=>"vname", "s"=>"a"}]},
               {"t"=>"sqs", "s"=>"'a small single quoted string}\"'"}]}]}],

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

