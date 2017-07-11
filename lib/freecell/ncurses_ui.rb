require 'curses'
require_relative 'input_state_machine.rb'

module Freecell
  # Commandline UI
  class NCursesUI
    BLACK_CARD_COLOR_PAIR_ID = 1
    SELECTED_BLACK_CARD_COLOR_PAIR_ID = 2
    SELECTED_RED_CARD_COLOR_PAIR_ID = 3

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
      Curses.init_pair(
        SELECTED_BLACK_CARD_COLOR_PAIR_ID,
        Curses::COLOR_CYAN,
        Curses::COLOR_BLUE
      )
      Curses.init_pair(
        SELECTED_RED_CARD_COLOR_PAIR_ID,
        Curses::COLOR_WHITE,
        Curses::COLOR_BLUE
      )
    end

    def render(game_state)
      Curses.clear
      render_top_area(game_state)
      advance_y(by: 3)
      render_cascades(game_state)
      advance_y(by: 1)
      render_bottom_area
      Curses.refresh
      reset_state
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

    def render_bottom_area
      Curses.attron(black_card_color_pair)
      Curses.addstr('q')
      Curses.attroff(black_card_color_pair)
      Curses.addstr('uit')
    end

    def render_free_cells(game_state)
      game_state.free_cells.each do |card|
        draw_card_with_border(card, game_state.selected_card)
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
        draw_card_with_border(card, game_state.selected_card)
      end
    end

    def render_cascades(game_state)
      printable_card_grid(game_state).each do |row|
        Curses.addstr('   ')
        row.each { |card| draw_card(card, game_state.selected_card) }
        advance_y(by: 1)
      end
      advance_y(by: 1)
      Curses.setpos(@curr_y, 4)
      game_state.cascades.length.times do |i|
        Curses.addstr("#{i_to_cascade_letter(i)}    ")
      end
    end

    def printable_card_grid(game_state)
      max_length = game_state.cascades.map(&:length).max
      game_state.cascades.map do |c|
        c + (0...max_length - c.count).map { '   ' }
      end.transpose
    end

    def i_to_free_cell_letter(i)
      %w(w x y z)[i]
    end

    def i_to_cascade_letter(i)
      ascii_a = 97
      [i + ascii_a].pack('c*')
    end

    def draw_card(card, selected_card)
      with_card_coloring(card, selected_card) do |c|
        Curses.addstr(c.to_s)
      end
      Curses.addstr('  ')
    end

    def draw_card_with_border(card, selected_card)
      Curses.addstr('[')
      with_card_coloring(card, selected_card) do |c|
        Curses.addstr(c.to_s)
      end
      Curses.addstr(']')
    end

    def black_card_color_pair
      @black_card_color_pair ||= Curses.color_pair(BLACK_CARD_COLOR_PAIR_ID)
    end

    def black_selected_card_color_pair
      @black_selected_card_color_pair ||= Curses.color_pair(
        SELECTED_BLACK_CARD_COLOR_PAIR_ID
      )
    end

    def red_selected_card_color_pair
      @red_selected_card_color_pair ||= Curses.color_pair(
        SELECTED_RED_CARD_COLOR_PAIR_ID
      )
    end

    def with_card_coloring(card, selected_card)
      is_black_card = card.respond_to?(:black?) && card.black?
      is_red_card = card.respond_to?(:red?) && card.red?
      attr = if selected_card
               if is_red_card && card == selected_card
                 red_selected_card_color_pair
               elsif is_black_card && card == selected_card
                 black_selected_card_color_pair
               else
                 black_card_color_pair if is_black_card
               end
             else
               black_card_color_pair if is_black_card
             end
      Curses.attron(attr) if attr
      yield card
      Curses.attroff(attr) if attr
    end

    def advance_y(by:)
      @curr_y += by
      Curses.setpos(@curr_y, 0)
    end
  end
end
