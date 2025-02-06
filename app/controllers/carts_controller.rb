class CartsController < ApplicationController
  before_action :initialize_cart

  def destroy
    @cart = Cart.find_by(id: session[:cart][:id])

    product_id = params[:product_id].to_i
    if session[:cart].has_key?(product_id)
      session[:cart].delete(product_id)
      Cart.find_by(id: session.dig(:cart, :id)).products.delete(product_id)
      render json: json_response, status: :ok
    else
      render json: { error: 'Product_id not found' }, status: :not_found
    end
  end

  def show
    render json: json_response, status: :ok
  end

  def add_items
    product_id = params[:product_id]

    session[:cart][product_id] ||= 0
    session[:cart][product_id] += params[:quantity].to_i

    render json: json_response, status: :created
  end

  def create
    begin
      @cart = Cart.find_or_create_by(id: @cart[:id])

      @product = Product.find(params[:product_id])
      @cart.products << @product

      session[:cart][:id] = @cart.id
      session[:cart][@product.id] ||= 0
      session[:cart][@product.id] += params[:quantity].to_i

      render json: json_response, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Product not found' }, status: :not_found
    end
  end

  private

  def json_response
    {
      id: @cart.id,
      products: @cart.products.group_by(&:id).transform_values do |id, product|
        {
          id: product.id,
          name: product.name,
          quantity: session[:cart][product.id],
          unit_price: product.price,
          total_price: product.price * session[:cart][product.id]
        }
      end.values,
      total_price: @cart.products.sum { |product| product.price * params[:quantity].to_i }
    }
  end

  def verify_session_presence
    render json: { error: 'There is no cart to this session' }, status: :not_found unless session[:cart_id]
  end

  def initialize_cart
    @cart = session[:cart] ||= {}
  end
end
