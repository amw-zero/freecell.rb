module Freecell
  # A playing card
  class Card
    attr_reader :rank, :suit

    SUITS = %i[hearts diamonds spades clubs].freeze

    def initialize(rank, suit)
      @rank = rank
      @suit = suit
    end

    def ==(other)
      %i[rank suit].all? { |v| send(v) == other.send(v) }
    end

    def black?
      %i[clubs spades].include?(suit)
    end

    def red?
      %i[hearts diamonds].include?(suit)
    end

    def color
      case suit
      when :hearts, :diamonds
        :red
      when :spades, :clubs
        :black
      end
    end

    def opposite_color?(other)
      red = %i[hearts diamonds]
      red.include?(suit) ^ red.include?(other.suit)
    end
  end
end
