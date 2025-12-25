# frozen_string_literal: true

# MAIN CLASS
class Mastermind
  COLORS = %w[red green blue orange yellow purple].freeze
  def initialize(code_length = 4, max_turns = 12)
    @code_length = code_length
    @max_turns = max_turns
    @secret_code = Array.new(code_length) {COLORS.sample}
  end

  # method for game play
  def play
    puts 'Welcome to Mastermind!'
    puts "Try to guess the secret code of #{@code_length} colors."
    puts "Available colors: #{COLORS.join(', ')}"
    puts "You have #{@max_turns} turns."

    @max_turns.times do |turn|
      puts "\nTurn #{turn+1}: Enter your guess (comma-separated) : "
      guess = gets.chomp.split(',').map(&:strip)

      unless guess.length == @secret_code.length
        puts 'Insufficient guesses.'
        redo
      end

      exact, partial = check_guess(guess)
      puts "Exact matches: #{exact}.\nPartial matches: #{partial}."

      if exact == @code_length
        puts 'Congratulations, you cracked the code!'
        return
      end
    end
    puts "\nSorry, you ran out of turns. The code was: #{@secret_code.join(', ')}"
  end

  private

  # method for checking if the guess matches the code of host
  def check_guess(guess)
    exact = 0
    partial = 0
    secret_code_copy = @secret_code.dup

    # count exact matches
    guess.each_with_index do |code, index|
      next unless secret_code_copy[index] == code

      exact += 1
      secret_code_copy[index] = nil
      guess[index] = nil
    end

    # count partial matches
    guess.compact.each do |code|
      if secret_code_copy.include?(code)
        partial += 1
        secret_code_copy[secret_code_copy.index(code)] = nil
      end
    end
    [exact, partial]
  end
end

# run the game
Mastermind.new.play
