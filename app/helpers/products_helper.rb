module ProductsHelper
  def average_star(ratings)
    sum = 0
    count = 0
    ratings.each do |rating|
      sum += rating.star.to_i
      count += 1
    end
    return sum / count
  end

  def star_statistic(ratings)
    arr = [0, 0, 0, 0, 0, 0]
    sum = 0
    ratings.each do |rating|
      case rating.star
      when 1
        arr[0] += 1
      when 2
        arr[1] += 1
      when 3
        arr[2] += 1
      when 4
        arr[3] += 1
      when 5
        arr[4] += 1
      end
      sum += rating.star
    end
    arr[5] = sum / ratings.size
    return arr
  end

  def current_visitor_selections
    session[:selection] ||= []
    @selections = session[:selection]
  end

  def allow_comment(product)
    allow = false
    product.orders.each do |order|
      if order.user_id == current_user.id
        allow = true
        break
      end
    end
    return allow
  end

  def checkout_these_product(dataset)
    session[:selection] ||= []
    recommend_pids = []
    if !current_user.nil?
      if dataset == 1 and !current_user.recommend_1.nil?
        recommend_pids = eval(current_user.recommend_1)
      elsif dataset == 2 and !current_user.recommend_2.nil?
        recommend_pids = eval(current_user.recommend_2)
      elsif dataset == 3 and !current_user.recommend_3.nil?
        recommend_pids = eval(current_user.recommend_3)
      end
    end

    if session[:selection].present?
      rules = Recommended.all
      rules.each do |rule|
        if rule.dataset == dataset.to_s
          associations = rule.associations.split("=>").map! { |id| id.to_i }
          left = []
          left << associations.first
          check = session[:selection] - left
          if check != session[:selection]
            second = []
            second << associations.second
            recommend_pids = (recommend_pids + second).uniq
          end
        end
      end
    end

    if session[:selection].present?
      session[:selection].each do |pid|
        products = Product.categorized.without_deleted.find_by(id: pid).category.products.sample(2).pluck(:id)
        recommend_pids << products
        recommend_pids.flatten!
        recommend_pids.uniq!
        if recommend_pids.size >= 15
          break
        end
      end
    end
    #-----------------------------------------------------------------------------------
    # if recommend_pids.size > 15
    #   recommend_pids = recommend_pids.take(15)
    # end
    if recommend_pids.size < 15
      take_num = 15 - recommend_pids.size
      extras = Product.categorized.without_deleted.sample(take_num).pluck(:id)
      recommend_pids << extras
    end
    recommend_pids.flatten!
    return recommend_pids
  end

  def categories_of_woman
    cate_w = []
    Category.all.each do |cate|
      if cate.parent_path.present?
        if cate.parent_path.split("/").second.to_i == 2
          cate_w << cate
        end
      end
    end
    return cate_w
  end

  def page_path current_product
    page_path = ["Homepage"]
    product_category = current_product.category.id
    parent_category = current_product.category.category.name
    page_path << parent_category << product_category
    return page_path
  end
end
