require "curses"
require_relative "move_parser"

module Freecell
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

      Curses.addstr("[   ] [   ] [   ] [   ]")
      Curses.setpos(0, 28)
      Curses.addstr(":)")
      Curses.setpos(0, 35)
      Curses.addstr("[   ] [   ] [   ] [   ]")

      Curses.setpos(4, 0)
      7.times do |i|
        Curses.addstr(game_state.cascades[0][i].to_s)
        Curses.setpos(4 + i, 0)
      end

      Curses.refresh
    end

    def parse_input
      input = ""
      loop do
        input << Curses.getch
        move = @move_parser.parse_input(input)
        break move if move
      end
    end
  end
end
