
#
# spec'ing maboroshi
#
# Sun Dec 12 14:26:47 JST 2021
#

require 'pp'
require 'json'
require 'ferrum'
require 'webrick'

WPORT = 9090

server = WEBrick::HTTPServer.new(
  Port: WPORT,
  DocumentRoot: File.join(Dir.pwd, 'www'),
  Logger: WEBrick::Log.new('/dev/null'),
  AccessLog: [])
Thread.new {
  server.start }


module Helpers

  def evaluate(s)

    $browser ||=
      begin

        opts = {}

        opts[:headless] = (ENV['HEADLESS'] != 'false')
        if opts[:headless]
          opts[:xvfb] = true
          opts[:headless] = false
        end

        b = Ferrum::Browser.new(opts)

        sleep 0.450
        b.goto("http://127.0.0.1:#{WPORT}/spec.html")
        #b.execute('window._src = document.body.innerHTML;')

        b
      end

    r = $browser.evaluate("JSON.stringify((function() {#{s};})())");

    begin
      r = JSON.parse(r)
    rescue
      fail RuntimeError.new(r)
    end if r.is_a?(String)

    r = r.strip if r.is_a?(String)

    r
  end

  #def reset_dom
  #  $browser.execute('document.body.innerHTML = window._src;') \
  #    if $browser
  #end
  #def class_list(a)
  #  a.each_with_index.inject({}) { |h, (c, i)| h[i.to_s] = c; h }
  #end
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

