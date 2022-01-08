
#
# spec'ing maboroshi.js
#
# Wed Jan  5 08:56:20 JST 2022
#

require 'spec_helpers.rb'


describe 'MaboTableSet' do

  describe '.evalString' do

    context '(dice)' do

      {

        '{1d6}' =>
          [ 1, 6 ],
        '{1d6 + 1}' =>
          [ 2, 7 ],
        '{d6d6}' =>
          (1..6).to_a.product((1..6).to_a).map { |a, b| "#{a}#{b}".to_i },

        '{4d6kh3}' => [ 3, 18 ],
        '{4d6kl3}' => [ 3, 18 ],
        '{4d6kh}' => [ 1, 6 ],
        '{4d6kl}' => [ 1, 6 ],

      }.each do |k, v|

        it "evals #{k.inspect}" do

          if v.is_a?(Array) && v.length == 2 # dice range

            210.times do
              r, h = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
              expect(r).to be_between(*v)
            end

          else

            210.times do
              r, h = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
              expect(v.include?(r)).to eq(true)
            end

          end
        end
      end
    end

    context '(not dice)' do

      {

        '{a = 11}' => { r: 11, h: { vars: { 'a' => 11 } } },
        '{a = B = 12}' => { r: 12, h: { vars: { 'a' => 12, 'B' => 12 } } },
        '{a1 = B2 = 13}' => { r: 13, h: { vars: { 'a1' => 13, 'B2' => 13 } } },

        '{a = 14; 15; a}' => 14,
        '{a = 14; a + 1}' => 15,

        '{12 + 34}' => 46,
        '{3 * 12}' => 36,
        '{12 / 3}' => 4,

        '{true}' => true,
        '{TRUE}' => true,
        '{false}' => false,
        '{FALSE}' => false,

        "{'abc'}" => 'abc',
        "{'abc\"def'}" => 'abc"def',

        "{'a' + 1 + 2}" => 'a12',

        "{a}" => nil,

        "{a = (1; 2; 3)}" => 3,

        "{ [ 1, 'deux', true ] }" => [ 1, 'deux', true ],

        "{ {} }" => {},
        "{ {,} }" => {},
        "{ { ab: 1, cd: 2, } }" => { 'ab' => 1, 'cd' => 2 },

        "{ 4 * (2 + 3) }" => 20,

      }.each do |k, v|

        it "evals #{k.inspect}" do

          if v.is_a?(Hash) && v.keys == [ :r, :h ]

            vh = v[:h].inject({}) { |h, (kk, vv)| h[kk.to_s] = vv; h }

            r, h = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
            expect(r).to eq(v[:r])
            expect(h).to eq(vh)

          else

            r, h = evaluate("return MaboTableSet.debugEval(#{k.inspect})");
            expect(r).to eq(v)
          end
        end
      end
    end
  end
end

