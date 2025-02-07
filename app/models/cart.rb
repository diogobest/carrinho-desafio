class Cart < ApplicationRecord
  has_many :cart_items
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_validation :set_default_total_price

  # before_save :update_abandoned_status

  def update_abandoned_status
    update(last_interaction_at: Time.now, abandoned: false)
  end

  def abandoned?
    abandoned == true
  end

  def mark_as_abandoned
    update(abandoned: true)
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  private

  def set_default_total_price
    self.total_price ||= 0.0
  end
end
