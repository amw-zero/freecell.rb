module Freecell
  # A playing card
  class Card
    include Comparable

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

    def <=>(other)
      rank <=> other.rank
    end

    def opposite_color?(other)
      red = [:hearts, :diamonds]
      red.include?(suit) ^ red.include?(other.suit)
    end
  end
end
