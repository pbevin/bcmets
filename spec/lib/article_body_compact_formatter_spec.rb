require 'spec_helper'

describe ArticleBodyCompactFormatter do

  describe '#remove_signature_block' do
    let(:formatter) { ArticleBodyCompactFormatter.new }
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
end
