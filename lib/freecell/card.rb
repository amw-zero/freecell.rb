module Freecell
  # A playing card
  class Card
    attr_reader :rank, :suit

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

    def ==(rhs)
      %i(rank suit).all? { |v| self.send(v) == rhs.send(v) }
    end
    def black?
      [:clubs, :spades].include?(suit)
    end

    def red?
      [:hearts, :diamonds].include?(suit)
    end

    def opposite_color?(other)
      red = [:hearts, :diamonds]
      red.include?(suit) ^ red.include?(other.suit)
    end
  end
end
