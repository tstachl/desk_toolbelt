#!/usr/bin/env ruby

require 'date'

100000.times do
  puts Date.parse('2001-02-03').strftime('%FT%T%:z')
end
