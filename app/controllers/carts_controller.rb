class CartsController < ApplicationController
  before_action :set_session, only: [:create, :show, :remove_product]

  ## TODO Escreva a lógica dos carrinhos aqui

  def create
      product = Product.find(cart_params[:product_id])
      quantity = cart_params[:quantity]
      cart_products = @cart.cart_products.find_or_initialize_by(product: product)

      cart_products.increment!(:quantity, quantity)

      if @cart.save
        render json: formatted_response(@cart)
      else
        render json: @cart.errors, status: :unprocessable_entity
      end
  end

  def show
    render json: formatted_response(@cart)
  end

  def remove_product
    product = @cart.cart_products.find_by(product_id: params[:product_id])

    if product
      product.destroy
      @cart.save
      render json: formatted_response(@cart), status: :ok
    else
      render json: { error: 'Produto não encontrado' }, status: :unprocessable_entity
    end
  end

  private 

  def set_session
    if session[:cart_id]
      @cart = Cart.find(session[:cart_id])
    else
      @cart = Cart.create(total_price: 0)
      session[:cart_id] = @cart.id
    end
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def formatted_response(cart)
    {
      id: cart.id,
      products: formated_cart_product(cart.cart_products),
      total_price: cart.total_price
    }
  end

  def formated_cart_product(cart_products)
    cart_products.map do |p|
      {
        id: p.product.id,
        name: p.product.name,
        quantity: p.quantity,
        unit_price: p.product.price,
        total_price:  p.quantity * p.product.price
      }
    end
  end
end
