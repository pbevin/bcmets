class CharsetFixer
  def initialize(encoding)
    @encoding = encoding
  end

  def fix(text)
    str = text.dup

    begin
      str.force_encoding(@encoding)
    rescue ArgumentError
    end

    if str.valid_encoding?
      str.encode("UTF-8")
    else
      str.force_encoding("iso8859-1").encode("utf-8")
    end
  end

#   body.force_encoding("CP1252") if !body.valid_encoding?
#   body.encode("UTF-8")
end
