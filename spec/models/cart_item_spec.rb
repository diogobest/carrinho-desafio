require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe '#update_abandoned_status' do
    let(:shopping_cart) { create(:shopping_cart, abandoned: true) }

    it 'calls update_abandoned_status on the cart' do
      expect { shopping_cart.update_abandoned_status }
        .to change { shopping_cart.abandoned }.from(true).to(false)
    end
  end
end
