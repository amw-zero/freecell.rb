require_relative 'deck'

module Freecell
  # Holds the mutable state of the game that
  # moves can change
  class GameState
    attr_reader :cascades, :free_cells, :foundations

    def initialize
      @cascades = partition_cascades(Deck.new)
      @free_cells = []
      @foundations = make_foundations
    end

    def apply(move)
      case move[0]
      when :cascade_to_free_cell
        perform_cascade_to_free_cell_move(move)
      when :cascade_to_foundation
        perform_cascade_to_foundation_move(move)
      when :free_cell_to_cascade_move
        perform_free_cell_to_cascade_move(move)
      when :cascade
        perform_cascade_move(move)
      end
      self
    end

    def printable_card_grid
      max_length = @cascades.map(&:length).max
      @cascades.map do |c|
        c + (0...max_length - c.count).map { '   ' }
      end.transpose
    end

    private

    def make_foundations
      {
        hearts: [],
        diamonds: [],
        spades: [],
        clubs: []
      }
    end

    def partition_cascades(deck)
      full_cascade_cards, short_cascade_cards = deck.cards.each_slice(28).to_a
      full_cascades = full_cascade_cards.each_slice(7).to_a
      short_cascades = short_cascade_cards.each_slice(6).to_a
      full_cascades + short_cascades
    end

    def perform_cascade_move(move)
      return unless legal_cascade_to_cascade_move?(move)
      _, source, dest = move
      @cascades[dest] << @cascades[source].pop
    end

    def perform_cascade_to_free_cell_move(move)
      return unless @free_cells.length < 4
      _, source = move
      @free_cells << @cascades[source].pop
    end

    def perform_free_cell_to_cascade_move(move)
      _, source, dest = move
      legal_move = legal_free_cell_to_cascade_move?(move)
      return unless legal_move && !@free_cells[source].nil?
      @cascades[dest] << @free_cells.delete_at(source)
    end

    def perform_cascade_to_foundation_move(move)
      return unless legal_foundation_move?(move)
      _, source = move
      source_card = @cascades[source].pop
      @foundations[source_card.suit] << source_card
    end

    def legal_cascade_to_cascade_move?(move)
      _, source, dest = move
      source_card = @cascades[source].last
      return true if @cascades[dest].empty?
      dest_card = @cascades[dest].last
      legal_cascade_move?(source_card, dest_card)
    end

    def legal_free_cell_to_cascade_move?(move)
      _, source, dest = move
      source_card = @free_cells[source]
      dest_card = @cascades[dest].last
      legal_cascade_move?(source_card, dest_card)
    end

    def legal_cascade_move?(source_card, dest_card)
      one_less_than_dest = source_card.rank == dest_card.rank - 1
      one_less_than_dest && source_card.opposite_color?(dest_card)
    end

    def legal_foundation_move?(move)
      _, source = move
      source_card = @cascades[source].last
      return true if source_card.rank == 1
      return false if @foundations[source_card.suit].empty?
      foundation_card = @foundations[source_card.suit].last
      source_card.rank == foundation_card.rank + 1
    end
  end
end
