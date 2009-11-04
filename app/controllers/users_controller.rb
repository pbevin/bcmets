class UsersController < ApplicationController
  def new
    @user = User.new

    @admin = logged_in_as_admin
    @button_label = @admin ? "Submit" : "Sign up"

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    if params[:id] != 'current' && logged_in_as_admin
      @user = User.find_by_id(params[:id])
      render :template => "users/edit_root"
    else
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
      respond_to do |format|
        if @user.signup!
          begin
            @user.deliver_activation_instructions!
          rescue
            @user.destroy
          end
          if logged_in_as_admin
            flash[:notice] = "User added"
          else
            flash[:notice] = 'Registration successful.  Please check your email for activation instructions.'
          end
          format.html { redirect_to(root_url) }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def create_and_activate
    @user = User.new(params[:user])
    @user.activate!

    respond_to do |format|
      if @user.signup!
        @user.update_mailman
        flash[:notice] = "User added"
        format.html { redirect_to(root_url) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    if params[:id] == 'current' || !logged_in_as_admin
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
        redirect_to edit_user_path('current')
      else
        render :action => "crop"
      end
    else
      render :action => "edit"
    end
  end
  
  def crop
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
    @articles = @articles = Article.find_all_by_email(@user.email, :order => "sent_at DESC")
  end
end
