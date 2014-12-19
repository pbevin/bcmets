class AdminController < ApplicationController
  before_filter :require_admin

  def mailman_import
    if request.post?
      filename = params[:file][:name]
      if filename =~ /subscribe$/
        import_subscribe_log(filename)
      else
        import_mailman_dump(filename)
      end
      redirect_to action: :index
    end
  end

  private

  def import_mailman_dump(filename)
    users = Mailman.parse(filename)

    if !users.empty?
      errors = []
      users.each do |u|
        next if u[:email] == 'pete@petebevin.com'

        delivery_type = "all"
        delivery_type = "digest" if u[:digest]
        delivery_type = "none" if u[:nomail]

        u[:name] = u[:email] if u[:name].nil? || u[:name] == ''

        user = User.find_by_email(u[:email])
        user ||= User.new(email: u[:email])
        user.name = u[:name]
        user.password = u[:password]
        user.email_delivery = delivery_type
        user.active = true
        user.moderated = u[:moderated]
        user.save || errors << u[:email]
      end
      logger.warn "Errors for #{errors.inspect}" if !errors.empty?
      flash[:notice] = "Imported file with #{errors.size} errors"
    else
      flash[:notice] = "No users to import"
    end
  end

  def import_subscribe_log(filename)
    open filename do |f|
      f.each_line do |line|
        line.strip!
        next unless line =~ /(.*) bcmets: new (\(\w*\) )?([^ ]*)/
        dt = DateTime.strptime($1, "%b %d %H:%M:%S %Y")
        email = $3
        email = $1 if email =~ /"(.*)"/
        logger.debug "#{dt.to_s(:db)} #{email}"
        user = User.find_by_email(email.downcase)
        if user
          user.created_at = dt
          user.save
        end
      end
    end
  end
end
