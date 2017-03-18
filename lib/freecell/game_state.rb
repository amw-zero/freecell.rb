require_relative 'deck'

module Freecell
  # Holds the mutable state of the game that
  # moves can change
  class GameState
    attr_reader :cascades, :free_cells

    def initialize
      deck = Deck.new
      @cascades = partition_cascades(deck)
      @free_cells = []
      @foundations = []
    end

    def apply(move)
      case move[0]
      when :cascade_to_free_cell
        perform_cascade_to_freecell_move(move)
      when :cascade
        perform_cascade_move(move)
      end
      self
    end

    def to_s
      @cascades.map { |c| c.map(&:to_s).join(' ') }.join(' ')
    end

    def printable_card_grid
      max_length = @cascades.map(&:length).max
      @cascades.map do |c|
        c + (0...max_length - c.count).map { '   ' }
      end.transpose
    end

    private

    def partition_cascades(deck)
      full_cascade_cards, short_cascade_cards = deck.cards.each_slice(28).to_a
      full_cascades = full_cascade_cards.each_slice(7).to_a
      short_cascades = short_cascade_cards.each_slice(6).to_a
      full_cascades + short_cascades
    end

    def perform_cascade_move(move)
      return unless legal_cascade_move?(move)
      _, source, dest = move
      @cascades[dest] << @cascades[source].pop
    end

    def perform_cascade_to_freecell_move(move)
      return unless @free_cells.length < 4
      _, source = move
      @free_cells << @cascades[source].pop
    end

    def legal_cascade_move?(move)
      _, source, dest = move
      source_card = @cascades[source].last
      dest_card = @cascades[dest].last
      source_card.can_move_to?(dest_card)
    end
  end
end
