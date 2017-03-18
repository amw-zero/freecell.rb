module Freecell
  # A playing card
  class Card
    SUITS = [:hearts, :diamonds, :spades, :clubs].freeze

    def initialize(rank, suit)
      @rank = rank
      @suit = suit
    end

    def to_s
      if @rank < 10
        " #{@rank}#{@suit.to_s[0]}"
      else
        "#{@rank}#{@suit.to_s[0]}"
      end
    end

    def <=>(other)
      to_i <=> other.to_i
    end
  end
end
