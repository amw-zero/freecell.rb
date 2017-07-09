require 'state_machine'

module Freecell
  class InputResult
    attr_reader :
    def initialize
    end
  end
  class GameMove
    attr_reader :type, :source_index, :dest_index, :num_cards

    def initialize(type:, source_index:, dest_index: nil, num_cards: 0)
      @type = type
      @source_index = source_index
      @dest_index = dest_index
      @num_cards = num_cards
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
v  end

  # Parse commandline input in a structured way
  class InputStateMachine
    attr_reader :source_index, :dest_index, :num_cards

    def initialize
      @source_index = 0
      @dest_index = 0
      @num_cards = 0
      @parser = CharacterParser.new
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
            [nil, :receive_number]
          elsif @parser.free_cell_letter?(ch)
            @source_index = @parser.free_cell_to_i(ch)
            value = { type: :selection, value: { free_cell: @source_index } }
            [value, :receive_free_cell_letter]
          elsif @parser.cascade_letter?(ch)
            value = { type: :selection, value: { cascade: @source_index } }
            @source_index = @parser.cascade_to_i(ch)
            [value, :receive_cascade_letter]
          else
            [nil, :reset]
          end
        end
      end

      state :cascade_letter do
        def receive_ch(ch)
          if @parser.cascade_letter?(ch)
            move = GameMove.new(
              type: :cascade_to_cascade,
              source_index: @source_index,
              dest_index: @parser.cascade_to_i(ch)
            )
            [{ type: :move, value: move }, :reset]
          elsif @parser.foundation_char?(ch)
            move = GameMove.new(
              type: :cascade_to_foundation,
              source_index: @source_index
            )
            [{ type: :move, value: move}, :reset]
          elsif @parser.free_cell_dest_letter?(ch)
            move = GameMove.new(
              type: :cascade_to_free_cell,
              source_index: @source_index
            )
            [{ type: :move, value: move }, :reset]
          else
            [nil, :reset]
          end
        end
      end

      state :free_cell_letter do
        def receive_ch(ch)
          if @parser.cascade_letter?(ch)
            move = GameMove.new(
              type: :free_cell_to_cascade,
              source_index: @source_index,
              dest_index: @parser.cascade_to_i(ch)
            )
            [{ type: :move, value: move }, :reset]
          elsif @parser.foundation_char?(ch)
            move = GameMove.new(
              type: :free_cell_to_foundation,
              source_index: @source_index
            )
            [{ type: :move, value: move }, :reset]
          else
            [nil, :reset]
          end
        end
      end

      state :number do
        def receive(ch)
        end
      end

      state :number_cascade_letter do
        def receive_ch(ch)
        end
      end
    end

    # { type: :move, value: @input}
    # { type: :quit }
    def handle_ch(ch)
      return { type: :quit } if @parser.quit?(ch)
      value, next_state_event = receive_ch(ch)
      send(next_state_event)
      value || {}
    end

    private

    def reset_state
      @source_index = nil
      @dest_index = nil
      @num_cards = 0
    end
  end
end
