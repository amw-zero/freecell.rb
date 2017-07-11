module Freecell
  # A playing card
  class Card
    attr_reader :rank, :suit

    SUITS = [:hearts, :diamonds, :spades, :clubs].freeze

    def initialize(rank, suit)
      @rank = rank
      @suit = suit
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

  # Used for printing
  class EmptyCard
    def black?
      false
    end

    def red?
      false
    end
  end
end
