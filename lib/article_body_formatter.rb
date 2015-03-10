require 'English'

class ArticleBodyFormatter
  include Fixpoint
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  def format(text)
    text = decode_quoted_printable(text)
    text = fix_funny_characters(text)
    text = h(text)
    text = article_format(text)
    text = auto_link(text)
  end

  def article_format(text)
    text = remove_attachment_warnings(text)
    text = remove_signature_block(text)
    text = quote_original_message(text)
    text = correct_newlines(text)
    paragraphs = text.split(/\n{2,}/)

    if paragraphs.empty?
      content_tag("p", nil)
    else
      paragraphs.map! { |paragraph|
        if paragraph =~ /\A&gt;/
          paragraph = paragraph.gsub(/^&gt;[^\S\n]*/, '')
          content_tag("blockquote", article_format(paragraph))
        else
          paragraph = paragraph.gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')
          content_tag("p", raw(paragraph))
        end
      }.join("\n\n").html_safe
    end
  end

  def correct_newlines(text)
    text.gsub(/\r\n?/, "\n")
  end

  def remove_attachment_warnings(text)
    text.gsub(%r{\[list software deleted \w+/\w+ attachment\]\n*}, "")
  end

  def remove_signature_block(text)
    fixpoint(text) { |t| t.gsub(/^--\s*\n(.*\n){,5}.*\s*\Z/, '').strip }
  end

  def fix_funny_characters(text)
    text.gsub(/[\u00c2\u00a0]/, " ")
  end

  def quote_original_message(text)
    text.lines.inject(["", false]) do |memo, line|
      lines, quoting = memo
      if quoting
        [lines + "&gt;" + line, true]
      elsif start_of_quoted_message?(line)
        [lines + "\n", true]
      else
        [lines + line, false]
      end
    end.first
  end

  def start_of_quoted_message?(line)
    line == "-----Original Message-----\n" ||
      line =~ /^\s*On [A-Z][a-z][a-z].*(AM|PM), .* wrote:$/
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

  def h(text)
    ERB::Util.html_escape(text)
  end
end
