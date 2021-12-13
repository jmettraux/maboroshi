
#
# spec'ing maboroshi.js
#
# Sun Dec 12 14:28:54 JST 2021
#

require 'spec_helpers.rb'


describe 'maboroshi Dice' do

  describe '.parse' do

    it 'parses' do

      expect(evaluate('return Dice.parse("3d6");')
        ).to eq([ { 'c' => 3, 'd' => 6 } ])
    end

    {

      'd20' => [
        { 'c' => 1, 'd' => 20 } ],
      '1d20' => [
        { 'c' => 1, 'd' => 20 } ],
      '3d6' => [
        { 'c' => 3, 'd' => 6 } ],
      'd6d4' => [
        { 'c' => 1, 'd' => 6 }, { 'c' => 1, 'd' => 4 } ],

    }.each do |k, v|

      it "parses #{k}" do

        expect(evaluate("return Dice.parse(#{k.inspect});")).to eq(v)
      end
    end
  end
end

