class ArticleBodyCompactFormatter < ArticleBodyFormatter
  def format(text)
    text = correct_newlines(text)
    text = sanitize(text)
    text = remove_signature_block(text)
    text = remove_attachment_warnings(text)
    text = decode_quoted_printable(text)

    auto_link(article_format(h(text)))
  end

  def correct_newlines(text)
    text.gsub(/\r\n?/, "\n")
  end

  def remove_attachment_warnings(text)
    text.gsub(%r{\[list software deleted \w+/\w+ attachment\]\n*}, "")
  end

  def remove_signature_block(text)
    text.gsub(/^--\s*\n(.*\n){,5}.*\s*\Z/, '').strip
  end


  def article_format(text)
    paragraphs = text.split(/\n{2,}/)

    if paragraphs.empty?
      content_tag("p", nil)
    else
      paragraphs.map! { |paragraph|
        if paragraph =~ /^&gt;/
          paragraph = paragraph.gsub(/^&gt;/, '')
          content_tag("blockquote", article_format(paragraph))
        else
          format_para(paragraph)
        end
      }.join("\n\n").html_safe.tap { |p| p p }
    end
  end

  def format_para(paragraph)
    paragraph = paragraph.gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')
    content_tag("p", raw(paragraph))
  end

  def split_paragraphs(text)
    return [] if text.blank?

    text.split(/\n{2,}/).map! do |t|
      t.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') || t
    end
  end
end
