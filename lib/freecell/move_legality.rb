module Freecell
  # Methods for determining the legality of moves
  class MoveLegality
    def initialize(cascades, free_cells, foundations)
      @cascades = cascades
      @free_cells = free_cells
      @foundations = foundations
    end

    def cascade_to_cascade_move?(command)
      return false if command.num_cards > num_movable_cards(command)
      return true if @cascades[command.dest_index].empty?
      cascade_cards_legal?(command)
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

    def cascade_cards_legal?(command)
      legal_cascade_move?(
        @cascades[command.source_index][-command.num_cards],
        @cascades[command.dest_index].last
      ) && all_source_cards_legal?(command)
    end

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

    def num_movable_cards(command)
      open_cascades = @cascades.select { |c| c.length.zero? }.length
      open_cascades -= 1 if @cascades[command.dest_index].empty?
      open_free_cells = 4 - @free_cells.length
      2**open_cascades + open_free_cells
    end

    def all_source_cards_legal?(command)
      source_cascade = @cascades[command.source_index]
      cards = source_cascade[-command.num_cards, command.num_cards]
      if cards.length > 1
        cards.each_cons(2).all? do |l, r|
          legal_cascade_move?(r, l)
        end
      else
        true
      end
    end
  end
end
