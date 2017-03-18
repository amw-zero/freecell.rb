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
      render_top_area(game_state)
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

    def render_top_area(game_state)
      render_free_cells(game_state)
      Curses.setpos(0, 28)
      Curses.addstr(':)')
      Curses.setpos(0, 35)
      Curses.addstr('[   ] [   ] [   ] [   ]')
    end

    def render_free_cells(game_state)
      game_state.free_cells.each do |card|
        Curses.addstr("[#{card}] ")
      end
      (4 - game_state.free_cells.count).times do
        Curses.addstr('[   ] ')
      end
    end

    def render_cascades(game_state, start_y)
      current_y = start_y
      game_state.printable_card_grid.each_with_index do |row, i|
        Curses.addstr(row.map(&:to_s).join('   '))
        current_y = start_y + i
        Curses.setpos(current_y, 0)
      end
      Curses.setpos(current_y + 2, 0)
      game_state.cascades.length.times do |i|
        Curses.addstr(" #{i_to_cascade_letter(i)}    ")
      end
    end


    def i_to_cascade_letter(i)
      ascii_a = 97
      [i + ascii_a].pack('c*')
    end
  end
end
