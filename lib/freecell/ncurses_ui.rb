require "ncurses"

module Freecell
  class NCursesUI
    def setup
      Ncurses.initscr
      Ncurses.cbreak           # provide unbuffered input
      Ncurses.noecho           # turn off input echoing
      Ncurses.nonl             # turn off newline translation
      Ncurses.stdscr.intrflush(false) # turn off flush-on-interrupt
      Ncurses.stdscr.keypad(true)     # turn on keypad mode

      Ncurses.stdscr.addstr("Press a key to continue") # output string
      Ncurses.stdscr.getch                             # get a charachter

    ensure
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
    end

    def render(game_state)
      #puts game_state.cards
    end
  end
end
