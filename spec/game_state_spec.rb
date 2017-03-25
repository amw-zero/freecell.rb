describe Freecell::GameState do
  let(:h3) { Freecell::Card.new(3, :spades) }
  let(:s4) { Freecell::Card.new(4, :hearts) }
  describe '#initialize' do
    let(:game_state) do
      Freecell::GameState.new
    end
    it 'creates the correct game regions' do
      expect(game_state.cascades.count).to eq(8)
      expect(game_state.foundations.keys.count).to eq(4)
      expect(game_state.free_cells.count).to eq(0)
    end
  end

  describe '#apply' do
    context 'when moving between cascades' do
      let(:game_state) do
        cascades = [
          [h3],
          [s4]
        ]
        Freecell::GameState.new(cascades)
      end

      before do
        game_state.apply([:cascade, 0, 1])
      end

      subject do
        game_state.cascades[1]
      end

      it 'allows legal moves' do
        expect(subject.length).to eq(2)
        expect(subject[0].rank).to eq(4)
        expect(subject[0].suit).to eq(:hearts)
        expect(subject[1].rank).to eq(3)
        expect(subject[1].suit).to eq(:spades)
      end
    end
  end
end
