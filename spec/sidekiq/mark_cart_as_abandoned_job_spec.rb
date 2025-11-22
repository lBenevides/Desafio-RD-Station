require 'rails_helper'
RSpec.describe MarkCartAsAbandonedJob, type: :job do

  it 'marks carts with abandoned status when last interaction is more than 3 hours' do
    cart = create(:cart, last_interaction_at: 3.hours.ago) 

    expect { MarkCartAsAbandonedJob.new.perform }.to change { cart.reload.status }.from('active').to('abandoned')
  end

  it 'do not marks carts with abandoned status when last interaction is less than 3 hours' do
    cart = create(:cart, last_interaction_at: 2.hours.ago) 

    expect { MarkCartAsAbandonedJob.new.perform }.to_not change { cart.reload.status }
  end
end
