class ArticleBodyCompactFormatter < ArticleBodyFormatter
  include Fixpoint

  def format(text)
    text = sanitize(text)
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
    fixpoint(text) { |t| t.gsub(/^--\s*\n(.*\n){,5}.*\s*\Z/, '').strip }
  end

  def article_format(text)
    text = remove_attachment_warnings(text)
    text = remove_signature_block(text)
    text = correct_newlines(text)
    paragraphs = text.split(/\n{2,}/)

    if paragraphs.empty?
      content_tag("p", nil)
    else
      paragraphs.map! { |paragraph|
        if paragraph =~ /\A>/
          paragraph = paragraph.gsub(/^>[^\S\n]*/, '')
          content_tag("blockquote", article_format(paragraph))
        else
          paragraph = paragraph.gsub(/([^\n]\n)(?=[^\n])/, '\1<br />')
          content_tag("p", raw(paragraph))
        end
      }.join("\n\n").html_safe
    end
  end
end
