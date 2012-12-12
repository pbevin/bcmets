class UsersController < ApplicationController
  before_filter :require_admin, :only => [:index, :destroy]

  def index
    @users = User.all(:order => "created_at DESC")
    render :index, :layout => "admin"
  end

  def new
    @user = User.new
    @admin = logged_in_as_admin
    @button_label = @admin ? "Submit" : "Sign up"
  end

  def edit
    if params[:id] != 'current' && logged_in_as_admin
      @user = User.find_by_id(params[:id])
      render :template => "users/edit_root"
    else
      return require_login if !current_user
      @user = current_user
      @user.guess_location(request.remote_ip)
    end
  end

  def create
    if params[:user][:active] == "1" && logged_in_as_admin
      create_and_activate
    else
      p = params[:user].slice(:name, :email)
      @user = User.new(p)
      @user.email_delivery = "none"
      if @user.signup!
        begin
          @user.deliver_activation_instructions!
        rescue => e
          puts e
          @user.destroy
        end
        if logged_in_as_admin
          flash[:notice] = "User added"
        else
          flash[:notice] = 'Registration successful.  Please check your email for activation instructions.'
        end
        redirect_to(root_url)
      else
        render :action => "new"
      end
    end
  end

  def create_and_activate
    @user = User.new(params[:user])
    @user.activate!

    if @user.signup!
      @user.update_mailman
      flash[:notice] = "User added"
      redirect_to(root_url)
    else
      render :action => :new
    end
  end
  private :create_and_activate

  def update
    if params[:id] == 'current' || !logged_in_as_admin
      return require_login if !current_user
      @user = current_user
    else
      @user = User.find(params[:id])
    end

    if @user.update_attributes(params[:user])
      if params[:user][:active] && !@user.active?
        @user.activate!
      end
      @user.update_mailman

      if params[:user][:photo].blank?
        flash[:notice] = 'Profile updated'
        redirect_to user_path('current')
      else
        render :action => "crop"
      end
    else
      render :action => "edit"
    end
  end

  def edit_email
    @email_change = EmailChange.new(:new_email => current_user.email)
  end

  def save_email
    @email_change = EmailChange.new(params[:email_change])
    @email_change.old_email = current_user.email
    if @email_change.valid?
      current_user.delete_from_mailman
      current_user.update_attributes(:email => @email_change.new_email)
      current_user.update_mailman

      flash[:notice] = "Email changed to #{@email_change.new_email}."
      redirect_to edit_user_path(current_user)
    else
      render :action => "edit_email"
    end
  end

  def edit_password
    @password_change = PasswordChange.new
    logger.debug @password_change
  end

  def save_password
    @password_change = PasswordChange.new(params[:password_change])
    if @password_change.valid? && @password_change.old_password_correct?(current_user)
      current_user.password = @password_change.new_password
      current_user.save!
      flash[:notice] = 'Password changed.'
      redirect_to current_user
    else
      render :action => 'edit_password'
    end
  end

  def show
    if params[:id] == 'current'
      return require_login if !current_user
      @user = current_user
    else
      @user = User.find(params[:id])
    end
    @articles = @articles = Article.find_all_by_email(@user.email, :order => "sent_at DESC").paginate(:page => params[:page])
  end

  def password
    if request.post?
      @user = User.find_by_email(params[:email])
      if @user
        @user.reset_password!
        flash[:notice] = "Instructions sent to #{params[:email]}"
      else
        flash[:notice] = "No such email"
      end
      redirect_to login_path
    end
  end

  def profile
    @user = User.find(params[:id])
    @articles = Article.find_all_by_email(@user.email, :order => "sent_at DESC")
  end

  def unsubscribe
    secret = params[:key]
    user = current_user
    if secret != user.secret_key
      flash[:notice] = "Something went wrong: please contact owner@bcmets.org if you want to unsubscribe."
      return redirect_to current_user
    end
    user.delete_from_mailman
    user.destroy
    flash[:notice] = "Your account has been deleted."
    redirect_to root_url
  end

  def destroy
    @user = User.find(params[:id])
    @user.delete_from_mailman
    @user.destroy
    flash[:notice] = "User deleted"
    redirect_to users_path
  end
end
