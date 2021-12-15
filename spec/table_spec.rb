
#
# spec'ing maboroshi.js
#
# Wed Dec 15 14:58:54 JST 2021
#

require 'spec_helpers.rb'


describe 'MaboTable' do

  before :each do

    @monster0 = File.read('www/monster0.md')
    @monster0j = JSON.dump(@monster0)
  end

  describe '.doMake' do

    it 'parses monster0' do

      t = evaluate("return MaboTable.doMake('monster0.md', #{@monster0j});")

#p t
      expect(t['table']).to eq([
        '{1d6} goblins',
        '{1d3} orcs with {1d2-1} shamans',
        '{1d3} orcs with {1d2} warchief(s) and their moms',
        '{1d2} ghosts' ])
    end
  end
end

