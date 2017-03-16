module Freecell
  class MoveParser
    def parse_input(input)
      case
      when cascade_move?(input)
        parse_cascade_move(input)
      when free_cell_move?(input)
        #puts 'Free cell move'
        [:free_cell, 0 , 0]
      else
        #puts 'nope'
        nil
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
      source, dest = input.split("")
      [:cascade, source, dest]
    end
  end

end
