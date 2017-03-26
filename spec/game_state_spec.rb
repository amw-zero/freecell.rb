describe Freecell::GameState do
  let(:h4) { Freecell::Card.new(4, :hearts) }
  let(:h3) { Freecell::Card.new(3, :hearts) }
  let(:h2) { Freecell::Card.new(2, :hearts) }
  let(:h1) { Freecell::Card.new(1, :hearts) }

  let(:s3) { Freecell::Card.new(3, :spades) }
  let(:s2) { Freecell::Card.new(2, :spades) }
  let(:s1) { Freecell::Card.new(1, :spades) }

  def expect_card(card, rank, suit)
    expect(card.rank).to eq(rank)
    expect(card.suit).to eq(suit)
  end

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
          [s3],
          [h4]
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
        expect_card(subject[0], 4, :hearts)
        expect_card(subject[1], 3, :spades)
      end
    end

    context 'when moving to free cells' do
      let(:game_state) do
        cascades = [
          [h4, h3, h2, h1, s3]
        ]
        Freecell::GameState.new(cascades)
      end

      before do
        game_state.apply([:cascade_to_free_cell, 0])
        game_state.apply([:cascade_to_free_cell, 0])
        game_state.apply([:cascade_to_free_cell, 0])
        game_state.apply([:cascade_to_free_cell, 0])
        game_state.apply([:cascade_to_free_cell, 0])
      end

      subject do
        game_state.free_cells
      end

      it 'allows legal moves' do
        expect(subject.length).to eq(4)
        expect(game_state.cascades[0].length).to eq(1)
        expect_card(subject[0], 3, :spades)
        expect_card(subject[1], 1, :hearts)
        expect_card(subject[2], 2, :hearts)
        expect_card(subject[3], 3, :hearts)
      end
    end
  end
end
