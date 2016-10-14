class UsersController < ApplicationController
  before_filter :get_user, :only => [:index, :new, :edit]

  # Make the current user object available to views
  #----------------------------------------
  def get_user
    @current_user = current_user
  end

  add_breadcrumb I18n.t('breadcrumbs.home'), '/'

  # GET /users
  # GET /users.xml                                                
  # GET /users.json                                       HTML and AJAX
  #-----------------------------------------------------------------------
  def index
    add_breadcrumb I18n.t('breadcrumbs.users'), users_path, {:type => "page_title"}

    respond_to do |format|
      format.json { render :json => UsersDatatable.new(view_context, context_company_id) }
      format.xml { render :xml => @users }
      format.html
    end
  end


  def edit
    @user = User.find(params[:id])

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/users/user_edit", :locals => {:user => @user, :read_only => false}, :layout => false, :status => :created
        else
          redirect_to(@user, :notice => "")
        end
      }
    end
  end


  def update_basic_details

    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    @user= User.find(params[:id])
    @roles = @user.company_id.present? ? Role.where("name != 'SuperUser'").all : Role.all
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html {
          if request.xhr?
            render :partial => "setup/forms/users/user_edit", :locals => {:user => @user, :read_only => false}, :layout => false, :status => :created
          end
        }
      else
        Rails.logger.info(@user.errors)
        format.html {
          if request.xhr?
            render :partial => "setup/forms/users/user_edit", :locals => {:user => @user, :read_only => false}, :layout => false, :status => :unprocessable_entity
          end
        }
      end
    end
  end

  def delete_user
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { head :no_content }
    end
  end

  def new
    @user = User.new
    @user.company_id = current_user.company_id if current_user.company_id
    @user.company_id = context_company_id if @user.company_id.blank?

    respond_to do |format|
      format.html {
        if request.xhr?
          render :partial => "setup/forms/users/forms/new_user", :locals => {:user => @user, :read_only => false}, :layout => false, :status => :created
        else
          redirect_to(@user, :notice => "")
        end
      }
    end
  end

  def create
    @user = User.new

    @user.company_id = current_user.company_id if current_user.company_id
    @user.company_id = context_company_id if @user.company_id.blank?

    @user.update_attributes(params[:user])
    @user.save

    respond_to do |format|
      if @user.present? && !@user.new_record?
        format.html {
          render :partial => "setup/forms/users/forms/new_user", :locals => {:user => @user, :read_only => false}, :layout => false, :status => :created
        }
        format.xml { head :ok }
      else
        format.html {
          render :partial => "setup/forms/users/forms/new_user", :locals => {:user => @user, :read_only => false}, :layout => false, :status => :unprocessable_entity
        }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  # PUT /users/1.json                                            HTML AND AJAX
  #----------------------------------------------------------------------------
  def update
    if params[:user][:password].blank?
      [:password, :password_confirmation, :current_password].collect { |p| params[:user].delete(p) }
      #else
      #  @user.errors[:base] << t('users.password_not_correct') unless @user.valid_password?(params[:user][:current_password])
    end
    @roles = @user.company_id.present? ? Role.where("name != 'SuperUser'").all : Role.all

    respond_to do |format|
      if @user.errors[:base].empty? and @user.update_attributes(params[:user])
        flash[:notice] = t('users.account_updated')
        format.json { render :json => @user.to_json, :status => 200 }
        format.xml { head :ok }
        format.html { redirect_to @user, notice: 'Channel was successfully updated.' }
      else
        format.json { render :text => t('users.account_not_updated'), :status => :unprocessable_entity } #placeholder
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
        format.html { render :action => :edit, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml, :html)
  end

end