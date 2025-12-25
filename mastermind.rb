# frozen_string_literal: true

# MAIN CLASS
class Mastermind
  COLORS = %w[red green blue orange yellow purple].freeze
  def initialize(code_length = 4, max_turns= 12)
    @code_length = code_length
    @max_turns = max_turns
    @secret_code = Array.new(code_length) {COLORS.sample}
  end
end
