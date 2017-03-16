module Freecell
  class GameState
    attr_accessor :cards

    def initialize
      @cards = [1,2,3,4]
    end

    def apply(move)
      type = move[0]
      case type
      when :free_cell
        puts 'applying free cell move'
      when :cascade
        puts 'applying cascade move'
      else
        puts 'unrecognized move'
      end
      self
    end
  end
end
