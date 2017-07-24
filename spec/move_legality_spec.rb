require 'spec_helper'

describe Freecell::MoveLegality do
  let(:h4) { Freecell::Card.new(4, :hearts) }
  let(:h3) { Freecell::Card.new(3, :hearts) }
  let(:h2) { Freecell::Card.new(2, :hearts) }
  let(:h1) { Freecell::Card.new(1, :hearts) }

  let(:s3) { Freecell::Card.new(3, :spades) }

  let(:legality) do
    Freecell::MoveLegality.new
  end

  let(:cascades) { [] }
  let(:free_cells) { [] }
  let(:foundations) { [] }

  let(:command) do
    Freecell::GameStateCommand.new(
      type: :any,
      source_index: 0,
      dest_index: 1
    )
  end

  describe '#cascade_to_cascade_move?' do
    subject do
      legality.cascade_to_cascade_move?(command, cascades, free_cells)
    end

    context 'when the move is a multi card move' do
      let(:command) do
        Freecell::GameStateCommand.new(
          type: :any,
          source_index: 0,
          dest_index: 1,
          num_cards: 2
        )
      end

      context 'when the move is legal' do
        let(:cascades) do
          [[s3, h2], [h4]]
        end

        it 'allows the move' do
          expect(subject).to be true
        end
      end

      context 'when the move is not legal' do
        let(:cascades) do
          [[s3, s3], [h4]]
        end

        it 'allows the move' do
          expect(subject).to be false
        end
      end
    end

    context 'when the move is a single card move' do
      context 'when the move is legal' do
        let(:cascades) do
          [[s3], [h4]]
        end

        it 'allows the move' do
          expect(subject).to be true
        end
      end

      context 'when the move is not legal' do
        let(:cascades) do
          [[h3], [h4]]
        end

        it 'does not allow the move' do
          expect(subject).to eq(false)
        end
      end
    end
  end

  describe '#cascade_to_free_cell_move?' do
    subject do
      legality.cascade_to_free_cell_move?(free_cells)
    end

    let(:cascades) do
      [[s3]]
    end

    context 'when the move is legal' do
      let(:cascades) do
        [[s3]]
      end

      it 'allows the move' do
        expect(subject).to be true
      end
    end

    context 'when the move is not legal' do
      let(:free_cells) do
        [s3, s3, s3, s3]
      end

      it 'does not allow the move ' do
        expect(subject).to be false
      end
    end
  end

  describe '#free_cell_to_cascade_move?' do
    subject do
      legality.free_cell_to_cascade_move?(command, cascades, free_cells)
    end

    let(:cascades) do
      [[], [h4]]
    end

    context 'when the move is legal' do
      let(:free_cells) do
        [s3]
      end

      it 'allows the move' do
        expect(subject).to be true
      end
    end

    context 'when the move is not legal' do
      let(:free_cells) do
        [h4]
      end

      it 'does not allow the move' do
        expect(subject).to be false
      end
    end
  end

  describe '#cascade_to_foundation_move?' do
    subject do
      legality.cascade_to_foundation_move?(command, cascades, foundations)
    end

    context 'when the move is legal' do
      context 'when the foundation is empty and the card is an Ace' do
        let(:cascades) do
          [[h1]]
        end

        let(:foundations) do
          { hearts: [] }
        end

        it 'allows the move' do
          expect(subject).to be true
        end
      end

      context 'when the card is 1 greater than the current foundation card' do
        let(:cascades) do
          [[h4]]
        end

        let(:foundations) do
          { hearts: [h3] }
        end

        it 'allows the move' do
          expect(subject).to be true
        end
      end
    end

    context 'when the move is not legal' do
      let(:cascades) do
        [[h4]]
      end

      let(:foundations) do
        { hearts: [h2] }
      end

      it 'does not allow the move' do
        expect(subject).to be false
      end
    end
  end

  describe '#free_cell_to_foundation_move?' do
    subject do
      legality.free_cell_to_foundation_move?(command, free_cells, foundations)
    end

    context 'when then move is legal' do
      let(:free_cells) do
        [h4]
      end

      let(:foundations) do
        { hearts: [h3] }
      end

      it 'allows the move' do
        expect(subject).to be true
      end
    end

    context 'when the move is not legal' do
      let(:free_cells) do
        [h2]
      end

      let(:foundations) do
        { hearts: [h3] }
      end

      it 'does not allow the move' do
        expect(subject).to be false
      end
    end
  end
end
