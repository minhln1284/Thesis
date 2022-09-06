class Admin::StaticPagesController < Admin::BaseController
  def index
    @products = Product.group(:category_id).count
    @orders = Order.this_month.group(:user_id).count
    @order_details = OrderDetail.this_month.group(:product_id).count
  end
end
