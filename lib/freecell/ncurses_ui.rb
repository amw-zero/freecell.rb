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

    def render(game_state)
      Curses.clear
      render_top_area(game_state)
      advance_y(by: 3)
      render_cascades(game_state)
      advance_y(by: 1)
      render_bottom_area(game_state)
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

    def render_bottom_area(game_state)
      with_highlight_coloring { Curses.addstr('q') }
      Curses.addstr('uit')

      Curses.setpos(@curr_y, 5)
      with_highlight_coloring { Curses.addstr('u') }
      Curses.addstr('ndo')

      Curses.setpos(@curr_y, 10)
      with_highlight_coloring { Curses.addstr('?') }
      Curses.addstr('=help')
      Curses.setpos(@curr_y, 28)
      Curses.addstr("#{game_state.num_moves} moves,")
      Curses.setpos(@curr_y, 37)
      Curses.addstr("#{game_state.num_undos} undos")
    end

    def render_free_cells(game_state)
      draw_occupied_free_cells(game_state)
      draw_empty_free_cells(game_state)
      Curses.setpos(@curr_y + 1, 0)
      game_state.free_cells.each_index do |i|
        Curses.addstr("  #{i_to_free_cell_letter(i)}  ")
      end
    end

    def draw_occupied_free_cells(game_state)
      game_state.free_cells.each do |card|
        with_border do
          draw_card(card, game_state.selected_cards)
        end
      end
    end

    def draw_empty_free_cells(game_state)
      (4 - game_state.free_cells.count).times do
        Curses.addstr('[   ]')
      end
    end

    def render_foundations(game_state)
      %i[diamonds hearts spades clubs].each do |suit|
        card = game_state.foundations[suit].last || EmptyCard.new
        with_border do
          draw_card(card, game_state.selected_cards)
        end
      end
    end

    def render_cascades(game_state)
      draw_cascade_cards(game_state)
      advance_y(by: 1)
      Curses.setpos(@curr_y, 4)
      game_state.cascades.length.times do |i|
        Curses.addstr("#{i_to_cascade_letter(i)}    ")
      end
    end

    def draw_cascade_cards(game_state)
      printable_card_grid(game_state).each do |row|
        Curses.addstr('   ')
        row.each do |card|
          draw_card(card, game_state.selected_cards)
          Curses.addstr('  ')
        end
        advance_y(by: 1)
      end
    end

    def printable_card_grid(game_state)
      max_length = game_state.cascades.map(&:length).max
      game_state.cascades.map do |c|
        c + (0...max_length - c.count).map { EmptyCard.new }
      end.transpose
    end

    def i_to_free_cell_letter(i)
      %w[w x y z][i]
    end

    def i_to_cascade_letter(i)
      [i + Freecell::CharacterParser::ASCII_LOWERCASE_A].pack('c*')
    end

    def draw_card(card, selected_cards)
      with_card_coloring(card, selected_cards) do |c|
        str = case c
              when Freecell::Card
                card_string(c)
              when Freecell::EmptyCard
                empty_card_string
              end
        Curses.addstr(str)
      end
    end

    def card_string(card)
      if card.rank < 10
        " #{card.rank}#{card.suit.to_s[0]}"
      else
        "#{card.rank}#{card.suit.to_s[0]}"
      end
    end

    def empty_card_string
      '   '
    end

    def with_border
      Curses.addstr('[')
      yield
      Curses.addstr(']')
    end

    def black_card_color
      @black_card_color ||= Curses.color_pair(BLACK_CARD_COLOR_PAIR_ID)
    end

    def black_selected_card_color
      @black_selected_card_color ||= Curses.color_pair(
        SELECTED_BLACK_CARD_COLOR_PAIR_ID
      )
    end

    def red_selected_card_color
      @red_selected_card_color ||= Curses.color_pair(
        SELECTED_RED_CARD_COLOR_PAIR_ID
      )
    end

    def with_card_coloring(card, selected_cards)
      attr = color_for_card(card, selected_cards)
      Curses.attron(attr) if attr
      yield card
      Curses.attroff(attr) if attr
    end

    def color_for_card(card, selected_cards)
      attr = black_card_color if card.black?
      return attr unless selected_cards && (card.red? || card.black?)
      card_is_selected = selected_cards.include?(card)
      attr = red_selected_card_color if card.red? && card_is_selected
      attr = black_selected_card_color if card.black? && card_is_selected
      attr
    end

    def with_highlight_coloring
      Curses.attron(black_card_color)
      yield
      Curses.attroff(black_card_color)
    end

    def advance_y(by:)
      @curr_y += by
      Curses.setpos(@curr_y, 0)
    end
  end
end
