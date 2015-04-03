#!/usr/bin/env ruby

# Pseudo code to Graphviz converter
# ./tt.rb | dot -Tsvg > tt.svg

require 'polyglot'

require './pseudocode.rb'

Treetop.load "pseudocode"

parser = PseudocodeParser.new

tree = parser.parse(IO.read 'reg.pseudo')

if(tree.nil?)
  puts parser.failure_reason
else
  puts "digraph G {"
  tree.show
  puts "}"
end
