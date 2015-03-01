class ArticleBodyCompactFormatter < ArticleBodyFormatter
  def format(text)
    text = remove_signature_block(text)
    text = decode_quoted_printable(text)

    auto_link(simple_format(h(text)))
  end

  def remove_signature_block(text)
    text.gsub(/^--\s*\n(.*\n){,5}.*\s*\Z/, '').strip
  end
end
