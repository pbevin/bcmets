module Mailman
  MM_MODERATED = 0x80

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
    SECTIONS = {
      members: :email,
      usernames: :name,
      passwords: :password,
      digest_members: :email,
      delivery_status: :status,
      user_options: :email
    }

    SECTION_START = %r#^\s*'(.*)':\s+\{#
    KEY_VALUE_PAIR = %r{'([^']+)': (.*),?$}

    attr_reader :section, :members
    def initialize
      @section = nil
      @members = []
      @records = {}
    end

    def accept(line)
      if line =~ SECTION_START
        key = $1.to_sym
        if SECTIONS.key?(key)
          @section = key
        end
        line = $'
      end

      if !@section.nil?
        if line =~ KEY_VALUE_PAIR
          email, value = $1, $2
          if @section == :delivery_status
            # Anyone listed in delivery_status is NOMAIL.
            add(email, :nomail, true)
          elsif @section == :user_options
            add(email, :email, email)
            add(email, :moderated, true) if value.to_i & MM_MODERATED != 0
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
      if @records.key?(email)
        @records[email][key] = value
      else
        @members << (@records[email] = { key => value })
      end
    end

    def key_for_current_section
      SECTIONS[@section]
    end
  end
end
