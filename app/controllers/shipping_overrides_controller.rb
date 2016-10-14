class ShippingOverridesController < ApplicationController
  # GET /shipping_overrides
  # GET /shipping_overrides.json
  def index
    #@shipping_overrides = ShippingOverride.search(params[:search]).page(params[:page]).per(15)
    if params[:search]
      @shipping_overrides = ShippingOverride.where('id LIKE ?', "#{params[:search]}%").order('id').page(params[:page]).per(15)
    else
      @shipping_overrides = ShippingOverride.order('id').page(params[:page]).per(15)
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shipping_overrides }
    end
  end

  # GET /shipping_overrides/1
  # GET /shipping_overrides/1.json
  def show
    @shipping_override = ShippingOverride.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shipping_override }
    end
  end

  # GET /shipping_overrides/new
  # GET /shipping_overrides/new.json
  def new
    @shipping_override = ShippingOverride.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shipping_override }
    end
  end

  # GET /shipping_overrides/1/edit
  def edit
    @shipping_override = ShippingOverride.find(params[:id])
  end

  # POST /shipping_overrides
  # POST /shipping_overrides.json
  def create
    @shipping_override = ShippingOverride.new(params[:shipping_override])

    respond_to do |format|
      if @shipping_override.save
        format.html { redirect_to @shipping_override, notice: 'Shipping override was successfully created.' }
        format.json { render json: @shipping_override, status: :created, location: @shipping_override }
      else
        format.html { render action: "new" }
        format.json { render json: @shipping_override.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipping_overrides/1
  # PATCH/PUT /shipping_overrides/1.json
  def update
    @shipping_override = ShippingOverride.find(params[:id])

    respond_to do |format|
      if @shipping_override.update_attributes(params[:shipping_override])
        format.html { redirect_to @shipping_override, notice: 'Shipping override was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shipping_override.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_overrides/1
  # DELETE /shipping_overrides/1.json
  def destroy
    @shipping_override = ShippingOverride.find(params[:id])
    @shipping_override.destroy

    respond_to do |format|
      format.html { redirect_to shipping_overrides_url }
      format.json { head :no_content }
    end
  end
end
