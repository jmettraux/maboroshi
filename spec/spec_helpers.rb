
#
# spec'ing maboroshi
#
# Sun Dec 12 14:26:47 JST 2021
#

require 'pp'
require 'io/console'
require 'json'
require 'ferrum'


module Helpers

  #MW = IO.console.winsize[1] rescue 80
  MW = 1000 # :-(

  def evaluate(s)

    $sources ||=
      begin
        src = %w[ www/js/jaabro-1.4.0.com.js www/js/maboroshi.js ]
          .collect { |path| File.read(path) }
          .join(';')
        src = %{
          window._log = [];
          window.clog = function() {
            window._log.push(JSON.stringify(Array.from(arguments))) };
          window.cjog = window.clog;
        } + src
        File.open('spec/.source.js', 'w') { |f| f.write(src) }
        src
      end
    $browser ||=
      Ferrum::Browser.new(
        js_errors: true,
        extensions: [ { source: $sources } ])

    s1 = "JSON.stringify((function() { #{s}; })())"

    j =
      begin
        $browser.evaluate(s1)
      rescue Ferrum::DeadBrowserError
        $browser = nil
        return evaluate(s)
      end

    JSON.parse(j)

  rescue JSON::ParserError

    raise ::StandardError.new(j)

  ensure

    $log =
      begin
        $browser.evaluate('window._log').collect { |e| JSON.parse(e) }
      rescue
        nil
      end
  end

  def print_tree(n, indent=0)

    tc =  "[0;90m" # tree color
    sc0 = "[1;33m[4m" # string color 0
    sc1 = "[0;33m" # string color 1
    c1 =  "[0;32m" # result 1 color
    rc =  "[0;0m" # reset color
    rdc = "[1;31m" # red color
    nc =  "[0;97m" # name color

    if indent == 0
      n['input']['string']
        .split("\n")
        .each { |l| puts "#{tc}  │#{sc1}#{l}#{rc}" }
    end

    o, l = n['offset'], n['length']
    s = n['input']['string'][o..-1]
    res = n['result']
    r = res.to_s; r = "#{c1}#{r}#{tc}" if res == 1

    na = n['name']; na = na ? "#{nc}#{na}#{tc}" : '(null)'

    ind = (0..indent)
      .inject('') { |ss, i|
        ss +
          case i % 3
          when 0 then '│ '
          when 1 then '· '
          else '· '; end }

    sio =
      StringIO.new
    sio <<
      ind << tc << na << ' ' << r << ' ' << n['parter'] << "(#{o}, #{l})"

    if res != 1
      #sc0 = "[1;90m";
      sc1 = "[0;90m"
    end

    mw = MW - sio.length - 3 - 10; mw = 0 if mw < 0
    s = s[0, mw]
    if l < mw
      s.insert(l, sc1)
    elsif l > mw
      s = s + sc1 + '...'
    end
    s = s.gsub(/\n/, '\n')

    sio <<
      ' >' << sc0 << s << tc << '<'

    puts sio.string

    n['children'].each { |c| print_tree(c, indent + 1) }

    if indent == 0
      il = n['input']['string'].length
      tl = n['length']; tl = "#{rdc}#{tl}#{rc}" if tl != il
      puts "├─ input length:  #{il}"
      puts "└─ tree length:   #{tl}"
    end
  end

  def dump_tree(s, level=2)

    puts

    print_tree(
      evaluate(
        "return MaboStringParser.parse(#{s.inspect}, { debug: #{level} });"))
  end
end

RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end


class ::String

  #def htrip
  #  self
  #    .gsub(/^( +)/, '')
  #    .gsub(/>\s+(.)/) { |m| ">#{$1}" }
  #    .gsub(/\s+</, '<')
  #    .strip
  #end
  #def huntrip
  #  '  ' + htrip.gsub(/>/, ">\n  ")
  #end
end

class ::Integer

  def included_in?(a)

    a.include?(self)
  end
end


#RSpec::Matchers.define :eqh do |expected|
#
#  match do |actual|
#
#    expected.htrip == actual.htrip
#  end
#
#  failure_message do |actual|
#
#    "expected:\n#{expected.huntrip}\n" +
#    "actual:\n#{actual.huntrip}"
#  end
#end

