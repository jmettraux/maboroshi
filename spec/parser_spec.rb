
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
        { 't' => 'sqs', 's' => 'a ' },
        { 't' => 'cod', 'a' => [ { "s" => "@ status", "t" => "exp" } ] },
        { 't' => 'sqs', 's' => ' goblin' } ],

      "{@ status; 1d6} orc" => [
        { "t" => "cod", "a" => [
          { "s" => "@ status", "t" => "exp" },
          { "s" => " 1d6", "t" => "exp" } ] },
        { "s"=>" orc", "t"=>"sqs" } ],

      "{@ name}" => [
        ],

    }.each do |k, v|

      it "parses #{k.inspect}" do

        t = evaluate("return MaboStringParser.parse(#{k.inspect});")

        expect(t).to eq(v)
      end
    end
  end
end

