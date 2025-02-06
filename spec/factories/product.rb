FactoryBot.define do
  factory :product do
    name { "Name" }
    price { rand(0.1..199.9).round(2) }
  end
end
