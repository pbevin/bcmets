class ActivationsController < ApplicationController
  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    if !@user
      flash[:notice] = "You have already activated your account."
      if !current_user
        flash[:notice] += " " + self.class.helpers.link_to("Click here to login", login_url)
      end
      redirect_to root_url
    end
  end

  def create
    @user = User.find(params[:id])
    vals = {
      :password => params[:user][:password],
      :password_confirmation => params[:user][:password_confirmation]
    }

    if @user.update_attributes(params[:user]) && @user.activate!
      @user.deliver_activation_confirmation!
      UserSession.create(@user)
      @user.update_mailman
      flash[:notice] = "Thank you for registering!  Please check your email again for handy tips on using bcmets."
      redirect_to root_url
    else
      render :new
    end
  end

  def reset_password
    new
  end    
end
