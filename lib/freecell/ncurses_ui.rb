require 'curses'
require_relative 'input_state_machine.rb'

module Freecell
  # Helpers for drawing
  module CursesExtensions
    def mvaddstr(y, x, str)
      Curses.setpos(y, x)
      Curses.addstr(str)
    end
  end

  # Colors
  class Colors
    BLACK_CARD = 1
    SELECTED_BLACK_CARD = 2
    SELECTED_RED_CARD = 3

    class << self
      def setup
        Curses.start_color
        [
          [BLACK_CARD, Curses::COLOR_CYAN, Curses::COLOR_BLACK],
          [SELECTED_BLACK_CARD, Curses::COLOR_CYAN, Curses::COLOR_BLUE],
          [SELECTED_RED_CARD, Curses::COLOR_WHITE, Curses::COLOR_BLUE]
        ].each { |a| Curses.init_pair(*a) }
      end

      def black_card_color
        Curses.color_pair(BLACK_CARD)
      end

      def black_selected_card_color
        Curses.color_pair(SELECTED_BLACK_CARD)
      end

      def red_selected_card_color
        Curses.color_pair(SELECTED_RED_CARD)
      end
    end
  end

  # Base view
  class BaseView
    include CursesExtensions

    def initialize(y)
      @y = y
    end

    def advance_y(by:)
      @y += by
      Curses.setpos(@y, 0)
    end
  end

  # Renders a card
  class CardView
    def initialize(card)
      @card = card
    end

    def render(selected_cards)
      card_str = "#{@card.rank}#{@card.suit.to_s[0]}"
      card_str.insert(0, ' ') if @card.rank < 10
      with_card_coloring(@card, selected_cards) do
        Curses.addstr(card_str)
      end
    end

    private

    def with_card_coloring(card, selected_cards)
      color = color_for_card(card, selected_cards)
      Curses.attron(color) if color
      yield card
      Curses.attroff(color) if color
    end

    def color_for_card(card, selected_cards)
      selected = selected_cards.include?(card) if selected_cards
      case card.color
      when :red
        Colors.red_selected_card_color if selected
      when :black
        selected ? Colors.black_selected_card_color : Colors.black_card_color
      end
    end
  end

  # Free cells and Cascades
  class TopView < BaseView
    def render(game_state)
      mvaddstr(@y, 0, 'space                                  enter')
      advance_y(by: 1)
      render_free_cells(game_state)
      mvaddstr(@y, 21, '=)')
      Curses.setpos(@y, 24)
      render_foundations(game_state)
    end

    private

    def render_free_cells(game_state)
      draw_occupied_free_cells(game_state)
      draw_empty_free_cells(game_state)
      game_state.free_cells.each_index do |i|
        Curses.addstr("  #{free_cell_letter(i)}  ")
      end
    end

    def draw_occupied_free_cells(game_state)
      game_state.free_cells.each do |card|
        with_border do
          CardView.new(card).render(game_state.selected_cards)
        end
      end
    end

    def draw_empty_free_cells(game_state)
      (4 - game_state.free_cells.count).times { Curses.addstr('[   ]') }
    end

    def render_foundations(game_state)
      %i[diamonds hearts spades clubs].each do |suit|
        card = game_state.foundations[suit].last
        if card
          with_border { CardView.new(card).render(game_state.selected_cards) }
        else
          Curses.addstr('[   ]')
        end
      end
    end

    def with_border
      Curses.addstr('[')
      yield
      Curses.addstr(']')
    end

    def free_cell_letter(i)
      %w[w x y z][i]
    end
  end

  # Renders the cascade section of the game
  class CascadeView < BaseView
    def render(game_state)
      Curses.setpos(@y, 0)
      draw_cascade_cards(game_state)
      advance_y(by: 1)
      Curses.setpos(@y, 4)
      game_state.cascades.length.times do |i|
        Curses.addstr("#{i_to_cascade_letter(i)}    ")
      end
      @y
    end

    private

    def draw_cascade_cards(game_state)
      printable_card_grid(game_state).each do |row|
        Curses.setpos(@y, 3)
        row.each do |card|
          CardView.new(card).render(game_state.selected_cards) if card
          Curses.addstr(empty_card_string) if card.nil?
          Curses.addstr('  ')
        end
        advance_y(by: 1)
      end
    end

    def printable_card_grid(game_state)
      max_length = game_state.cascades.map(&:length).max
      game_state.cascades.map do |c|
        c + (0...max_length - c.count).map { nil }
      end.transpose
    end

    def i_to_cascade_letter(i)
      [i + Freecell::CharacterParser::ASCII_LOWERCASE_A].pack('c*')
    end

    def empty_card_string
      '   '
    end
  end

  # Bottom area of game
  class BottomView < BaseView
    def render(game_state)
      draw_with_highlighted_first_letter(0, 'quit')
      draw_with_highlighted_first_letter(5, 'undo')
      draw_with_highlighted_first_letter(10, '?=help')
      mvaddstr(@y, 28, "#{game_state.num_moves} moves,")
      mvaddstr(@y, 37, "#{game_state.num_undos} undos")
    end

    private

    def draw_with_highlighted_first_letter(x, str)
      Curses.setpos(@y, x)
      with_highlight_coloring { Curses.addstr(str[0]) }
      Curses.addstr(str[1..-1])
    end

    def with_highlight_coloring
      Curses.attron(Colors.black_card_color)
      yield
      Curses.attroff(Colors.black_card_color)
    end
  end

  # Commandline UI
  class NCursesUI
    def initialize
      @curr_y = 0
      @input_sm = InputStateMachine.new
    end

    def setup
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.nonl
      Curses.curs_set(0)
      Colors.setup
    ensure
      Curses.close_screen
    end

    def render(game_state)
      Curses.erase
      TopView.new(0).render(game_state)
      y = CascadeView.new(4).render(game_state)
      BottomView.new(y + 1).render(game_state)
      Curses.refresh
    end

    def parse_input
      command = @input_sm.handle_ch(Curses.getch)
      return unless command
      case command.type
      when :quit
        exit
      else
        command
      end
    end
  end
end
