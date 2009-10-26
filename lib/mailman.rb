module Mailman
  def self.parse(filename)
    parser = Parser.new
    open(filename) do |f|
      f.each_line do |line|
        parser.accept(line)
      end
    end
    parser.members
  end

  class Parser
    @@sections = {
      :members => :email,
      :usernames => :name,
      :passwords => :password,
      :digest_members => :email,
      :delivery_status => :status,
    }
    
    SECTION_START = %r#^\s*'(.*)':\s+\{#
    KEY_VALUE_PAIR = %r#'([^']+)': (.*),?$#
    
    attr_reader :section, :members
    def initialize
      @section = nil
      @members = []
      @records = {}
    end
    
    def accept(line)
      if line =~ SECTION_START
        key = $1.to_sym
        if @@sections.has_key?(key)
          @section = key
        end
        line = $'
      end
      
      if @section != nil
        if line =~ KEY_VALUE_PAIR
          email, value = $1, $2
          if @section == :delivery_status
            # Anyone listed in delivery_status is NOMAIL.
            add(email, :nomail, true)
          else
            if value =~ /'(.*)'/
              value = $1
            else
              value = email
            end

            key = key_for_current_section

            add(email, key, value)
          
            if @section == :digest_members
              add(email, :digest, true)
            end
          end
        end
        if line =~ /\},/
          @section = nil
        end
      end
    end
  
    private
    def add(email, key, value)
      if @records.has_key?(email)
        @records[email][key] = value
      else
        @members << (@records[email] = { key => value })
      end
    end
  
    def key_for_current_section
      @@sections[@section]
    end
  end
end