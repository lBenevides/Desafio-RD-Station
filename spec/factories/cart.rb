FactoryBot.define do
  factory :cart do
    status { 'active' }
    last_interaction_at { Time.now }
    total_price { 0 }

    factory :shopping_cart do

    end

    factory :abandoned_cart do
      status { 'abandoned' }
      last_interaction_at { 7.days.ago }

    end
  end
end
