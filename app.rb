# frozen_string_literal: true

require 'sinatra'
require 'json'
require_relative 'mastermind'
require_relative 'mastermind_host'
require_relative 'mastermind_knuth'

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET', 'dev_secret_key_at_least_64_characters_long_for_development_only_change_in_production')

# Increase session size limit
use Rack::Session::Cookie,
    key: 'mastermind.session',
    secret: settings.session_secret,
    same_site: :lax,
    max_age: 86400  # 24 hours

# Helper to get or create game instance
helpers do
  def get_game
    case session[:game_mode]
    when 'player'
      session[:game] ||= serialize_mastermind(Mastermind.new)
      deserialize_mastermind(session[:game])
    when 'host_random'
      session[:game] ||= serialize_host(MastermindHost.new)
      deserialize_host(session[:game])
    when 'host_knuth'
      session[:game] ||= serialize_knuth(MastermindKnuth.new)
      deserialize_knuth(session[:game])
    end
  end

  def serialize_mastermind(game)
    {
      code_length: game.instance_variable_get(:@code_length),
      max_turns: game.instance_variable_get(:@max_turns),
      secret_code: game.instance_variable_get(:@secret_code),
      current_turn: game.instance_variable_get(:@current_turn) || 0
    }
  end

  def deserialize_mastermind(data)
    game = Mastermind.new(data[:code_length], data[:max_turns])
    game.instance_variable_set(:@secret_code, data[:secret_code])
    game.instance_variable_set(:@current_turn, data[:current_turn])
    game
  end

  def serialize_host(game)
    {
      code_length: game.instance_variable_get(:@code_length),
      max_turns: game.instance_variable_get(:@max_turns),
      current_turn: game.instance_variable_get(:@current_turn) || 0
    }
  end

  def deserialize_host(data)
    game = MastermindHost.new(data[:code_length], data[:max_turns])
    game.instance_variable_set(:@current_turn, data[:current_turn])
    game
  end

  def serialize_knuth(game)
    {
      code_length: game.instance_variable_get(:@code_length),
      max_turns: game.instance_variable_get(:@max_turns),
      current_turn: game.instance_variable_get(:@current_turn) || 0
    }
  end

  def deserialize_knuth(data)
    game = MastermindKnuth.new(data[:code_length], data[:max_turns])
    game.instance_variable_set(:@current_turn, data[:current_turn])
    game
  end
end

# Home page
get '/' do
  erb :index
end

# Start game as player (computer hosts)
post '/start/player' do
  session.clear
  session[:game_mode] = 'player'
  session[:game] = serialize_mastermind(Mastermind.new)
  session[:history] = []
  redirect '/play/player'
end

# Start game as host (computer guesses)
post '/start/host/:mode' do
  session.clear
  mode = params[:mode] # 'random' or 'knuth'
  session[:game_mode] = mode == 'knuth' ? 'host_knuth' : 'host_random'

  if mode == 'knuth'
    session[:game] = serialize_knuth(MastermindKnuth.new)
  else
    session[:game] = serialize_host(MastermindHost.new)
  end

  session[:history] = []
  redirect "/play/host/#{mode}"
end

# Player mode - show guess form
get '/play/player' do
  @game_data = session[:game]

  # Handle case where session was dropped
  unless @game_data
    session[:error] = 'Session expired. Please start a new game.'
    redirect '/'
    return
  end

  @history = session[:history] || []
  @current_turn = @game_data[:current_turn]
  @max_turns = @game_data[:max_turns]
  erb :player
end

# Player mode - submit guess
post '/play/player/guess' do
  game = get_game

  # From dropdowns: params[:guess] is already an Array
  guess = params[:guess]

  game_data = session[:game]
  current_turn = game_data[:current_turn]

  # Defensive validation
  unless guess.is_a?(Array) && guess.length == game_data[:code_length]
    session[:error] = "Please select exactly #{game_data[:code_length]} colors."
    redirect '/play/player'
    return
  end

  # Store a clean copy BEFORE any logic touches it
  clean_guess = guess.dup

  exact, partial = game.send(:check_guess, guess)

  # Save history safely
  session[:history] ||= []
  session[:history] << {
    turn: current_turn + 1,
    guess_str: clean_guess.join('|'),
    exact: exact,
    partial: partial
  }

  # Advance turn
  game_data[:current_turn] = current_turn + 1
  session[:game] = game_data

  # Win / lose conditions
  if exact == game_data[:code_length]
    session[:result] = 'won'
    session[:message] =
      "Congratulations! You cracked the code in #{current_turn + 1} turns!"
  elsif current_turn + 1 >= game_data[:max_turns]
    session[:result] = 'lost'
    session[:message] =
      "Sorry, you ran out of turns. The code was: #{game_data[:secret_code].join(', ')}"
  end

  redirect '/play/player'
end


# Host mode - show computer's guess
get '/play/host/:mode' do
  @mode = params[:mode]
  @game_data = session[:game]

  # Handle case where session was dropped
  unless @game_data
    session[:error] = 'Session expired. Please start a new game.'
    redirect '/'
    return
  end

  @history = session[:history] || []
  @current_turn = @game_data[:current_turn]
  @max_turns = @game_data[:max_turns]

  # Get possible codes count
  @possible_count = session[:possible_count]

  # Get or generate current guess
  if @current_turn == 0
    # First guess
    if @mode == 'knuth'
      guess_array = %w[red red blue blue]
    else
      game = get_game
      guess_array = game.instance_variable_get(:@all_code).sample
    end
    # Store as string to prevent array corruption
    session[:current_guess_str] = guess_array.join('|')
    session[:feedback_history] = []
    @current_guess = guess_array
  else
    # Retrieve from string
    @current_guess = session[:current_guess_str].split('|')
  end

  erb :host
end

# Host mode - submit feedback
post '/play/host/:mode/feedback' do
  mode = params[:mode]
  game_data = session[:game]

  exact = params[:exact].to_i
  partial = params[:partial].to_i
  current_turn = game_data[:current_turn]

  # Get current guess (stored as string, convert to array)
  current_guess = session[:current_guess_str].split('|')

  # Store feedback history (we'll use this to rebuild filtered codes)
  session[:feedback_history] ||= []
  session[:feedback_history] << {
    guess: current_guess.join('|'),  # Store as string
    exact: exact,
    partial: partial
  }

  # Store display history with guess as string
  session[:history] ||= []
  session[:history] << {
    turn: current_turn + 1,
    guess_str: current_guess.join('|'),  # Store as string instead of array
    exact: exact,
    partial: partial
  }

  if exact == game_data[:code_length]
    session[:result] = 'won'
    session[:message] = "Computer cracked your code in #{current_turn + 1} turns!"
    game_data[:current_turn] = current_turn + 1
    session[:game] = game_data
    redirect "/play/host/#{mode}"
    return
  end

  # Get game instance for check_guess method
  game = get_game
  all_codes = game.instance_variable_get(:@all_code)

  # Rebuild filtered codes from all feedback history
  possible_codes = all_codes.select do |code|
    session[:feedback_history].all? do |fb|
      fb_guess = fb[:guess].split('|')
      game.send(:check_guess, code, fb_guess) == [fb[:exact], fb[:partial]]
    end
  end

  if possible_codes.empty?
    session[:result] = 'invalid'
    session[:message] = 'No possible codes remain. The feedback may have been incorrect.'
    game_data[:current_turn] = current_turn + 1
    session[:game] = game_data
    redirect "/play/host/#{mode}"
    return
  end

  # Generate next guess
  if mode == 'knuth'
    # Use minimax to find next guess
    best_guess = find_best_guess_minimax(all_codes, possible_codes, game)
  else
    # Random guess from filtered codes
    best_guess = possible_codes.sample
  end

  # Store as string to avoid array corruption in session
  session[:current_guess_str] = best_guess.join('|')
  session[:possible_count] = possible_codes.length

  game_data[:current_turn] = current_turn + 1
  session[:game] = game_data

  if current_turn + 1 >= game_data[:max_turns] && !session[:result]
    session[:result] = 'lost'
    session[:message] = 'Computer failed to crack your code!'
  end

  redirect "/play/host/#{mode}"
end

# Helper method for Knuth's minimax
def find_best_guess_minimax(all_codes, possible_codes, game)
  return possible_codes.first if possible_codes.length == 1

  best_guess = nil
  best_score = Float::INFINITY

  # Sample candidates to check (balance between speed and accuracy)
  candidates = possible_codes.length < 50 ? all_codes.sample(500) : possible_codes

  candidates.each do |candidate|
    partitions = Hash.new(0)
    possible_codes.each do |code|
      feedback = game.send(:check_guess, code, candidate)
      partitions[feedback] += 1
    end
    worst_case = partitions.values.max || 0

    # Prefer guesses from possible_codes if scores are equal
    if worst_case < best_score || (worst_case == best_score && possible_codes.include?(candidate))
      best_score = worst_case
      best_guess = candidate
    end
  end

  best_guess || possible_codes.sample
end

# Reset game
post '/reset' do
  session.clear
  redirect '/'
end


=begin
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
=end
