
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

      expect(t['tables']['monsters']).to eq({
        "type" => "string", "string" => "\n\n{@ some monsters}\n" })
    end

    it 'parses npc0' do

      t = evaluate(
        "return MaboTableSet.doMake('npc0.md', #{@npc0j});")

      expect(t['tables']['npc']).to eq({
        "type"=>"string", "string" => "\n\n{@trait} {@race}\n" })
      expect(t['tables']['race']).to eq({
        "name" => "race",
        "type" => "h2",
        "l" => "ol",
        "entries" => [ "human", "dwarf", "elf", "halflin" ] })
    end
  end
end

