require_relative 'spec_helper'

RSpec.describe Mastermind do
  let(:game) { Mastermind.new(4, 12) }

  before do
    game.instance_variable_set(:@secret_code, %w[red blue green yellow])
  end

  it 'counts exact matches correctly' do
    exact, partial = game.send(:check_guess, %w[red blue green yellow])
    expect(exact).to eq(4)
    expect(partial).to eq(0)
  end

  it 'counts partial matches correctly' do
    exact, partial = game.send(:check_guess, %w[blue red yellow green])
    expect(exact).to eq(0)
    expect(partial).to eq(4)
  end

  it 'does not mutate the guess array' do
    guess = %w[red blue green yellow]
    game.send(:check_guess, guess)
    expect(guess).to eq(%w[red blue green yellow])
  end
end
