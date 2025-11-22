class RenameCartProductsToCartItems < ActiveRecord::Migration[7.1]
  def change
    rename_table :cart_products, :cart_items
  end
end
