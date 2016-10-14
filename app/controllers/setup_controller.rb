class SetupController < ApplicationController
  def index
    add_breadcrumb I18n.t('breadcrumbs.home'), "/"
    add_breadcrumb I18n.t('breadcrumbs.setup'), "/setup", {:type => "page_title"}


    @company = context_company

    if @company.present? and @company.fedex_setting.blank?
      @company.build_fedex_setting
      @company.save!
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @company }
    end
  end
end
