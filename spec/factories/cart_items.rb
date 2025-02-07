FactoryBot.define do
  factory :cart_item do
    cart factory: :shopping_cart
    product
    quantity { 1 }
  end
end
