class ShippingDestinationsController < ApplicationController
  # GET /shipping_destinations
  # GET /shipping_destinations.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.home'), '/'
    add_breadcrumb I18n.t('breadcrumbs.shipping_destinations'), '/shipping_destinations', {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => ShippingDestinationsDatatable.new(view_context, context_company_id) }
    end
  end

  # GET /shipping_destinations/1
  # GET /shipping_destinations/1.json
  def show
    @shipping_destination = ShippingDestination.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shipping_destination }
    end
  end

  # GET /shipping_destinations/new
  # GET /shipping_destinations/new.json
  def new
    @shipping_destination = ShippingDestination.new
    @shipping_destination.company_id = context_company_id

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/shipping_destinations/shipping_destinations_edit", :layout => false, :status => :created
        end
      }
    end
  end

  # GET /shipping_destinations/1/edit
  def edit
    @shipping_destination = ShippingDestination.find(params[:id])
  end

  # POST /shipping_destinations
  # POST /shipping_destinations.json
  def create
    @shipping_destination = ShippingDestination.new(params[:shipping_destination])

    respond_to do |format|
      if @shipping_destination.save
        format.html {
          if request.xhr?
            render :partial => "setup/forms/shipping_destinations/shipping_destinations_edit", :locals => {:shipping_destination => @shipping_destination, :read_only => false}, :layout => false, :status => :created
          end
        }
      else

        format.html {
          if request.xhr?
            render :partial => "setup/forms/shipping_destinations/shipping_destinations_edit", :locals => {:shipping_destination => @shipping_destination, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  # PATCH/PUT /shipping_destinations/1
  # PATCH/PUT /shipping_destinations/1.json
  def update
    @shipping_destination = ShippingDestination.find(params[:id])

    respond_to do |format|
      if @shipping_destination.update_attributes(params[:shipping_destination])
        format.html { redirect_to @shipping_destination, notice: 'Shipping destination was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shipping_destination.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_destinations/1
  # DELETE /shipping_destinations/1.json
  def destroy
    @shipping_destination = ShippingDestination.find(params[:id])
    @shipping_destination.destroy

    respond_to do |format|
      format.html { redirect_to shipping_destinations_url }
      format.json { head :no_content }
    end
  end
end
