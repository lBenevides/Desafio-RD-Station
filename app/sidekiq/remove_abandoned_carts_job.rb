class RemoveAbandonedCartsJob
  include Sidekiq::Job
  # fiquei em duvida na utilizacao do nome do worker
  # em geral, usaria algo feito CartRemoverJob ou CartRemoverWorker
  # mas preferi seguir a convencao do outro job MarkCartAsAbandonedJob

  def perform
    carts = Cart.where(status: 'abandoned')

    # Devido ao metodo mark_as_abandoned, optei por fazer com each loop
    #  mas acho que seja mais performatico utilizar algo feito
    #  Cart.where(status: 'abandoned').where('last_interacion_at < ?', 7.days.ago )
    #  carts.destroy_all
    #  isto evitaria loops e faria uma operação unica

    carts.each do |cart|
      cart.remove_if_abandoned
    end
  end
end
