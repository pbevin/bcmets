class CharsetFixer
  def initialize(encoding)
    @encoding = encoding
  end

  def fix(text)
    string = text.dup
    original_encoding = string.encoding

    best_guess = nil

    guesses = [Encoding::UTF_8, Encoding::ISO8859_1, @encoding]
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

    return convert_emoji(string.encode(Encoding::UTF_8))
  end

  def convert_emoji(str)
    str.gsub(/[\u{1f601}-\u{1f60f}]/, ":)")  # smiley faces
       .gsub(/[\u{1f612}-\u{1f616}]/, ":(")  # sad faces
       .gsub(/[\u{1f300}-\u{1f6ff}]/, "")    # remove any other emoji
  end
end
