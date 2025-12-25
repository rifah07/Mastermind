# frozen_string_literal: true

# Computer is Player in this class
class MastermindHost
  COLORS = %w[red green blue orange yellow purple].freeze
  def initialize(code_length = 4, max_turns = 12)
    @code_length = code_length
    @max_turns = max_turns
    @all_code = COLORS.repeated_permutation(@code_length).to_a
  end

  # method for game play
  def play
    puts 'Welcome to Mastermind!'
    puts 'You are the host.'
    puts "Pick the secret code of #{@code_length} colors."
    puts "Available colors: #{COLORS.join(', ')}"
    puts "Computer have #{@max_turns} turns."

    possible_codes = @all_code.dup

    @max_turns.times do |turn|
      guess = possible_codes.sample
      # puts guess
      puts "\nTurn #{turn + 1}: Computer guesses : #{guess.join(', ')} "

      puts 'Enter feedback (exact, partial): '
      feedback = gets.chomp.split(',').map(&:strip).map(&:to_i)
      exact, partial = feedback

      if exact == @code_length
        puts "Computer cracked your code in #{turn + 1} turns!"
        return
      end

      # Filter possible codes based on feedback
      possible_codes.select! do |code|
        check_guess(code, guess) == [exact, partial]
      end
    end
    puts "\nComputer failed to crack your code"
  end

  private

  # method for checking if the guess matches the code
  def check_guess(secret_code, guess)
    exact = 0
    partial = 0
    secret_code_copy = secret_code.dup
    guess_code = guess.dup

    # count exact matches
    guess_code.each_with_index do |code, index|
      next unless secret_code_copy[index] == code

      exact += 1
      secret_code_copy[index] = nil
      guess_code[index] = nil
    end

    # count partial matches
    guess_code.compact.each do |code|
      if secret_code_copy.include?(code)
        partial += 1
        secret_code_copy[secret_code_copy.index(code)] = nil
      end
    end
    [exact, partial]
  end
end

MastermindHost.new.play
