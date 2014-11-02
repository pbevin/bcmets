# Stolen from pickle/parser/matchers.rb and pickle/parser.rb
def match_quoted
  '(?:[^\\"]|\\.)*'
end

def match_value
  "(?:\"#{match_quoted}\"|nil|true|false|[+-]?[0-9_]+(?:\\.\\d+)?)"
end

def match_field
  "(?:[\\w\\.]+: #{match_value})"
end

def match_fields
  "(?:#{match_field}, )*#{match_field}"
end

def capture_field
  "(#{match_field})"
end

def capture_value
  "(#{match_value})"
end

def capture_fields
  "(#{match_fields})"
end

def capture_key_and_value_in_field
  "(?:([\\w+\\.]+): #{capture_value})"
end

def parse_fields(fields)
  if fields.blank?
    {}
  elsif fields =~ /^#{match_fields}$/
    fields.scan(/(#{match_field})(?:,|$)/).inject({}) do |m, match|
      m.merge(parse_field(match[0]))
    end
  else
    fail ArgumentError, "The fields string is not in the correct format.\n\n'#{fields}' did not match: #{match_fields}"
  end
end

def parse_field(field)
  if field =~ /^#{capture_key_and_value_in_field}$/
    { $1 => eval($2) }
  else
    fail ArgumentError, "The field argument is not in the correct format.\n\n'#{field}' did not match: #{match_field}"
  end
end
