class Cart < ApplicationRecord
  has_many :carts_products
  has_many :products, through: :carts_products

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_validation :set_default_total_price

  private

  def set_default_total_price
    self.total_price ||= 0.0
  end

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
end
