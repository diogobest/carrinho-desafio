class CartsController < ApplicationController
  # before_action :cart_not_found, only: %i[destroy show add_items]
  before_action :initialize_cart

  def destroy
    @cart = Cart.find_by(id: cart_id)

    product_id = params[:product_id].to_i
    if @cart.cart_items.exists?(product_id: product_id)
      session[:cart].delete(product_id)
      Cart.find_by(id: cart_id).products.delete(product_id)
      render json: json_response, status: :ok
    else
      render json: { error: 'Product_id not found' }, status: :not_found
    end
  end

  def show
    @cart = Cart.find_by(id: cart_id)

    if @cart.nil?
      render json: { error: 'Cart not found' }, status: :not_found
      return
    end

    render json: json_response, status: :ok
  end

  def add_items
    # @cart = Cart.find_or_create_by(id: cart_id)
    # @cart = Cart.find_by(id: session.dig(:cart, :id))
    @cart = CartItem.find_by(product_id: params[:product_id])&.cart
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if @cart.nil?
      render json: { error: 'Cart not found' }, status: :not_found
      return
    end

    cart_item = @cart.cart_items.find_or_initialize_by(product: product)
    cart_item.quantity += quantity
    cart_item.save

    render json: json_response, status: :created
  end

  def create
    begin
      @cart = Cart.find_or_create_by(id: cart_id)

      @product = Product.find(params[:product_id])
      CartItem.create(cart: @cart, product: @product, quantity: params[:quantity].to_i)

      session[:cart][:id] = @cart.id

      render json: json_response, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Product not found' }, status: :not_found
    end
  end

  private

  def cart_id
    binding.break
    session.dig(:cart, :id)
  end

  def json_response
    {
      id: @cart.id,
      products: cart_items,
      total_price: total_cart_price
    }
  end

  def total_cart_price
    @cart.cart_items.sum { |item| item.product.price * item.quantity }
  end

  def cart_items
    @cart.cart_items.group_by(&:product_id).map do |product_id, items|
      item = items.first
      quantity = items.sum(&:quantity)

      {
        id: item.product.id,
        name: item.product.name,
        quantity: quantity,
        unit_price: item.product.price,
        total_price: item.product.price * quantity
      }
    end
  end

  def initialize_cart
    @cart = session[:cart] ||= {}
  end

  def cart_not_found
    if session[:cart].blank?
      render json: { error: 'Cart not found' }, status: :bad_request
      return
    end
  end
end
