require 'state_machine'

module Freecell
  # Parse commandline input in a structured way
  class InputStateMachine
    def initialize
      @input = ''
      super
    end

    state_machine :state, initial: :empty do
      event :receive_number do
        transition empty: :number
        transition all - :empty => :empty
      end

      event :receive_letter do
        transition empty: :one_letter,
                   number: :number_one_letter
      end

      event :reset do
        transition all => :empty
      end

      after_transition any => :empty, do: :reset_input

      state :empty do
        def receivable?(ch)
          number?(ch) || free_cell_letter?(ch) || cascade_letter?(ch)
        end

        def transition_event(ch)
          if number?(ch)
            :receive_number
          elsif free_cell_letter?(ch) || cascade_letter?(ch)
            :receive_letter
          end
        end
      end

      state :one_letter do
        def receivable?(ch)
          destination_char?(ch)
        end

        def transition_event(*) end

        def terminal_length
          2
        end
      end

      state :number_one_letter do
        def receivable?(ch)
          destination_char?(ch)
        end

        def transition_event(*)
          :receive_letter
        end

        def terminal_length
          3
        end
      end

      state :number do
        def receivable?(ch)
          free_cell_letter?(ch)
        end

        def transition_event(*)
          :receive_letter
        end

        def terminal_length; end
      end
    end

    # { type: :move, input: @input}
    # { type: :quit }
    # { type: :continue }
    def handle_ch(ch)
      if receivable?(ch)
        @input << ch
        send(transition_event(ch)) if transition_event(ch)
        check_input_length
      elsif quit?(ch)
        { type: :quit }
      else
        reset
        {}
      end
    end

    private

    def check_input_length
      if @input.length == terminal_length
        ret = { type: :move, input: @input }
        reset
        ret
      else
        {}
      end
    end

    def reset_input
      @input = ''
    end

    def quit?(ch)
      ch == 'q'
    end

    def free_cell_letter?(ch)
      !(ch =~ /[w-z]/).nil?
    end

    def cascade_letter?(ch)
      !(ch =~ /[a-h]/).nil?
    end

    def destination_char?(ch)
      carriage_return_byte = 13
      !(ch =~ /\ |[a-h]/).nil? || ch == carriage_return_byte
    end

    def number?(ch)
      !(ch =~ /[2-9]/).nil?
    end
  end
end
