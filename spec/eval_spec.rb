
#
# spec'ing maboroshi.js
#
# Wed Jan  5 08:56:20 JST 2022
#

require 'spec_helpers.rb'


describe 'MaboTableSet' do

  describe '.evalString' do

    {

      '{1d6}' =>
        [ 1, 6 ],
      '{1d6 + 1}' =>
        [ 2, 7 ],
      '{d6d6}' =>
        (1..6).to_a.product((1..6).to_a).map { |a, b| "#{a}#{b}".to_i },
      '{12 + 34}' =>
        46,

    }.each do |k, v|

      it "evals #{k.inspect}" do

        if v.is_a?(Array) && v.length == 2 # dice range

          (v[1] * 3).times do
            r = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
            expect(r).to be_between(*v)
          end

        elsif v.is_a?(Array)

          (v.length * 3).times do
            r = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
            expect(v.include?(r)).to eq(true)
          end

        else

          r = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
          expect(r).to eq(v)
        end
      end
    end
  end
end

