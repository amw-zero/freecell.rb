require_relative "deck"

module Freecell
  class GameState
    attr_accessor :cascades

    def initialize
      @deck = Deck.new
      @cascades = []
    end

    def apply(move)
      type = move[0]
      @deck.cards.shuffle!
      case type
      when :free_cell
        #puts 'applying free cell move'
      when :cascade
        #puts 'applying cascade move'
      else
        #puts 'unrecognized move'
      end
      self
    end

    def to_s
      @deck.cards[0].to_s
    end
  end
end
