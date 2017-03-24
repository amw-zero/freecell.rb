module Freecell
  # Takes in raw input and returns a move
  # that can be applied to a game state.
  class MoveParser
    def parse_input(input)
      if cascade_move?(input)
        parse_cascade_move(input)
      elsif cascade_to_free_cell_move?(input)
        parse_cascade_to_freecell_move(input)
      elsif free_cell_to_cascade_move?(input)
        parse_free_cell_to_cascade_move(input)
      elsif cascade_to_foundation_move?(input)
        parse_cascade_to_foundation_move(input)
      elsif free_cell_to_foundation_move?(input)
        parse_free_cell_to_foundation_move(input)
      end
    end

    private

    def cascade_move?(input)
      !(input =~ /[a-h]{2}/).nil?
    end

    def cascade_to_free_cell_move?(input)
      !(input =~ /[a-h]\ /).nil?
    end

    def free_cell_to_cascade_move?(input)
      !(input =~ /[w-z][a-h]/).nil?
    end

    def cascade_to_foundation_move?(input)
      # Regex for \n not working
      carriage_return_byte = 13
      !(input =~ /^[a-h]/).nil? && input.bytes.last == carriage_return_byte
    end

    def free_cell_to_foundation_move?(input)
      carriage_return_byte = 13
      !(input =~ /^[w-z]/).nil? && input.bytes.last == carriage_return_byte
    end

    def parse_cascade_move(input)
      source, dest = input.split('').map { |c| cascade_to_i(c) }
      [:cascade, source, dest]
    end

    def parse_cascade_to_freecell_move(input)
      source = cascade_to_i(input.split('').first)
      [:cascade_to_free_cell, source]
    end

    def parse_free_cell_to_cascade_move(input)
      source, dest = input.split('')
      source = free_cell_to_i(source)
      dest = cascade_to_i(dest)
      [:free_cell_to_cascade, source, dest]
    end

    def parse_cascade_to_foundation_move(input)
      source = cascade_to_i(input.split('').first)
      [:cascade_to_foundation, source]
    end

    def parse_free_cell_to_foundation_move(input)
      source = free_cell_to_i(input.split('').first)
      [:free_cell_to_foundation, source]
    end

    # Use ascii for lowercase a to
    # offset the char to an index
    def cascade_to_i(char)
      ascii_a = 97
      char.bytes.first - ascii_a
    end

    def free_cell_to_i(char)
      ascii_w = 119
      char.bytes.first - ascii_w
    end
  end
end
