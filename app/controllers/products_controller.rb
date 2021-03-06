class ProductsController < ApplicationController
	before_action :authenticate_user!, only: [:favor, :unfavor]
	before_action :validate_query_string, only: [:search]


	def index
		@books = Product.where(:category => "book")
		@dresses = Product.where(:category => "dress")
		@cars = Product.where(:category => "car")
		@wines = Product.where(:category => "wine")
	end

	def show
		@product = Product.find(params[:id])
		@reviews_all = @product.reviews
		@reviews = cate_reviews
		if @reviews_all.count > 0
			@good_percent = @reviews_all.good.count.to_f / @reviews_all.count
			@fair_percent = @reviews_all.fair.count.to_f / @reviews_all.count
			@bad_percent = @reviews_all.bad.count.to_f / @reviews_all.count
		else
			@good_percent = 1
			@fair_percent = 0
			@bad_percent = 0
		end
	end

	def search
		@products = Product.ransack({:title_cont => @q}).result(:distinct => true)
	end

	def favor
		@product = Product.find(params[:id])
		current_user.favor!(@product)
		redirect_to :back
	end

	def unfavor
		@product = Product.find(params[:id])
		current_user.unfavor!(@product)
		redirect_to :back
	end

	def add_to_cart
		@product = Product.find(params[:id])
		if current_cart.products.include?(@product)
			redirect_to :back, alert: "此商品已经加入购物车"
		else
			current_cart.add_product_to_cart(@product)
			redirect_to :back, notice: "加入购物车"
		end
		
	end


	protected

	def validate_query_string
		@q = params[:query_string].gsub(/\|\'|\/|\?/, "") if params[:query_string].present?
	end	

	def cate_reviews	
		case params[:review_cate]
		when "good"
			@product.reviews.good
		when "fair"
			@product.reviews.fair
		when "bad"
			@product.reviews.bad
		else
			@product.reviews
		end
	end
end
