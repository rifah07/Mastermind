# frozen_string_literal: true

# frozen_string_literal: true

require 'sinatra'
require_relative 'mastermind'
require_relative 'mastermind_host'
require_relative 'mastermind_knuth'

enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET', 'dev_secret_key_at_least_64_characters_long_for_development_only_change_in_production')

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
      possible_codes: game.instance_variable_get(:@possible_codes) || game.instance_variable_get(:@all_code).dup,
      current_turn: game.instance_variable_get(:@current_turn) || 0
    }
  end

  def deserialize_host(data)
    game = MastermindHost.new(data[:code_length], data[:max_turns])
    game.instance_variable_set(:@possible_codes, data[:possible_codes])
    game.instance_variable_set(:@current_turn, data[:current_turn])
    game
  end

  def serialize_knuth(game)
    {
      code_length: game.instance_variable_get(:@code_length),
      max_turns: game.instance_variable_get(:@max_turns),
      possible_codes: game.instance_variable_get(:@possible_codes),
      current_guess: game.instance_variable_get(:@current_guess),
      current_turn: game.instance_variable_get(:@current_turn) || 0
    }
  end

  def deserialize_knuth(data)
    game = MastermindKnuth.new(data[:code_length], data[:max_turns])
    game.instance_variable_set(:@possible_codes, data[:possible_codes])
    game.instance_variable_set(:@current_guess, data[:current_guess])
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
  guess = params[:guess].split(',').map(&:strip)

  game_data = session[:game]
  current_turn = game_data[:current_turn]

  if guess.length != game_data[:code_length]
    session[:error] = 'Insufficient guesses. Please enter exactly 4 colors.'
    redirect '/play/player'
    return
  end

  exact, partial = game.send(:check_guess, guess)

  session[:history] ||= []
  session[:history] << {
    turn: current_turn + 1,
    guess: guess,
    exact: exact,
    partial: partial
  }

  game_data[:current_turn] = current_turn + 1
  session[:game] = game_data

  if exact == game_data[:code_length]
    session[:result] = 'won'
    session[:message] = "Congratulations! You cracked the code in #{current_turn + 1} turns!"
  elsif current_turn + 1 >= game_data[:max_turns]
    session[:result] = 'lost'
    session[:message] = "Sorry, you ran out of turns. The code was: #{game_data[:secret_code].join(', ')}"
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

  if @current_turn == 0
    @current_guess = @mode == 'knuth' ? @game_data[:current_guess] : @game_data[:possible_codes].sample
  else
    @current_guess = session[:last_guess]
  end

  erb :host
end

# Host mode - submit feedback
post '/play/host/:mode/feedback' do
  mode = params[:mode]
  game = get_game
  game_data = session[:game]

  exact = params[:exact].to_i
  partial = params[:partial].to_i
  current_turn = game_data[:current_turn]

  # Get current guess
  if mode == 'knuth'
    current_guess = game_data[:current_guess]
  else
    current_guess = game_data[:possible_codes].sample
  end

  session[:history] ||= []
  session[:history] << {
    turn: current_turn + 1,
    guess: current_guess,
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

  # Filter possible codes
  if mode == 'knuth'
    possible_codes = game_data[:possible_codes].select do |code|
      game.send(:check_guess, code, current_guess) == [exact, partial]
    end
    game_data[:possible_codes] = possible_codes

    # Get next guess
    next_guess = game.send(:next_guess)
    game_data[:current_guess] = next_guess
    session[:last_guess] = next_guess
  else
    possible_codes = game_data[:possible_codes].select do |code|
      game.send(:check_guess, code, current_guess) == [exact, partial]
    end
    game_data[:possible_codes] = possible_codes

    if possible_codes.empty?
      session[:result] = 'invalid'
      session[:message] = 'No possible codes remain. The feedback may have been incorrect.'
    else
      session[:last_guess] = possible_codes.sample
    end
  end

  game_data[:current_turn] = current_turn + 1
  session[:game] = game_data

  if current_turn + 1 >= game_data[:max_turns] && !session[:result]
    session[:result] = 'lost'
    session[:message] = 'Computer failed to crack your code!'
  end

  redirect "/play/host/#{mode}"
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
