require 'spec_helper'

describe ArticleBodyCompactFormatter do
  let(:formatter) { ArticleBodyCompactFormatter.new }

  describe '#remove_signature_block' do
    let(:text) {
      [
        "This part should stay\n",
        "\n",
        "-- \n",
        "This is signature block\n"
      ].join
    }
    it "removes lines starting with -- and beyond" do
      formatter.remove_signature_block(text)
        .should == "This part should stay"
    end

    it "doesn't need a newline on the last line" do
      formatter.remove_signature_block(text.strip)
        .should == "This part should stay"
    end
  end


  describe '#remove_attachment_warnings' do
    it "removes a text/html warning" do
      formatter.remove_attachment_warnings([
        "This part should stay\n",
        "\n",
        "[list software deleted text/html attachment]\n",
        "\n"
      ].join).should == "This part should stay\n\n"
    end

    it "works if the attachment is at the end of the string" do
      formatter.remove_attachment_warnings([
        "This part should stay\n",
        "\n",
        "[list software deleted text/html attachment]",
      ].join).should == "This part should stay\n\n"
    end

  end

end
