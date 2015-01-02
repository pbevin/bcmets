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
    def notify_destroyed(user)

    end
  end
end
