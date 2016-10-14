class ItemsController < ApplicationController
  add_breadcrumb I18n.t('breadcrumbs.home'), "/"
  # GET      /items
  # GET /items.json
  def index
    add_breadcrumb I18n.t('breadcrumbs.items'), items_path, {:type => "page_title"}
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => ItemsDatatable.new(view_context, context_company_id) }
    end
  end
end
