class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  before_save :update_abandoned_status

  def update_abandoned_status
    cart.update_abandoned_status
  end
end
