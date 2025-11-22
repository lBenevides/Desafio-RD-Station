class CartProduct < ApplicationRecord
  validates :product_id, uniqueness: { scope: :cart_id, message: 'já existe neste carrinho' }
  validates_numericality_of :quantity, greater_than_or_equal_to: 0

  belongs_to :cart
  belongs_to :product

end
