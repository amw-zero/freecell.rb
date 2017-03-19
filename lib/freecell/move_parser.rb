module Freecell
  # Takes in raw input and returns a move
  # that can be applied to a game state.
  class MoveParser
    def parse_input(input)
      if cascade_move?(input)
        parse_cascade_move(input)
      elsif cascade_to_free_cell_move?(input)
        parse_cascade_to_freecell_move(input)
      elsif to_foundation_move?(input)
        parse_to_foundation_move(input)
      end
    end

    private

    def cascade_move?(input)
      !(input =~ /[a-h]{2}/).nil?
    end

    def cascade_to_free_cell_move?(input)
      !(input =~ /[a-h]\ /).nil?
    end

    def to_foundation_move?(input)
      # Regex for \n not working
      !(input =~ /^[a-h]/).nil? && input.bytes.last == 13
    end

    def parse_cascade_move(input)
      source, dest = input.split('').map { |c| cascade_to_i(c) }
      [:cascade, source, dest]
    end

    def parse_cascade_to_freecell_move(input)
      source = cascade_to_i(input.split('').first)
      [:cascade_to_free_cell, source]
    end

    def parse_to_foundation_move(input)
      source = cascade_to_i(input.split('').first)
      [:cascade_to_foundation, source]
    end

    # Use ascii for lowercase a to
    # offset the char to an index
    def cascade_to_i(char)
      ascii_a = 97
      char.bytes.first - ascii_a
    end
  end
end
