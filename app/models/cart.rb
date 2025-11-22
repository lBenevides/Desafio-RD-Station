class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado
  has_many :cart_products, dependent: :destroy
  has_many :products, through: :cart_products

  before_save :calculate_total_price
  after_destroy :calculate_total_price

  enum status: { active: 0, abandoned: 1 }

  def calculate_total_price
    self.total_price = cart_products.sum do |item|
      item.product.price * item.quantity
    end
  end
end
