class UsersController < ApplicationController
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def edit
    @user = current_user
    @user.guess_location(request.remote_ip)
  end

  def create
    @user = User.new(params[:user])
    @user.email_delivery = "none"

    respond_to do |format|
      if @user.signup!(params)
        begin
          @user.deliver_activation_instructions!
        rescue
          @user.destroy
        end
        flash[:notice] = 'Registration successful.  Please check your email for activation instructions.'
        format.html { redirect_to(root_url) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Profile updated'
        format.html { redirect_to(root_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
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
