class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  before_save :calculate_total_price

  enum status: { active: 0, abandoned: 1 }

  def calculate_total_price
    self.total_price = cart_items.sum do |item|
      item.product.price * item.quantity
    end
  end

  def mark_as_abandoned
    if last_interaction_at < 3.hours.ago
      update(status: 'abandoned')
    end
  end

  def remove_if_abandoned
    if abandoned? && last_interaction_at < 7.days.ago
      destroy
    end
  end
end
