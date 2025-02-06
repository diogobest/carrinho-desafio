FactoryBot.define do
  factory :shopping_cart, class: Cart do
    total_price { nil }
  end
end
