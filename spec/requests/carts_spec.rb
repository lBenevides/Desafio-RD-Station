require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /cart" do
    let(:product) { Product.create(name: "Test Product", price: 10.0) }

    context 'when there is no cart' do
      it 'create cart and add product' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

        expect(response).to have_http_status(201)
        formated_response = JSON.parse(response.body)
        expect(formated_response.dig('products').first.dig('id')).to eq(product.id)
        expect(formated_response.dig('products').first.dig('unit_price').to_f).to eq(product.price)
        expect(formated_response.dig('total_price').to_f).to eq(product.price * 2)
      end
    end

    context 'when already exists a cart with a product' do
      let(:cart) { Cart.create(total_price: 0) }
      let(:product_2) { Product.create(name: "Test Product 2", price: 15.0) }
      let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

      before do
        allow_any_instance_of(CartsController).to receive(:session) { { cart_id: cart.id } }
      end

      it 'add another product to the cart' do
        post '/cart', params: { product_id: product_2.id, quantity: 2 }, as: :json

        expect(response).to have_http_status(201)
        formated_response = JSON.parse(response.body)
        expect(formated_response.dig('products').first.dig('id')).to eq(product.id)
        expect(formated_response.dig('products').second.dig('id')).to eq(product_2.id)
        expect(formated_response.dig('products').second.dig('quantity')).to eq(2)
        expect(formated_response.dig('total_price').to_f).to eq(40.00)
      end

      it 'do not accept an existing product in the cart' do
        post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body).dig('errors', 'product_id')).to eq(['Produto já existe no carrinho'])
      end
    end
  end

  # Alteracão no nome da rota. Na descricao do desafio, é add_item, adaptado para seguir o padrao
 
  describe "POST /add_item" do
    let(:cart) { Cart.create(total_price: 0) }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let!(:cart_item) { CartItem.create(cart: cart, product: product, quantity: 1) }

    before do
      allow_any_instance_of(CartsController).to receive(:session) { { cart_id: cart.id } }
    end

    context 'when the product already is in the cart' do
      subject do
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end

    context 'when the product is not in the cart' do
      it 'updates the quantity of the existing item in the cart' do
        post '/cart/add_item', params: { product_id: 4, quantity: 1 }, as: :json

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)['error']).to eq('Produto não encontrado')
      end
    end
  end

  describe "GET /cart" do
    let(:cart) { Cart.create(total_price: 0) }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let(:product_2) { Product.create(name: "Test Product 2", price: 16.0) }


    context 'when exist a cart with products' do
      before do
        cart.cart_items.create(product: product, quantity: 3) 
        cart.cart_items.create(product: product_2, quantity: 5) 
        cart.save

        allow_any_instance_of(CartsController).to receive(:session) { { cart_id: cart.id } }
      end

      it 'updates the quantity of the existing item in the cart' do
        get '/cart'

        expect(response).to have_http_status(200)
        formated_response = JSON.parse(response.body)

        expect(formated_response.dig('products').first.dig('id')).to eq(product.id)
        expect(formated_response.dig('products').second.dig('id')).to eq(product_2.id)

        expect(formated_response.dig('products').first.dig('total_price').to_f).to eq(30.00)
        expect(formated_response.dig('products').second.dig('total_price').to_f).to eq(80.00)

        expect(formated_response.dig('total_price').to_f).to eq(110.00)
      end
    end

    context 'when do not exist a cart' do
      it 'do not find an created cart' do
        get '/cart'

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)["error"]).to eq('Carrinho não encontrado')
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    let(:cart) { Cart.create(total_price: 0) }
    let(:product) { Product.create(name: "Test Product", price: 10.0) }
    let(:product_2) { Product.create(name: "Test Product 2", price: 16.0) }
    let(:unassigned_product) { Product.create(name: "Produto fora do carrinho", price: 6.0) }

    context 'when exist a cart with products' do
      before do
        cart.cart_items.create(product: product, quantity: 3) 
        cart.cart_items.create(product: product_2, quantity: 5) 
        cart.save

        allow_any_instance_of(CartsController).to receive(:session) { { cart_id: cart.id } }
      end

      it 'remove product when product is in the cart' do
        delete "/cart/#{product_2.id}"

        expect(response).to have_http_status(200)
        formated_response = JSON.parse(response.body)

        expect(formated_response.dig('products').size).to eq(1)
        expect(formated_response.dig('products').first.dig('id')).to eq(product.id)

        expect(formated_response.dig('total_price').to_f).to eq(30.00)
      end

      it 'do not remove product when product is not in the cart' do
        delete "/cart/#{unassigned_product.id}"

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)["error"]).to eq('Produto não encontrado')
      end
    end

    context 'when do not exist a cart' do
      it 'do not find an created cart' do
        delete '/cart/2'

        expect(response).to have_http_status(404)
        expect(JSON.parse(response.body)["error"]).to eq('Carrinho não encontrado')
      end
    end
  end
end
