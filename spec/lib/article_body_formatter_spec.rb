require 'rails_helper'

describe ArticleBodyFormatter do
  let(:formatter) { ArticleBodyFormatter.new }
  describe '#decode_quoted_printable' do
    it "converts =20 to space at the end of a line" do
      expect(formatter.decode_quoted_printable("This=20\nworks\n"))
        .to eq("This works\n")
    end
  end
end

