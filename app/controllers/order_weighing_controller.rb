class OrderWeighingController < ApplicationController

  def index
    add_breadcrumb I18n.t('breadcrumbs.home'), '/'
    add_breadcrumb I18n.t('breadcrumbs.order_weighing'), '/order_weighing', {:type => "page_title"}
    @ad_hoc_packaging_id = (CompanyPackagingType.where(:company_id => context_company_id).joins(:packaging_type).where("packaging_types.name = 'AD_HOC'").first.id rescue nil)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def get_order
    order_id = params[:order_id].to_i.to_s
    @order = Order.find_by_id_and_status_and_company_id(order_id, Order::STATUS_PICKED, context_company_id)
    @packaging_types = CompanyPackagingType.where(:company_id => context_company_id)

    if context_company.fedex_setting.blank?
      @packaging_types = @packaging_types.joins(:packaging_type).where('packaging_types.fedex = 0')
    end

    render :partial => 'form', :content_type => 'text/html', :layout => false, :status => :created
  end

  def update

    @order = Order.find(params[:order][:id])
    @order.weigh_order(params[:order], params[:order][:override_shipping_service_id])
    @packaging_types = CompanyPackagingType.where(:company_id => context_company_id)

    respond_to do |format|
      format.html {
        if request.xhr?
          if @order.errors.blank?
            render :partial => "form", :layout => false, :status => :created
          else
            render :partial => "form", :layout => false, :status => :unprocessable_entity
          end

        end
      }
    end
  end
end
