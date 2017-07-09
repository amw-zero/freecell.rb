require_relative 'deck'

module Freecell
  # Holds the mutable state of the game that
  # moves can change
  class GameState
    attr_reader :cascades, :free_cells, :foundations

    def initialize(cascades = nil, free_cells = nil, foundations = nil)
      @cascades = cascades || partition_cascades(Deck.new.shuffle)
      @free_cells = free_cells || []
      empty_foundations = { hearts: [], diamonds: [], spades: [], clubs: [] }
      @foundations = foundations || empty_foundations
      @selected_card = nil
    end

    def apply(move)
      case move.type
      when :cascade_to_free_cell
        perform_cascade_to_free_cell_move(move)
      when :cascade_to_foundation
        perform_cascade_to_foundation_move(move)
      when :free_cell_to_foundation
        perform_free_cell_to_foundation_move(move)
      when :free_cell_to_cascade
        perform_free_cell_to_cascade_move(move)
      when :cascade_to_cascade
        perform_cascade_move(move)
      when :multi_card_cascade
        perform_multi_card_cascade_move(move)
      end
      self
    end

    private

    def partition_cascades(deck)
      full_cascade_cards, short_cascade_cards = deck.cards.each_slice(28).to_a
      full_cascades = full_cascade_cards.each_slice(7).to_a
      short_cascades = short_cascade_cards.each_slice(6).to_a
      full_cascades + short_cascades
    end

    def perform_cascade_move(move)
      return unless legal_cascade_to_cascade_move?(move)
      @cascades[move.dest_index] << @cascades[move.source_index].pop
    end

    def perform_cascade_to_free_cell_move(move)
      return unless @free_cells.length < 4
      @free_cells << @cascades[move.source_index].pop
    end

    def perform_free_cell_to_cascade_move(move)
      legal_move = legal_free_cell_to_cascade_move?(move)
      return unless legal_move && !@free_cells[move.source_index].nil?
      @cascades[move.dest_index] << @free_cells.delete_at(move.source_index)
    end

    def perform_cascade_to_foundation_move(move)
      return unless legal_foundation_move?(@cascades[move.source_index].last)
      source_card = @cascades[move.source_index].pop
      @foundations[source_card.suit] << source_card
    end

    def perform_free_cell_to_foundation_move(move)
      source_card = @free_cells[move.source_index]
      return unless legal_foundation_move?(source_card)
      @foundations[source_card.suit] << @free_cells.delete_at(move.source_index)
    end

    def legal_cascade_to_cascade_move?(move)
      source_card = @cascades[move.source_index].last
      return true if @cascades[move.dest_index].empty?
      dest_card = @cascades[move.dest_index].last
      legal_cascade_move?(source_card, dest_card)
    end

    def legal_free_cell_to_cascade_move?(move)
      source_card = @free_cells[move.source_index]
      dest_card = @cascades[move.dest_index].last
      legal_cascade_move?(source_card, dest_card)
    end

    def legal_cascade_move?(source_card, dest_card)
      return true if dest_card.nil?
      one_less_than_dest = source_card.rank == dest_card.rank - 1
      one_less_than_dest && source_card.opposite_color?(dest_card)
    end

    def legal_cascade_to_foundation_move?(move)
      legal_foundation_move?(@cascades[move.source_index].last)
    end

    def legal_free_cell_to_foundation_move?(move)
      legal_foundation_move?(@free_cells[move.source_index])
    end

    def legal_foundation_move?(source_card)
      return false if source_card.nil?
      return true if source_card.rank == 1
      return false if @foundations[source_card.suit].empty?
      foundation_card = @foundations[source_card.suit].last
      return true if foundation_card.nil?
      source_card.rank == foundation_card.rank + 1
    end
  end
end
