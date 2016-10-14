class CompanyPackagingTypesController < ApplicationController
  # GET /company_packaging_types
  # GET /company_packaging_types.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.home'), '/'
    add_breadcrumb I18n.t('breadcrumbs.packaging_types'), '/company_packaging_types', {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => PackagingTypeDatatable.new(view_context, context_company_id) }
    end
  end

  # GET /company_packaging_types/1
  # GET /company_packaging_types/1.json
  def show
    @company_packaging_type = CompanyPackagingType.find(params[:id])


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @company_packaging_type }
    end
  end

  # GET /company_packaging_types/new
  # GET /company_packaging_types/new.json
  def new
    @company_packaging_type = CompanyPackagingType.new
    @company_packaging_type.company_id = context_company_id

    if context_company.fedex_setting.present?
      @packaging_types = PackagingType.all.map { |pt| [I18n.t("packaging_types.#{pt.name.to_s.downcase}"), pt.id] }
    else
      @packaging_types = PackagingType.where(:fedex => false).all.map { |pt| [I18n.t("packaging_types.#{pt.name.to_s.downcase}"), pt.id] }
    end


    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/packaging_types/packaging_types_edit", :layout => false, :status => :created
        end
      }
    end
  end

  # GET /company_packaging_types/1/edit
  def edit
    @company_packaging_type = CompanyPackagingType.find(params[:id])
  end

  # POST /company_packaging_types
  # POST /company_packaging_types.json
  def create
    @company_packaging_type = CompanyPackagingType.new(params[:company_packaging_type])
    if context_company.fedex_setting.present?
      @packaging_types = PackagingType.all.map { |pt| [I18n.t("packaging_types.#{pt.name.to_s.downcase}"), pt.id] }
    else
      @packaging_types = PackagingType.where(:fedex => false).all.map { |pt| [I18n.t("packaging_types.#{pt.name.to_s.downcase}"), pt.id] }
    end

    respond_to do |format|
      if @company_packaging_type.save
        format.html {
          if request.xhr?
            render :partial => "setup/forms/packaging_types/packaging_types_edit", :locals => {:company_packaging_type => @company_packaging_type, :read_only => false}, :layout => false, :status => :created
          end
        }
      else

        format.html {
          if request.xhr?
            render :partial => "setup/forms/packaging_types/packaging_types_edit", :locals => {:company_packaging_type => @company_packaging_type, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end


    end
  end

  # PATCH/PUT /company_packaging_types/1
  # PATCH/PUT /company_packaging_types/1.json
  def update
    @company_packaging_type = CompanyPackagingType.find(params[:id])

    respond_to do |format|
      if @company_packaging_type.update_attributes(params[:company_packaging_type])
        format.html { redirect_to @company_packaging_type, notice: 'Company packaging type was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @company_packaging_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /company_packaging_types/1
  # DELETE /company_packaging_types/1.json
  def destroy
    @company_packaging_type = CompanyPackagingType.find(params[:id])
    @company_packaging_type.destroy

    respond_to do |format|
      format.html { redirect_to company_packaging_types_url }
      format.json { head :no_content }
    end
  end
end
