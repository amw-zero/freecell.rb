require 'curses'
require_relative 'move_parser'
require_relative 'input_state_machine.rb'

module Freecell
  # Commandline UI
  class NCursesUI
    BLACK_CARD_COLOR_PAIR_ID = 1

    def initialize
      @move_parser = MoveParser.new
      @curr_y = 0
      input_sm = InputStateMachine.new
    end

    def setup
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.nonl
      Curses.curs_set(0)
      setup_color
    ensure
      Curses.close_screen
    end

    def setup_color
      Curses.start_color
      Curses.init_pair(
        BLACK_CARD_COLOR_PAIR_ID,
        Curses::COLOR_CYAN,
        Curses::COLOR_BLACK
      )
    end

    def render(game_state)
      Curses.clear
      render_top_area(game_state)
      advance_y(by: 3)
      render_cascades(game_state, 4)

      Curses.refresh
      reset_state
    end

    def parse_input
      loop do
        input = input_sm.handle_input(Curses.getch)
        case input[:type]
        when :move
          move = @move_parser.parse_input(input)
          break move if move
        when :quit
          exit
        end
      end
    end

    private

    def reset_state
      @curr_y = 0
    end

    def render_top_area(game_state)
      Curses.addstr('space')
      Curses.setpos(@curr_y, 39)
      Curses.addstr('enter')
      advance_y(by: 1)
      render_free_cells(game_state)
      Curses.setpos(@curr_y, 21)
      Curses.addstr('=)')
      Curses.setpos(@curr_y, 24)
      render_foundations(game_state)
    end

    def render_free_cells(game_state)
      game_state.free_cells.each do |card|
        draw_card_with_border(card)
      end
      (4 - game_state.free_cells.count).times do
        Curses.addstr('[   ]')
      end
      Curses.setpos(@curr_y + 1, 0)
      game_state.free_cells.each_index do |i|
        Curses.addstr("  #{i_to_free_cell_letter(i)}  ")
      end
    end

    def render_foundations(game_state)
      [:diamonds, :hearts, :spades, :clubs].each do |suit|
        card = game_state.foundations[suit].last || '   '
        draw_card_with_border(card)
      end
    end

    def render_cascades(game_state, start_y)
      game_state.printable_card_grid.each_with_index do |row, i|
        Curses.addstr('   ')
        row.each do |card|
          draw_card(card)
        end
        advance_y(by: 1)
      end
      advance_y(by: 1)
      Curses.setpos(@curr_y, 4)
      game_state.cascades.length.times do |i|
        Curses.addstr("#{i_to_cascade_letter(i)}    ")
      end
    end

    def i_to_free_cell_letter(i)
      ['w', 'x', 'y', 'z'][i]
    end

    def i_to_cascade_letter(i)
      ascii_a = 97
      [i + ascii_a].pack('c*')
    end

    def draw_card(card)
      with_black_card_coloring(card) do |card|
        Curses.addstr(card.to_s)
      end
      Curses.addstr('  ')
    end

    def draw_card_with_border(card)
      Curses.addstr('[')
      with_black_card_coloring(card) do |card|
        Curses.addstr(card.to_s)
      end
      Curses.addstr(']')
    end

    def black_card_color_pair
      @black_card_color_pair ||= Curses.color_pair(BLACK_CARD_COLOR_PAIR_ID)
    end

    def with_black_card_coloring(card)
      is_black_card = card.respond_to?(:black?) && card.black?
      Curses.attron(black_card_color_pair) if is_black_card
      yield card
      Curses.attroff(black_card_color_pair) if is_black_card
    end

    def advance_y(by:)
      @curr_y += by
      Curses.setpos(@curr_y, 0)
    end
  end
end
