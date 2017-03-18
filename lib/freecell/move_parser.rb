module Freecell
  # Takes in raw input and returns a move
  # that can be applied to a game state.
  class MoveParser
    def parse_input(input)
      if cascade_move?(input)
        parse_cascade_move(input)
      elsif free_cell_move?(input)
        [:free_cell, 0, 0]
      end
    end

    private

    def cascade_move?(input)
      !(input =~ /[a-h]{2}/).nil?
    end

    def free_cell_move?(input)
      !(input =~ /[a-h][wz]/).nil?
    end

    def parse_cascade_move(input)
      source, dest = input.split('').map { |c| cascade_to_i(c) }
      [:cascade, source, dest]
    end

    # Use ascii for lowercase a to
    # offset the char to an index
    def cascade_to_i(char)
      ascii_a = 97
      char.bytes.first - ascii_a
    end
  end
end
