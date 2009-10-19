class ActivationsController < ApplicationController
  def new
    @user = User.find_using_perishable_token(params[:activation_code], 1.week)
    if !@user || @user.active?
      flash[:notice] = "You have already activated your account."
      if !current_user
        flash[:notice] += " " + self.class.helpers.link_to("Click here to login", login_url)
      end
      redirect_to root_url
    end
  end

  def create
    @user = User.find(params[:id])
    if @user.activate!(params)
      @user.deliver_activation_confirmation!
      flash[:notice] = "Thank you for registering!  Please check your email again for tips on using bcmets."
      redirect_to root_url
    else
      render :new
    end
  end
end
