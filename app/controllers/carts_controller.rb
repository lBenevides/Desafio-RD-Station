class CartsController < ApplicationController
  before_action :set_session, only: [:create]
  before_action :get_session, except: [:create]

  before_action :validate_product, only: [:create, :add_item]
  before_action :validate_quantity, only: [:create, :add_item]

  # As actions de create/add_item são parecidas e estao com logicas quase duplicadas. Acharia melhoror unificar as duas, 
  # porem o desafio me deixou em duvida se eu poderia adicionar logica de criar a sessão em outras
  # actions alem do endpoint de POST cart
  # A descrição tambem deixa em duvida se no POST cart eu poderia incrementar a quantia de produtos, 
  # entao optei por apenas retornar erro de que o produto ja existe
  #

  def create
    cart_items = @cart.cart_items.build(product: @product, quantity: @quantity)

    if cart_items.save
      @cart.save
      render json: formatted_response(@cart), status: :created
    else
      render json: { errors: cart_items.errors }, status: :unprocessable_entity
    end
  end

  def add_item
    cart_items =  @cart.cart_items.find_by(product: @product)

    if cart_items&.increment(:quantity, @quantity)
      cart_items.save
      @cart.save # isto é necessario para fazer com que o total_price seja atualizado
      render json: formatted_response(@cart), status: :ok
    else
      render json: { error: 'Produto não encontrado' }, status: :not_found
    end
  end

  def show
    render json: formatted_response(@cart), status: :ok
  end

  def remove_product
    product = @cart.cart_items.find_by(product_id: params[:product_id])

    if product
      product.destroy
      @cart.save

      render json: formatted_response(@cart), status: :ok
    else
      render json: { error: 'Produto não encontrado' }, status: :not_found
    end
  end

  private 

  def set_session
    if session[:cart_id]
      @cart = Cart.find_by(id: session[:cart_id])
    end

    if @cart.blank?
      @cart = Cart.create(total_price: 0)
      session[:cart_id] = @cart.id
    end
  end

  def get_session
    @cart = Cart.find_by(id: session[:cart_id]) 

    return render json: { error: 'Carrinho não encontrado' }, status: :not_found unless @cart
  end

  def cart_params
    params.permit(:product_id, :quantity)
  end

  def validate_product
    @product = Product.find_by(id: cart_params[:product_id])

    return render json: { error: 'Produto não encontrado' }, status: :not_found unless @product
  end

  def validate_quantity
    @quantity = cart_params[:quantity].to_i

    return render json: { error: 'Quantidade deve ser maior que 0' }, status: :not_found unless @quantity > 0
  end

  def formatted_response(cart)
    {
      id: cart.id,
      products: formated_cart_items(cart.cart_items),
      total_price: cart.total_price
    }
  end

  def formated_cart_items(cart_items)
    cart_items.map do |p|
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
