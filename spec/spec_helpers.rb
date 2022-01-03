
#
# spec'ing maboroshi
#
# Sun Dec 12 14:26:47 JST 2021
#

require 'pp'
require 'json'
require 'ferrum'


module Helpers

  def evaluate(s)

    $sources ||=
      begin
        %w[ www/js/maboroshi.js ]
          .collect { |path| File.read(path) }
          .join(';')
      end
    $browser ||=
      begin
        Ferrum::Browser.new(js_errors: true)
      end

    s1 = "JSON.stringify((function() { #{$sources}; #{s}; })())"
    j = begin
      $browser.evaluate(s1)
    rescue Ferrum::DeadBrowserError
      $browser = nil
      return evaluate(s)
    end

    JSON.parse(j)
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

