require 'state_machine'

module Freecell
  # Parse commandline input in a structured way
  class InputStateMachine
    attr_accessor :input

    def initialize
      @input = ''
    end

    state_machine :state, initial: :blank do

      event :receive_cascade_letter do
        transition blank: :cascade_move
      end

      state :blank do
      end

      state :cascade_move
    end

    def handle_input(input)
      { type: :quit }
    end

    def input_valid?(input)
      !(input =~ /^[a-h]|[w-z]|\d/).nil?
    end
  end
end
