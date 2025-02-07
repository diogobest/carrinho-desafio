class CartsController < ApplicationController
  def destroy
    @cart = Cart.find(cart_id)

    product_id = params[:product_id].to_i
    if @cart.cart_items.exists?(product_id: product_id)
      session[:cart].delete(product_id)
      @cart.products.delete(product_id)
      render json: json_response, status: :ok
    else
      render json: { error: 'Product_id not found' }, status: :not_found
    end

  rescue ActiveRecord::RecordNotFound => e
    render json: { error: 'Cart not found' }, status: :not_found
  end

  def show
    @cart = Cart.find(cart_id)

    render json: json_response, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Cart not found' }, status: :not_found
  end

  def add_items
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

  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
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
end
