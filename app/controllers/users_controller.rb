class UsersController < ApplicationController
  before_filter :require_admin, only: [:index, :destroy]

  def index
    @users = User.order("created_at DESC")
  end

  def new
    @user = User.new
    @admin = logged_in_as_admin
    @button_label = @admin ? "Submit" : "Sign up"
  end

  def edit
    if params[:id] != 'current' && logged_in_as_admin
      @user = User.find_by_id(params[:id])
      render template: "users/edit_root"
    else
      return require_login if !current_user
      @user = current_user
    end
  end

  def create
    if params[:user][:active] == "1" && logged_in_as_admin
      create_and_activate
    else
      p = params.require(:user).permit(:name, :email)
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
        @button_label = @admin ? "Submit" : "Sign up"
        render action: "new"
      end
    end
  end

  def create_and_activate
    @user = User.new(user_params)
    @user.activate!

    if @user.signup!
      SubscriberEvent.queue.notify_created(@user)
      flash[:notice] = "User added"
      redirect_to(root_url)
    else
      render action: :new
    end
  end
  private :create_and_activate

  def update
    action = UserUpdate.new(params[:id], user_params, current_user, logged_in_as_admin)
    case action.run
    when :success
      flash[:notice] = 'Profile updated'
      redirect_to user_path('current')
    when :failure
      @user = User.find(params[:id])
      render action: "edit"
    when :photo_updated
      @user = User.find(params[:id])
      render action: "crop"
    when :require_login
      require_login
    end
  end

  def edit_email
    @email_change = EmailChange.new(new_email: current_user.email)
  end

  def save_email
    @email_change = EmailChange.new(new_email: params[:email_change][:new_email])
    @email_change.old_email = current_user.email
    if @email_change.valid?
      @email_change.execute(current_user)

      flash[:notice] = "Email changed to #{@email_change.new_email}."
      redirect_to edit_user_path(current_user)
    else
      render action: "edit_email"
    end
  end

  def edit_password
    @password_change = PasswordChange.new
    logger.debug @password_change
  end

  def save_password
    @password_change = PasswordChange.new(password_change_params)
    if @password_change.valid? && @password_change.old_password_correct?(current_user)
      current_user.password = @password_change.new_password
      current_user.save!
      flash[:notice] = 'Password changed.'
      redirect_to current_user
    else
      render action: 'edit_password'
    end
  end

  def show
    if params[:id] == 'current'
      return require_login if !current_user
      @user = current_user
    else
      @user = User.find(params[:id])
    end
    @articles = @articles = Article.where("email = ? or user_id = ?", @user.email, @user.id).order("sent_at DESC").paginate(page: params[:page])
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
    @articles = Article.where(email: @user.email).order("sent_at DESC")
  end

  def unsubscribe
    secret = params[:key]
    user = current_user
    if secret != user.secret_key
      flash[:notice] = "Something went wrong: please contact owner@bcmets.org if you want to unsubscribe."
      return redirect_to current_user
    end
    SubscriberEvent.queue.notify_destroyed(user)
    user.destroy
    flash[:notice] = "Your account has been deleted."
    redirect_to root_url
  end

  def destroy
    @user = User.find(params[:id])
    SubscriberEvent.queue.notify_destroyed(@user)
    @user.destroy
    flash[:notice] = "User deleted"
    redirect_to users_path
  end

  private

  def password_change_params
    params.require(:password_change).permit(:old_password, :new_password, :new_password_confirmation)
  end

  def user_params
    admin_params = logged_in_as_admin ? [:active] : []
    params.require(:user).permit(:name, :photo, :email, :password, :location, :email_delivery, *admin_params)
  end
end
