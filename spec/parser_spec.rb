
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

    }.each do |k, v|

      it "parses #{k.inspect}" do

        t = evaluate("return MaboStringParser.parse(#{k.inspect});")

        if t != v
          dump_tree(k, 2)
          puts; pp t
          exit(1)
        end

        expect(t).to eq(v)
      end
    end
  end
end

