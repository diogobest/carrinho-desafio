class Product < ApplicationRecord
  has_many :carts_products
  has_many :carts, through: :carts_products

  validates_presence_of :name, :price
  validates_numericality_of :price, greater_than_or_equal_to: 0
end
