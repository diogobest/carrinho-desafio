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
      let(:product2) { create(:product, name: 'Product 2', price: 15.0) }

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

  describe "POST /cart" do
    context 'when there is no cart in session' do
      let(:product) { create(:product, price: 10.0, name: 'Product 1') }

      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      before do
        dbl = ActionDispatch::Request::Session.new(Rails.application, {})
        allow(ActionDispatch::Request::Session).to receive(:new).and_return(dbl)
        allow(dbl).to receive(:[]).with(:cart).and_return({ id: 1 })
        allow(dbl).to receive(:dig).with(:cart, :id).and_return(nil)
        allow(dbl).to receive(:options).and_return({})
        allow(dbl).to receive(:id).and_return("123")
      end


      it 'creates a new cart and adds the product sent' do
        subject

        expect(response.body).to eq({
          id: Cart.last.id,
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

    context 'when the product is not found' do
      subject do
        post '/cart', params: { product_id: 999, quantity: 1 }, as: :json
      end

      it 'returns error message' do
        subject

        expect(response.body).to eq({ error: 'Product not found' }.to_json)
      end
    end

    context 'when there is a cart in session' do
      let(:cart) { create(:shopping_cart) }
      let(:product) { create(:product, name: 'Product 1', price: 10.0) }

      subject do
        post '/cart', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      before do
        dbl = ActionDispatch::Request::Session.new(Rails.application, {})
        allow(ActionDispatch::Request::Session).to receive(:new).and_return(dbl)
        allow(dbl).to receive(:[]).with(:cart).and_return({ id: 1 })
        allow(dbl).to receive(:dig).with(:cart, :id).and_return(nil)
        allow(dbl).to receive(:options).and_return({})
        allow(dbl).to receive(:id).and_return("123")
      end


      it 'creates a new cart and adds the product sent' do
        subject

        expect(response.body).to eq({
          id: Cart.last.id,
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


    context 'when there isn\'t any cart for the product' do
      let(:product2) { create(:product, name: 'Product 2', price: 15.0) }

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
    let(:cart) { create(:shopping_cart) }
    let(:product) { create(:product, name: 'Product', price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

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

  describe "DELETE /cart" do
    let(:cart) { create(:shopping_cart) }
    let(:product) { create(:product, name: 'Product', price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    context 'when there is no session' do
      subject { delete '/cart/1' }

      it 'returns a message of not found' do
        subject

        expect(response.body).to eq({ error: 'Cart not found' }.to_json)
        expect(response.status).to eq(404)
      end
    end

    context 'when there is a session' do
      subject do
        delete "/cart/#{product.id}"
      end

      before do
        dbl = ActionDispatch::Request::Session.new(Rails.application, {})
        allow(ActionDispatch::Request::Session).to receive(:new).and_return(dbl)
        allow(dbl).to receive(:[]).with(:cart).and_return({ id: cart.id, product.id => 1})
        allow(dbl).to receive(:dig).with(:cart, :id).and_return(cart.id)
        allow(dbl).to receive(:delete).with(product.id).and_return(nil)
        allow(dbl).to receive(:options).and_return({})
        allow(dbl).to receive(:id).and_return("123")
      end

      it 'deletes the cart' do
        expect { subject }.to change { CartItem.count }.by(-1)

        expect(response.body).to eq({ id: cart.id, products: [], total_price: 0 }.to_json)
      end
    end

    context 'when the product is not found' do
      subject do
        delete "/cart/999"
      end

      before do
        dbl = ActionDispatch::Request::Session.new(Rails.application, {})
        allow(ActionDispatch::Request::Session).to receive(:new).and_return(dbl)
        allow(dbl).to receive(:[]).with(:cart).and_return({ id: cart.id, product.id => 1})
        allow(dbl).to receive(:dig).with(:cart, :id).and_return(cart.id)
        allow(dbl).to receive(:delete).with(product.id).and_return(nil)
        allow(dbl).to receive(:options).and_return({})
        allow(dbl).to receive(:id).and_return("123")
      end

      it 'returns error message' do
        subject

        expect(response.body).to eq({ error: 'Product_id not found' }.to_json)
      end
    end
  end
end
