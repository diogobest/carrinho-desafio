require 'rails_helper'

RSpec.describe DestroyUnusedCartsJob, type: :job do
  describe '#perform' do
    subject { described_class.new.perform }

    context 'when the cart is older than 7 days' do
      let!(:shopping_cart) { create(:shopping_cart, last_interaction_at: 8.days.ago, abandoned: true) }

      it 'destroys abandoned carts' do
        expect { subject }.to change { Cart.count }.by(-1)
      end
    end

    context 'when the cart is not older than 7 days' do
      let!(:shopping_cart) { create(:shopping_cart, last_interaction_at: 5.days.ago, abandoned: true) }

      it 'destroys abandoned carts' do
        expect { subject }.not_to change { Cart.count }
      end
    end

    context 'when the cart is not older than 7 days, but is not abandoned' do
      let!(:shopping_cart) { create(:shopping_cart, last_interaction_at: 10.days.ago, abandoned: false) }

      it 'does not do anything' do
        expect { subject }.not_to change { Cart.count }
      end
    end
  end
end
