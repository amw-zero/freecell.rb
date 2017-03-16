require_relative 'card'

module Freecell
  class Deck
    SIZE = 52

    attr_reader :cards

    def initialize
      @cards = (1..(SIZE / 4)).to_a.product(Card::SUITS).map do |rank, suit|
        Card.new(rank, suit)
      end.shuffle
    end
  end
end
