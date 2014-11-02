class ArticleBodyFormatter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  def h(text)
    ERB::Util.html_escape(text)
  end

  def format(text)
    auto_link(simple_format(h(decode_quoted_printable(text))))
  end

  def decode_quoted_printable(text)
    if text =~ /=20$/
      text = text
             .gsub(/=20\n/, " ")
             .gsub(/=\n/, "")
             .gsub(/\n/m, $INPUT_RECORD_SEPARATOR)
             .gsub(/=([\dA-F]{2})/) { hex_to_utf8($1.hex) }
    end

    text
  end

  def hex_to_utf8(code)
    # 99% of the time, code is 0x20 (space) or 0x3D (equal sign).
    # But sometimes, it's a funny character, which usually comes from
    # silly Windows clients.  So we assume ISO8859-1, but return it
    # encoded as UTF-8.
    code.chr.force_encoding(Encoding::ISO8859_1).encode(Encoding::UTF_8)
  end
end
