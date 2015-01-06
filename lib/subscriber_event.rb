class SubscriberEvent
  def self.queue=(queue)
    @queue = queue
  end

  def self.queue
    @queue || SubscriberEvent::NullQueue.new
  end

  class Queue
    def notify_destroyed(user); end
    def notify_email_changed(old_email, new_email); end
    def notify_created(user); end
    def notify_prefs_changed(user); end
  end

  class NullQueue < Queue
  end

  class BunnyQueue < Queue
    def initialize(hostname:)
      @hostname = hostname
    end

    def notify_destroyed(user)
      send_message "destroyed #{user.email}"
    end

    def notify_email_changed(old_email, new_email)
      send_message "email_changed #{old_email} #{new_email}"
    end

    def notify_created(user)
      send_message "created #{user.email} #{user.email_delivery}"
    end

    def notify_prefs_changed(user)
      send_message "prefs_changed #{user.email} #{user.email_delivery}"
    end

    def send_message(msg)
      conn = Bunny.new(hostname: @hostname)
      conn.start

      ch = conn.create_channel
      x = ch.fanout("bcmets.subscribers")
      x.publish(msg, persistent: true)
      conn.close
    end
  end
end
