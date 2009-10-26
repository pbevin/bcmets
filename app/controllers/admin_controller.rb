class AdminController < ApplicationController
  before_filter :logged_in_as_admin

  def index
  end
  
  def users
    @users = User.find(:all, :order => :email)
  end
  
  def mailman_import
    if request.post?
      users = Mailman::parse(params[:file][:name])
      
      if !users.empty?
        User.delete_all(["email <> ?", 'pete@petebevin.com'])
        errors = []
        users.each do |u|
          next if u[:email] == 'pete@petebevin.com'

          delivery_type = "all"
          delivery_type = "digest" if u[:digest]
          delivery_type = "none" if u[:nomail]
        
          u[:name] = u[:email] if u[:name].nil? || u[:name] == ''
        
          user = User.new(
            :name => u[:name],
            :email => u[:email],
            :password => u[:password],
            :email_delivery => delivery_type)
          user.active = true
          user.save || errors << u[:email]
        end
        logger.warn "Errors for #{errors.inspect}" if !errors.empty?
        flash[:notice] = "Imported file with #{errors.size} errors"
      else
        flash[:notice] = "No users to import"
      end
      
      redirect_to :action => :index
    end
  end
  
  private
  
  def logged_in_as_admin
    if !current_user || current_user.email != 'pete@petebevin.com'
      flash[:notice] = "Login first please"
      redirect_to root_url
    end
  end
end
