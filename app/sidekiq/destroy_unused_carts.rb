class DestroyUnusedCarts
  include Sidekiq::Job

  def perform(*args)
    Cart.where('last_interaction_at < ?', 7.days.ago).where(abandoned: true).find_each do |cart|
      cart.remove_if_abandoned
    end
  end
end
