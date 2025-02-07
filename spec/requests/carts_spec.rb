require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /add_items" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context 'when there isn\'t any cart for the product' do
      let(:product2) { Product.create(name: "Test Product 2", price: 15.0) }

      subject do
        post '/cart/add_items', params: { product_id: product2.id, quantity: 1 }, as: :json
      end

      it 'returns error message' do
        subject

        expect(response.body).to eq({ error: 'Cart not found' }.to_json)
      end
    end

    context 'when the product is not found' do
      subject do
        post '/cart/add_items', params: { product_id: 999, quantity: 1 }, as: :json
      end

      it 'returns error message' do
        subject

        expect(response.body).to eq({ error: 'Product not found' }.to_json)
      end
    end
  end

  describe "GET /cart" do
    let(:cart) { Cart.create }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    context 'when there is no session' do
      subject { get '/cart' }

      it 'returns a message of not found' do
        subject

        expect(response.body).to eq({ error: 'Cart not found' }.to_json)
      end
    end

    context 'when there is a session' do
      subject do
        get '/cart'
      end

      before do
        dbl = ActionDispatch::Request::Session.new(Rails.application, {})
        allow(ActionDispatch::Request::Session).to receive(:new).and_return(dbl)
        allow(dbl).to receive(:dig).with(:cart, :id).and_return(cart.id)
        allow(dbl).to receive(:options).and_return({})
        allow(dbl).to receive(:id).and_return("123")
      end

      it 'returns the cart' do
        subject

        expect(response.body).to eq({
          id: cart.id,
          products: [
            {
              id: product.id,
              name: product.name,
              quantity: 1,
              unit_price: product.price,
              total_price: "10.0"
            }
          ],
          total_price: "10.0"
        }.to_json)
      end
    end
  end
end
