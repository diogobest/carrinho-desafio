require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'set_default_total_price' do
    let(:cart) { create(:shopping_cart, total_price: nil) }

    it 'sets the default total_price to 0' do
      expect(cart.total_price).to eq(0.0)
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:shopping_cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:shopping_cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe '.update_abandoned_status' do
    let(:shopping_cart) { create(:shopping_cart) }

    context 'when the status of the cart is updated' do
      it 'updates the last_interaction_at and abandoned fields' do
        shopping_cart.update(last_interaction_at: 3.hours.ago, abandoned: true)

        expect { shopping_cart.update_abandoned_status }.to change { shopping_cart.abandoned? }.from(true).to(false)
      end
    end
  end

  describe '.abandoned?' do
    context 'when the shopping cart is abandoned' do
      let(:shopping_cart) { create(:shopping_cart, abandoned: true) }

      it 'returns true' do
        expect(shopping_cart.abandoned?).to be_truthy
      end
    end

    context 'when the shopping cart is not abandoned' do
      let(:shopping_cart) { create(:shopping_cart, abandoned: false) }

      it 'returns false' do
        expect(shopping_cart.abandoned?).to be_falsey
      end
    end
  end
end
