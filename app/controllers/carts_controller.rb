class CartsController < ApplicationController
  def show; end

  def create
    # session = RedisSessionStore.new(session.id)
    @cart = Cart.find_by(id: session[:cart_id])

    unless @cart
      @cart = Cart.create(total_price: 1)
      session[:cart_id] = @cart.id
    end

    render json: @cart, status: :ok
  end
end
