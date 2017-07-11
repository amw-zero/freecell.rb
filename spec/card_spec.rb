require 'spec_helper'

describe Freecell::Card do
  describe '#==' do
    let(:card1) do
      Freecell::Card.new(1, :diamonds)
    end

    let(:card2) do
      Freecell::Card.new(1, :diamonds)
    end

    it 'correctly reports card equality' do
      expect(card1).to eq(card2)
    end
  end
end
