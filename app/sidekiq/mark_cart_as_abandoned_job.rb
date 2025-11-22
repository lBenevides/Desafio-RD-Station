class MarkCartAsAbandonedJob
  include Sidekiq::Job


  def perform
    carts = Cart.where(status: 'active')

    carts.each do |cart|
      cart.mark_as_abandoned
    end
  end
end
