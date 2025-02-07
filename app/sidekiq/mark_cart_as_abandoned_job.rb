class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    Cart
      .where('last_interaction_at < ?', 3.hours.ago)
      .where(abandoned: false).find_each do |cart|
        cart.mark_as_abandoned
      end
  end
end
