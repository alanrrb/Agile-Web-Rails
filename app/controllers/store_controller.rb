class StoreController < ApplicationController
  before_filter :find_cart, :except => :empty_cart
  
  def index
    @products = Product.find_products_for_sale
  end

  def add_to_cart
    product = Product.find(params[:id])
    @current_item = @cart.add_product(product)
    respond_to do |format|
      format.js if request.xhr?
      format.html {redirect_to_index}
    end
  rescue ActiveRecord::RecordNotFound
    logger.error("Tentativa para acessar o produto #{params[:id]} inválida")
    redirect_to_index("Produto Inválido")      
  end
  
  def empty_cart
    session[:cart] = nil
    redirect_to_index
  end
  
  def checkout
    if @cart.items.empty?
      redirect_to_index("Seu carrinho está vazio!")
    else
      @order = Order.new
    end
  end
  
  def save_order
    @order = Order.new(params[:order])
    @order.add_line_items_from_cart(@cart)
    if @order.save
      session[:cart] = nil
      redirect_to_index("Obrigado por seu pedido")
    else
      render :action => 'checkout'
    end
  end
  
  #sobrescrevendo o metodo authorize para este controller nao precisar de autenticacao
  protected
  def authorize
  end
  
  private
  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'
  end
  
  def find_cart
    @cart = (session[:cart] ||= Cart.new)
  end

end
