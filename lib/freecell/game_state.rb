require_relative "deck"

module Freecell
  class GameState
    attr_accessor :cascades

    def initialize
      deck = Deck.new
      @cascades = partition_cascades(deck)
      @free_cells = [ ]
      @foundations = []
    end

    def apply(move)
      type = move[0]
      case type
      when :free_cell
        @free_cells << Card.new(rand(13), [:hearts, :diamonds].shuffle.first)
      when :cascade
        #puts 'applying cascade move'
      else
        #puts 'unrecognized move'
      end
      self
    end

    def to_s
      @cascades.map { |c| c.map(&:to_s).join(" ") }.join(" ")
    end

    def card_grid
      grid = []

    end

    #private

    def partition_cascades(deck)
      cascades = []
      l_cascades_h = 7
      n_l_cascades = 4
      r_cascades_h = 6
      8.times do |i|
        cascade = []
        start = i < 4 ? i * l_cascades_h : 4 * l_cascades_h + (i-4) * ((i-5) *r_cascades_h)
        cascade = deck.cards.drop(start).take(i < 4 ? l_cascades_h : r_cascades_h)
        cascades << cascade
      end
      cascades
    end
  end
end
