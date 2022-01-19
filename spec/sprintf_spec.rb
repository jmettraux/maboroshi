
#
# spec'ing maboroshi.js
#
# Tue Jan 18 20:45:23 JST 2022
#

require 'spec_helpers.rb'


describe 'MaboTableSet.funcs' do

  describe '.sprintf' do

    {

      [ '', 123 ] => '',

      [ '%s', 4 ] => '4',
      [ '%10s', 'xxx' ] =>  '       xxx',
      [ '%-10s', 'xxx' ] => 'xxx       ',

      [ '%d', 4 ] => '4',
      [ '%10d', 4 ] =>    '         4',
      [ '%-10d', 4 ] =>   '4         ',
      [ '%+10d', 4 ] =>   '        +4',
      [ '%-+10d', 4 ] =>  '+4        ',
      [ '%+10d', -4 ] =>  '        -4',
      [ '%-+10d', -4 ] => '-4        ',
      [ '%-+10dx', -4 ] => '-4        x',
      [ '%+10dx', -4 ] =>  '        -4x',

      [ '%%' ] => "%",
      [ '%j', [ 1, 2, 3 ] ] => "[1,2,3]",

    }.each do |k, v|

      it "formats for #{k.inspect}" do

        r, _ = evaluate(
          "return MaboTableSet.funcs.sprintf.apply(null, #{JSON.dump(k)})");

        expect(r).to eq(v)
      end
    end
  end
end

