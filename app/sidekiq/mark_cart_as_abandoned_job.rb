class MarkCartAsAbandonedJob
  include Sidekiq::Job


  def perform
    carts = Cart.where(status: 'active')

    # Devido ao metodo mark_as_abandoned, optei por fazer com each loop
    #  mas acho que seja mais performatico utilizar algo feito
    #  Cart.where(status: 'active').where('last_interacion_at < ?', 3.hours.ago )
    #  carts.update_all(status: 'abandoned')
    #  isto evitaria loops e faria uma operação unica
    carts.each do |cart|
      cart.mark_as_abandoned
    end
  end
end
