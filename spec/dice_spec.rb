
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
      '1d6+3' => [
        { 'c' => 1, 'd' => 6 }, '+', 3 ],
      '1d6 + 1d8 + 2' => [
        { 'c' => 1, 'd' => 6 }, '+', { 'c' => 1, 'd' => 8 }, '+',  2 ],
      '1d6 -2' => [
        { 'c' => 1, 'd' => 6 }, '+', -2 ],
      '1d6 + -2' => [
        { 'c' => 1, 'd' => 6 }, '+', -2 ],

    }.each do |k, v|

      it "parses #{k}" do

        expect(evaluate("return Dice.parse(#{k.inspect});")).to eq(v)
      end
    end

    [

      'nada',
      'foo bar 1d6',

    ].each do |k, v|

      it "does not parse #{k}" do

        expect(evaluate("return Dice.parse(#{k.inspect});")).to eq(nil)
      end
    end
  end

  describe '.roll' do

    it 'rolls' do

      expect(evaluate('return Dice.roll("3d6");')
        ).to be_between(3, 18)
    end

    {

      '3d6' =>
        3..18,
      '3d6+2' =>
        5..20,
      '3d6 + 2' =>
        5..20,
      'd2d3' => [
        11, 12, 13, 21, 22, 23 ],
      'd2d3 + 1' => [
        12, 13, 14, 22, 23, 24 ],
      '1d6 + 1d8' =>
        2..14,
      '1d6 - 2' =>
        -1..4,

    }.each do |k, v|

      it "rolls #{k}" do

        250.times do
          expect(evaluate("return Dice.roll(#{k.inspect});")
            ).to be_included_in(v)
        end
      end
    end
  end
end

