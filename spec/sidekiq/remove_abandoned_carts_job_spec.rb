require 'rails_helper'
RSpec.describe RemoveAbandonedCartsJob, type: :job do

  it 'remove carts with abandoned status when last interaction was more than 7 days' do
    create(:abandoned_cart)

    expect { RemoveAbandonedCartsJob.new.perform }.to change { Cart.count }.by(-1)
  end

  it 'does not remove carts with abandoned status when last interaction is less than 7 days' do
    create(:abandoned_cart, last_interaction_at: 5.days.ago )

    expect { RemoveAbandonedCartsJob.new.perform }.to change { Cart.count }.by(0)
  end

  it 'does not remove carts with active status when last interaction is less than 7 days' do
    create(:cart)

    expect { RemoveAbandonedCartsJob.new.perform }.to change { Cart.count }.by(0)
  end
end
