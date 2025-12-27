# frozen_string_literal: true

require_relative 'mastermind_host'
require_relative 'mastermind_knuth'
require_relative 'mastermind'

puts 'Choose one:-'
puts 'Enter 1 if you want Computer to Host'
puts 'Enter 2 if you want to be the Host and Computer to guess randomly'
puts "Enter 3 if you want to be the Host and Computer to guess according to Knuth's algorithm"

input = gets.chomp.to_i

case input

when 1
  Mastermind.new.play
when 2
  MastermindHost.new.play
when 3
  MastermindKnuth.new.play
else
  puts 'Invalid input!'
end
