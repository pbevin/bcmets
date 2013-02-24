class CharsetFixer
  def initialize(encoding)
    @encoding = encoding
  end

  def fix(text)
    string = text.dup
    original_encoding = string.encoding

    best_guess = nil

    guesses = [@encoding, Encoding::UTF_8, Encoding::ISO8859_1]
    guesses.each do |guess|
      begin
        string.force_encoding(guess)
        if string.valid_encoding? && string.encode(Encoding::UTF_8)
          best_guess = guess
          break
        end
      rescue ArgumentError, EncodingError
      end
    end

    if best_guess
      string.force_encoding(best_guess)
    else
      string.force_encoding(original_encoding)
    end

    return string.encode(Encoding::UTF_8)
  end
end
