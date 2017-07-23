require_relative 'deck'
require_relative 'move_legality'

module Freecell
  # Holds the mutable state of the game that
  # moves can change
  class GameState
    attr_reader :cascades, :free_cells, :foundations, :selected_cards,
                :num_moves

    def initialize(cascades = nil, free_cells = nil, foundations = nil)
      @cascades = cascades || partition_cascades(Deck.new.shuffle)
      @free_cells = free_cells || []
      empty_foundations = { hearts: [], diamonds: [], spades: [], clubs: [] }
      @foundations = foundations || empty_foundations
      @selected_cards = nil
      @legality = MoveLegality.new(@cascades, @free_cells, @foundations)
      @num_moves = 0
    end

    def apply(command)
      remove_selected_cards
      action = command_to_action[command.type]
      return self unless action
      send(action, command)
      self
    end

    private

    def command_to_action
      {
        cascade_to_free_cell:    :perform_cascade_to_free_cell_command,
        cascade_to_foundation:   :perform_cascade_to_foundation_command,
        free_cell_to_foundation: :perform_free_cell_to_foundation_command,
        free_cell_to_cascade:    :perform_free_cell_to_cascade_command,
        cascade_to_cascade:      :perform_cascade_command,
        multi_card_cascade:      :perform_multi_card_cascade_commmand,
        free_cell_selection:     :perform_free_cell_selection,
        cascade_selection:       :perform_cascade_selection
      }
    end

    def partition_cascades(deck)
      full_cascade_cards, short_cascade_cards = deck.cards.each_slice(28).to_a
      full_cascades = full_cascade_cards.each_slice(7).to_a
      short_cascades = short_cascade_cards.each_slice(6).to_a
      full_cascades + short_cascades
    end

    def perform_cascade_command(command)
      return unless @legality.cascade_to_cascade_move?(command)
      with_num_move_incrementing do
        cards_to_move = command.num_cards.times.each_with_object([]) do |_, c|
          c << @cascades[command.source_index].pop
        end.reverse
        @cascades[command.dest_index] += cards_to_move
      end
    end

    def perform_cascade_to_free_cell_command(command)
      return unless @legality.cascade_to_free_cell_move?
      with_num_move_incrementing do
        @free_cells << @cascades[command.source_index].pop
      end
    end

    def perform_free_cell_to_cascade_command(command)
      return unless @legality.free_cell_to_cascade_move?(command)
      with_num_move_incrementing do
        @cascades[command.dest_index] << @free_cells.delete_at(
          command.source_index
        )
      end
    end

    def perform_cascade_to_foundation_command(command)
      return unless @legality.cascade_to_foundation_move?(command)
      with_num_move_incrementing do
        source_card = @cascades[command.source_index].pop
        @foundations[source_card.suit] << source_card
      end
    end

    def perform_free_cell_to_foundation_command(command)
      return unless @legality.free_cell_to_foundation_move?(command)
      with_num_move_incrementing do
        source_suit = @free_cells[command.source_index].suit
        @foundations[source_suit] << @free_cells.delete_at(
          command.source_index
        )
      end
    end

    def perform_cascade_selection(command)
      source_cascade = @cascades[command.source_index]
      @selected_cards = source_cascade[-command.num_cards, command.num_cards]
    end

    def perform_free_cell_selection(command)
      @selected_cards = [@free_cells[command.source_index]]
    end

    def remove_selected_cards
      @selected_cards = nil
    end

    def with_num_move_incrementing
      yield
      @num_moves += 1
    end
  end
end
