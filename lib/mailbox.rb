class Mailbox
  include Enumerable

  def initialize(filename)
    @filename = filename
  end

  def each_message
    starting = true
    article = ''
    lineno = 0
    File.open(@filename, "rb") do |file|
      begin
        file.each_line do |line|
          lineno += 1
          if line =~ /^From (.*)/
            if !starting
              yield article
              article = ''
            end
            starting = false
          end
          article += line
        end
      rescue => e
        $stderr.puts "Error on line #{lineno}: #{e.message}"
        raise
      end
    end
    yield article unless starting
  end
  alias_method :each, :each_message
end
