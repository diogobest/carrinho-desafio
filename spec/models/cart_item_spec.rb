require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'associations' do
    it { is_expected.to belong_to(:cart) }
    it { is_expected.to belong_to(:product) }
  end
  pending "add some examples to (or delete) #{__FILE__}"
end
