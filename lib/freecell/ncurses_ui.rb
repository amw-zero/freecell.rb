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
      Curses.addstr(game_state.cards.to_s)
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
