module Freecell
  # Methods for determining the legality of moves
  class MoveLegality
    def initialize(cascades, free_cells, foundations)
      @cascades = cascades
      @free_cells = free_cells
      @foundations = foundations
    end

    def cascade_to_cascade_move?(command)
      source_card = @cascades[command.source_index].last
      return true if @cascades[command.dest_index].empty?
      dest_card = @cascades[command.dest_index].last
      legal_cascade_move?(source_card, dest_card)
    end

    def cascade_to_free_cell_move?
      @free_cells.length < 4
    end

    def free_cell_to_cascade_move?(command)
      source_card = @free_cells[command.source_index]
      dest_card = @cascades[command.dest_index].last
      legal_move = legal_cascade_move?(source_card, dest_card)
      legal_move && !@free_cells[command.source_index].nil?
    end

    def cascade_to_foundation_move?(command)
      legal_foundation_move?(@cascades[command.source_index].last)
    end

    def free_cell_to_foundation_move?(command)
      legal_foundation_move?(@free_cells[command.source_index])
    end

    private

    def legal_foundation_move?(source_card)
      return false if source_card.nil?
      return true if source_card.rank == 1
      return false if @foundations[source_card.suit].empty?
      foundation_card = @foundations[source_card.suit].last
      return true if foundation_card.nil?
      source_card.rank == foundation_card.rank + 1
    end

    def legal_cascade_move?(source_card, dest_card)
      return true if dest_card.nil?
      one_less_than_dest = source_card.rank == dest_card.rank - 1
      one_less_than_dest && source_card.opposite_color?(dest_card)
    end
  end
end
