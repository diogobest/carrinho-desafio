require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    subject { described_class.new.perform }

    context 'when the cart was not used for more than 3 hours' do
      let!(:shopping_cart) { create(:shopping_cart, abandoned: false, last_interaction_at: 4.hours.ago) }

      it 'marks carts as abandoned' do
        subject

        expect(shopping_cart.reload.abandoned).to eq(true)
      end
    end

    context 'when the cart was used in the last hour' do
      let!(:shopping_cart) { create(:shopping_cart, abandoned: false, last_interaction_at: 1.hours.ago) }

      it 'doesn\'t do anything' do
        subject

        expect(shopping_cart.reload.abandoned).to eq(false)
      end
    end

    context 'when the cart was used exactly 3 hours ago' do
      let!(:shopping_cart) { create(:shopping_cart, abandoned: false, last_interaction_at: 3.hours.ago) }

      it 'marks carts as abandoned' do
        subject

        expect(shopping_cart.reload.abandoned).to eq(true)
      end
    end
  end
end
