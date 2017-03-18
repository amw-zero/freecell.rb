require_relative "deck"

module Freecell
  class GameState
    attr_accessor :cascades

    def initialize
      deck = Deck.new
      @cascades = partition_cascades(deck)
      @free_cells = []
      @foundations = []
    end

    def apply(move)
      type = move[0]
      case type
      when :free_cell
        @free_cells << Card.new(rand(13), [:hearts, :diamonds].shuffle.first)
      when :cascade
        perform_cascade_move(move)
      else
        #puts 'unrecognized move'
      end
      self
    end

    def to_s
      @cascades.map { |c| c.map(&:to_s).join(" ") }.join(" ")
    end

    def printable_card_grid
      max_length = @cascades.map(&:length).max
      @cascades.map { |c| c += (0...max_length-c.count).map { '   ' } }.transpose
    end

    #private

    def partition_cascades(deck)
      full_cascade_cards, short_cascade_cards = deck.cards.each_slice(28).to_a
      full_cascades = full_cascade_cards.each_slice(7).to_a
      short_cascades = short_cascade_cards.each_slice(6).to_a
      full_cascades += short_cascades
    end

    def perform_cascade_move(move)
      _, source, dest = move
      card = @cascades[source].pop
      @cascades[dest] << card
    end
  end
end
