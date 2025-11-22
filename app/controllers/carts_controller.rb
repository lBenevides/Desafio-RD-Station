class CartsController < ApplicationController
  before_action :set_session, only: [:create]
  before_action :get_session, except: [:create]

  before_action :validate_product, only: [:create, :add_item]

  # As actions de create/add_item são parecidas e estao com logicas quase duplicadas. Acharia melhoror unificar as duas, 
  # porem o desafio me deixou em duvida se eu poderia adicionar logica de criar a sessão em outras
  # actions alem do endpoint de POST cart
  # A descrição tambem deixa em duvida se no POST cart eu poderia incrementar a quantia de produtos, 
  # entao optei por apenas retornar erro de que o produto ja existe
  #

  def create
    quantity = cart_params[:quantity]
    cart_products = @cart.cart_products.build(product: @product, quantity: quantity)

    if cart_products.save
      @cart.save
      render json: formatted_response(@cart), status: :created
    else
      render json: { errors: cart_products.errors }, status: :unprocessable_entity
    end
  end

  def add_item
    quantity = cart_params[:quantity]

    cart_products =  @cart.cart_products.find_by(product: @product)

    if cart_products&.increment!(:quantity, quantity)
      @cart.save
      render json: formatted_response(@cart), status: :ok
    else
      render json: { error: 'Produto não encontrado' }, status: :not_found
    end
  end

  def show
    render json: formatted_response(@cart), status: :ok
  end

  def remove_product
    product = @cart.cart_products.find_by(product_id: params[:product_id])

    if product
      product.destroy
      @cart.save

      render json: formatted_response(@cart), status: :ok
    elseadad
      render json: { error: 'Produto não encontrado' }, status: :not_found
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

  def get_session
    return render json: { error: 'Carrinho não encontrado' }, status: :not_found unless session[:cart_id]

    @cart = Cart.find(session[:cart_id]) 
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def validate_product
    @product = Product.find_by(id: cart_params[:product_id])

    return render json: { error: 'Produto não encontrado' }, status: :not_found unless @product
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
