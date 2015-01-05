#!/usr/bin/env ruby

require "bunny"
require 'optparse'
require 'fileutils'

class SubscriberDaemon
  attr_reader :options
  def initialize(options)
    @options = options

    # daemonization will change CWD so expand relative paths now
    options[:logfile] = File.expand_path(logfile) if logfile?
    options[:pidfile] = File.expand_path(pidfile) if pidfile?
  end

  def run
    check_pid
    daemonize if daemonize?
    write_pid
    trap_signals

    if logfile?
      redirect_output
    elsif daemonize?
      suppress_output
    end

    conn = Bunny.new(hostname: options[:hostname])
    conn.start

    log = File.open(@options[:logfile] || "subscriberd.log", "a")
    log.sync = true

    ch   = conn.create_channel
    x    = ch.fanout("bcmets.subscribers")
    q    = ch.queue("mailman_updater")
    q.bind(x)

    puts " [*] Waiting for messages. To exit press CTRL+C"

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
  end

  def remove_member(email)
    system "sudo", "-u", "mailman",
      "/home/mailman/bin/remove_members", "--nouserack", "--noadminack", "bcmets", email
  end

  def add_member(email, email_delivery)
    system "sudo", "-u", "mailman",
      "/home/mailman/delivery", "bcmets", email, email_delivery
  end


  def daemonize?
    options[:daemonize]
  end

  def logfile
    options[:logfile]
  end

  def pidfile
    options[:pidfile]
  end

  def logfile?
    !logfile.nil?
  end

  def pidfile?
    !pidfile.nil?
  end

  def check_pid
    if pidfile?
      case pid_status(pidfile)
      when :running, :not_owned
        puts "A server is already running. Check #{pidfile}"
        exit(1)
      when :dead
        File.delete(pidfile)
      end
    end
  end

  def pid_status(pidfile)
    return :exited unless File.exists?(pidfile)
    pid = ::File.read(pidfile).to_i
    return :dead if pid == 0
    Process.kill(0, pid)      # check process status
    :running
  rescue Errno::ESRCH
    :dead
  rescue Errno::EPERM
    :not_owned
  end


  def daemonize
    exit if fork
    Process.setsid
    exit if fork
    Dir.chdir "/"
  end

  def write_pid
    if pidfile?
      begin
        File.open(pidfile, ::File::CREAT | ::File::EXCL | ::File::WRONLY){|f| f.write("#{Process.pid}") }
        at_exit { File.delete(pidfile) if File.exists?(pidfile) }
      rescue Errno::EEXIST
        check_pid
        retry
      end
    end
  end

  def redirect_output
    FileUtils.mkdir_p(File.dirname(logfile), :mode => 0755)
    FileUtils.touch logfile
    File.chmod(0644, logfile)
    $stderr.reopen(logfile, 'a')
    $stdout.reopen($stderr)
    $stdout.sync = $stderr.sync = true
  end

  def suppress_output
    $stderr.reopen('/dev/null', 'a')
    $stdout.reopen($stderr)
  end

  def trap_signals
    trap(:QUIT) do   # graceful shutdown of run! loop
      @quit = true
    end
  end
end

options        = {}
version        = "1.0.0"
daemonize_help = "run daemonized in the background (default: false)"
pidfile_help   = "the pid filename"
logfile_help   = "the log filename"
include_help   = "an additional $LOAD_PATH"
debug_help     = "set $DEBUG to true"
warn_help      = "enable warnings"

op = OptionParser.new
op.banner =  "Subscriber daemon for bcmets"
op.separator ""
op.separator "Usage: server [options]"
op.separator ""

op.separator "Process options:"
op.on("-d", "--daemonize",   daemonize_help) {         options[:daemonize] = true  }
op.on("-p", "--pid PIDFILE", pidfile_help)   { |value| options[:pidfile]   = value }
op.on("-l", "--log LOGFILE", logfile_help)   { |value| options[:logfile]   = value }
op.on("-H", "--hostname MQHOST", logfile_help)   { |value| options[:hostname]   = value }
op.separator ""

op.separator "Ruby options:"
op.on("-I", "--include PATH", include_help) { |value| $LOAD_PATH.unshift(*value.split(":").map{|v| File.expand_path(v)}) }
op.on(      "--debug",        debug_help)   { $DEBUG = true }
op.on(      "--warn",         warn_help)    { $-w = true    }
op.separator ""

op.separator "Common options:"
op.on("-h", "--help")    { puts op.to_s; exit }
op.on("-v", "--version") { puts version; exit }
op.separator ""

op.parse!(ARGV)

SubscriberDaemon.new(options).run
