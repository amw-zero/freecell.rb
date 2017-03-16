module Freecell
  class MoveParser
    def parse_input(input)
      case
      when cascade_move?(input)
        puts 'Cascade move!'
        [:cascade, 0, 0]
      when free_cell_move?(input)
        puts 'Free cell move'
        [:free_cell, 0 , 0]
      else
        puts 'nope'
        nil
      end
    end

    def cascade_move?(input)
      !(input =~ /[a-h]{2}/).nil?
    end

    def free_cell_move?(input)
      !(input =~ /[a-h][wz]/).nil?
    end
  end

end
