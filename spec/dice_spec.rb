
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
  end
end

