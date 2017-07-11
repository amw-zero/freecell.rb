require 'state_machine'

module Freecell
  class GameStateCommand
    attr_reader :type, :source_index, :dest_index, :num_cards

    def initialize(type:, source_index: nil, dest_index: nil, num_cards: 1)
      @type = type
      @source_index = source_index
      @dest_index = dest_index
      @num_cards = num_cards
    end

    def ==(rhs)
      %i(type source_index dest_index num_cards).all? { |v| self.send(v) == rhs.send(v) }
    end
  end

  class CharacterParser
    CARRIAGE_RETURN_BYTE = 13
    ASCII_LOWERCASE_A = 97
    ASCII_LOWERCASE_W = 119

    def quit?(ch)
      ch == 'q'
    end

    def free_cell_dest_letter?(ch)
      ch == ' '
    end

    def free_cell_letter?(ch)
      !(ch =~ /[w-z]/).nil?
    end

    def cascade_letter?(ch)
      !(ch =~ /[a-h]/).nil?
    end

    def foundation_char?(ch)
      ch == CARRIAGE_RETURN_BYTE
    end

    def number?(ch)
      !(ch =~ /[2-9]/).nil?
    end

    def cascade_to_i(ch)
      ch.bytes.first - ASCII_LOWERCASE_A
    end

    def free_cell_to_i(char)
      char.bytes.first - ASCII_LOWERCASE_W
    end
  end

  # Parse commandline input in a structured way
  class InputStateMachine
    attr_reader :source_index, :dest_index, :num_cards

    def initialize
      @source_index = 0
      @dest_index = 0
      @num_cards = 0
      @parser = CharacterParser.new
      @next_state_event = nil
      super
    end

    state_machine :state, initial: :empty do
      event :receive_number do
        transition empty: :number
        transition all - :empty => :empty
      end

      event :receive_cascade_letter do
        transition empty: :cascade_letter,
                   number: :number_cascade_letter
      end

      event :receive_free_cell_letter do
        transition empty: :free_cell_letter
      end

      event :reset do
        transition all => :empty
      end

      after_transition any => :empty, do: :reset_state

      state :empty do
        def receive_ch(ch)
          if @parser.number?(ch)
            @num_cards = ch.to_i
            @next_state_event = :receive_number
          elsif @parser.free_cell_letter?(ch)
            @source_index = @parser.free_cell_to_i(ch)
            @next_state_event = :receive_free_cell_letter
            selected_free_cell_result
          elsif @parser.cascade_letter?(ch)
            @source_index = @parser.cascade_to_i(ch)
            @next_state_event = :receive_cascade_letter
            selected_cascade_result
          else
            @next_state_event = :reset
            reset_result
          end
        end
      end

      state :cascade_letter do
        def receive_ch(ch)
          @next_state_event = :reset
          if @parser.cascade_letter?(ch)
            cascade_to_cascade_result(ch)
          elsif @parser.foundation_char?(ch)
            cascade_to_foundation_result
          elsif @parser.free_cell_dest_letter?(ch)
            cascade_to_free_cell_result
          else
            reset_result
          end
        end
      end

      state :free_cell_letter do
        def receive_ch(ch)
          @next_state_event = :reset
          if @parser.cascade_letter?(ch)
            free_cell_to_cascade_result(ch)
          elsif @parser.foundation_char?(ch)
            free_cell_to_foundation_result
          else
            reset_result
          end
        end
      end

      state :number do
        def receive(ch); end
      end
    end

    def handle_ch(ch)
      return GameStateCommand.new(type: :quit) if @parser.quit?(ch)
      command = receive_ch(ch)
      send(@next_state_event)
      command || nil
    end

    private

    def reset_state
      @source_index = nil
      @dest_index = nil
      @num_cards = 0
    end

    def cascade_to_cascade_result(ch)
      GameStateCommand.new(
        type: :cascade_to_cascade,
        source_index: @source_index,
        dest_index: @parser.cascade_to_i(ch)
      )
    end

    def cascade_to_foundation_result
      GameStateCommand.new(
        type: :cascade_to_foundation,
        source_index: @source_index
      )
    end

    def cascade_to_free_cell_result
      GameStateCommand.new(
        type: :cascade_to_free_cell,
        source_index: @source_index
      )
    end

    def free_cell_to_cascade_result(ch)
      GameStateCommand.new(
        type: :free_cell_to_cascade,
        source_index: @source_index,
        dest_index: @parser.cascade_to_i(ch)
      )
    end

    def free_cell_to_foundation_result
      GameStateCommand.new(
        type: :free_cell_to_foundation,
        source_index: @source_index
      )
    end

    def selected_free_cell_result
      GameStateCommand.new(
        type: :free_cell_selection,
        source_index: @source_index
      )
    end

    def selected_cascade_result
      GameStateCommand.new(
        type: :cascade_selection,
        source_index: @source_index
      )
    end

    def reset_result
      GameStateCommand.new(
        type: :state_reset
      )
    end
  end
end
