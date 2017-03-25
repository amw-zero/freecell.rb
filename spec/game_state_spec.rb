describe Freecell::GameState do
  describe '#apply' do
    let(:deck) do
      Freecell::Deck.new
    end

    let(:game_state) do
      Freecell::GameState.new(deck)
    end

    it 'creates the correct game regions' do
      expect(game_state.cascades.count).to eq(8)
      expect(game_state.foundations.keys.count).to eq(4)
      expect(game_state.free_cells.count).to eq(0)
    end
  end
end
