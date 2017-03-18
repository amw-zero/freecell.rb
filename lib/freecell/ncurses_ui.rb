require 'curses'
require_relative 'move_parser'

module Freecell
  # Commandline UI
  class NCursesUI
    def initialize
      @move_parser = MoveParser.new
    end

    def setup
      Curses.init_screen
      Curses.cbreak
      Curses.noecho
      Curses.nonl
    ensure
      Curses.close_screen
    end

    def render(game_state)
      Curses.clear
      render_top_area
      Curses.setpos(4, 0)
      render_cascades(game_state, 4)

      Curses.refresh
    end

    def parse_input
      input = ''
      loop do
        input << Curses.getch
        move = @move_parser.parse_input(input)
        break move if move
      end
    end

    private

    def render_top_area
      Curses.addstr('[   ] [   ] [   ] [   ]')
      Curses.setpos(0, 28)
      Curses.addstr(':)')
      Curses.setpos(0, 35)
      Curses.addstr('[   ] [   ] [   ] [   ]')
    end

    def render_cascades(game_state, start_y)
      game_state.printable_card_grid.each_with_index do |row, i|
        Curses.addstr(row.map(&:to_s).join('   '))
        Curses.setpos(start_y + i, 0)
      end
    end
  end
end
