
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
        {"t"=>"exps", "a"=>[
          {"t"=>"table", "s"=>"status"},
          {"t"=>"dice", "s"=>"1d6"}]},
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

