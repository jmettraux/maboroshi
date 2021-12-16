
#
# spec'ing maboroshi.js
#
# Wed Dec 15 14:58:54 JST 2021
#

require 'spec_helpers.rb'


describe 'MaboTableSet' do

  before :each do

    @monster0 = File.read('www/monster0.md')
    @monster0j = JSON.dump(@monster0)

    @npc0 = File.read('www/npc0.md')
    @npc0j = JSON.dump(@npc0)
  end

  describe '.doMake' do

    it 'parses monster0' do

      t = evaluate(
        "return MaboTableSet.doMake('monster0.md', #{@monster0j});")

      expect(t['tables']['monster']).to eq([
        '{1d6} goblins',
        '{1d3} orcs with {1d2-1} shamans',
        '{1d3} orcs with {1d2} warchief(s) and their moms',
        '{1d2} ghosts' ])
    end

    it 'parses npc0' do

      t = evaluate(
        "return MaboTableSet.doMake('npc0.md', #{@npc0j});")

      expect(t['tables']['npc']).to eq([
        '{#trait} {#race}' ])
      expect(t['tables']['race']).to eq([
        'human', 'dwarf', 'elf', 'halflin' ])
    end
  end
end

