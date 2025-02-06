require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartProduct.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "POST /create" do
    context 'when the product exists' do
      let(:product) { create(:product) }

      it 'creates a new cart and adds the product to it' do
        expect { post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json }.to change(Cart, :count).by(1)
      end
    end

    context 'when the product does not exist' do
      it 'returns a not found error' do
        post '/cart', params: { product_id: 1, quantity: 1 }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
