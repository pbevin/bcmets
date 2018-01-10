class MessageParser
  def parse(text)
    message = Mail.read_from_string(text)

    parent = parse_parent(message.in_reply_to, message.references)
    addr = parse_addr(message[:from].value)
    body = CharsetFixer.new("utf-8").fix(parse_body(message))
    received_at = parse_envelope_date(message)

    Article.new(
      name: addr.name,
      email: addr.email,
      subject: fix_subject(message.subject),
      received_at: received_at,
      sent_at: message.date,
      parent_msgid: parent,
      msgid: "<#{message.message_id}>",
      body: body
    )
  end

  def parse_parent(in_reply_to, references)
    ref = best_reference_id(in_reply_to, references)
    if ref.blank?
      nil
    elsif ref =~ /^<.*>$/
      ref
    else
      "<#{ref}>"
    end
  end

  def best_reference_id(in_reply_to, references)
    if in_reply_to.blank? || in_reply_to == "<>"
      Array(references).first
    else
      in_reply_to
    end
  end

  def parse_addr(value)
    case value
    when /^(.*) <(.*)>$/
      Addr.from($1, fix_email($2))
    when /^<(.*)>$/, /^(.*)$/
      email = fix_email($1)
      Addr.from(email, email)
    end
  end

  def parse_body(message)
    if message.multipart?
      walk_parts(message.body.parts).join
    else
      message.body.decoded
    end
  end

  def walk_parts(parts)
    parts.flat_map do |part|
      if part.multipart?
        walk_parts(part.parts)
      elsif part.mime_type == "text/plain"
        [part.decoded]
      else
        []
      end
    end
  end

  def parse_envelope_date(message)
    message.envelope_date
  rescue Mail::Field::IncompleteParseError
    if message.raw_envelope =~ /  (.*)$/
      $1
    end
  end

  def fix_email(email)
    email.gsub(/\.bcmets\.email\Z/, '')
  end

  def fix_subject(subject)
    subject
      .gsub(/\s{2,}/, " ") # remove extra spacing
      .gsub(/\[.*\]\s*/, "") # remove [bcmets] at start
  end

  class Addr
    include Anima.new(:name, :email)

    def self.from(name, email)
      new(name: name, email: email)
    end
  end
end
