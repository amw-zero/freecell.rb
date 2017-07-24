require 'state_machine'

module Freecell
  # rubocop:disable Metrics/ClassLength
  # Commands that are created from parsed user input and used to mutate
  # the GameState
  class GameStateCommand
    attr_reader :type, :source_index, :dest_index, :num_cards

    def initialize(type:, source_index: nil, dest_index: nil, num_cards: 1)
      @type = type
      @source_index = source_index
      @dest_index = dest_index
      @num_cards = num_cards
    end

    def ==(other)
      %i[type source_index dest_index num_cards].all? do |v|
        send(v) == other.send(v)
      end
    end
  end

  # Parses game information from a single user input character
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

    def undo_letter?(ch)
      ch == 'u'
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
      end

      event :receive_cascade_letter do
        transition %i[empty number] => :cascade_letter
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
            handle_number(ch)
          elsif @parser.free_cell_letter?(ch)
            handle_free_cell_letter(ch)
          elsif @parser.cascade_letter?(ch)
            handle_cascade_letter(ch)
          elsif @parser.undo_letter?(ch)
            handle_undo_letter
          else
            @next_state_event = :reset
            GameStateCommand.new(type: :reset_state)
          end
        end

        def handle_number(ch)
          @num_cards = ch.to_i
          @next_state_event = :receive_number
          GameStateCommand.new(type: :reset_state)
        end

        def handle_free_cell_letter(ch)
          @source_index = @parser.free_cell_to_i(ch)
          @next_state_event = :receive_free_cell_letter
          GameStateCommand.new(
            type: :free_cell_selection,
            source_index: @source_index
          )
        end

        def handle_cascade_letter(ch)
          @num_cards = 1
          @source_index = @parser.cascade_to_i(ch)
          @next_state_event = :receive_cascade_letter
          GameStateCommand.new(
            type: :cascade_selection,
            source_index: @source_index,
            num_cards: @num_cards
          )
        end

        def handle_undo_letter
          @next_state_event = :reset
          GameStateCommand.new(type: :undo)
        end
      end

      state :cascade_letter do
        def receive_ch(ch)
          @next_state_event = :reset
          if @parser.cascade_letter?(ch)
            handle_cascade_letter(ch)
          elsif @parser.foundation_char?(ch)
            handle_foundation_ch
          elsif @parser.free_cell_dest_letter?(ch)
            handle_free_cell_letter
          else
            GameStateCommand.new(type: :state_reset)
          end
        end

        def handle_cascade_letter(ch)
          GameStateCommand.new(
            type: :cascade_to_cascade,
            source_index: @source_index,
            dest_index: @parser.cascade_to_i(ch),
            num_cards: @num_cards
          )
        end

        def handle_foundation_ch
          GameStateCommand.new(
            type: :cascade_to_foundation,
            source_index: @source_index
          )
        end

        def handle_free_cell_letter
          GameStateCommand.new(
            type: :cascade_to_free_cell,
            source_index: @source_index
          )
        end
      end

      state :free_cell_letter do
        def receive_ch(ch)
          @next_state_event = :reset
          if @parser.cascade_letter?(ch)
            handle_cascade_letter(ch)
          elsif @parser.foundation_char?(ch)
            handle_foundation_ch
          else
            GameStateCommand.new(type: :reset_state)
          end
        end

        def handle_cascade_letter(ch)
          GameStateCommand.new(
            type: :free_cell_to_cascade,
            source_index: @source_index,
            dest_index: @parser.cascade_to_i(ch)
          )
        end

        def handle_foundation_ch
          GameStateCommand.new(
            type: :free_cell_to_foundation,
            source_index: @source_index
          )
        end
      end

      state :number do
        def receive_ch(ch)
          if @parser.cascade_letter?(ch)
            handle_cascade_letter(ch)
          else
            @next_state_event = :reset
            GameStateCommand.new(type: :reset_state)
          end
        end

        def handle_cascade_letter(ch)
          @source_index = @parser.cascade_to_i(ch)
          @next_state_event = :receive_cascade_letter
          GameStateCommand.new(
            type: :cascade_selection,
            source_index: @source_index,
            num_cards: @num_cards
          )
        end
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
  end
  # rubocop:enable Metrics/ClassLength
end
