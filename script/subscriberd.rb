#!/usr/bin/env ruby

require "bunny"

conn = Bunny.new(hostname: "mq.local", automatically_recover: false)
conn.start

log = File.open("subscriberd.log", "a")
log.sync = true

ch   = conn.create_channel
x    = ch.fanout("bcmets.subscribers")
q    = ch.queue("mailman_updater")
q.bind(x)

puts " [*] Waiting for messages. To exit press CTRL+C"

def remove_member(email)
  system "sudo", "-u", "mailman",
    "/home/mailman/bin/remove_members", "--nouserack", "--noadminack", "bcmets", email
end

def add_member(email, email_delivery)
  system "sudo", "-u", "mailman",
    "/home/mailman/delivery", "bcmets", email, email_delivery
end

begin
  q.subscribe(block: true, manual_ack: true) do |delivery_info, properties, body|
    puts " [x] Received #{body}"
    log.puts "#{Time.now} #{body}"
    case body
    when /destroyed (.*)/
      remove_member($1)
    when /created (.*) (.*)/, /prefs_changed (.*) (.*)/
      add_member($1, $2)
    when /email_changed (.*) (.*) (.*)/
      old, new, delivery = $1, $2, $3
      remove_member(old)
      add_member(new, delivery)
    end

    ch.ack(delivery_info.delivery_tag)
  end
rescue Interrupt => _
  conn.close
  log.close

  exit(0)
end
