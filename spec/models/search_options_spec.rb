require_relative "../../app/models/search_options"

describe SearchOptions do
  let(:options) { search.search_options }

  shared_examples_for "by date" do
    it "searches by received_at" do
      options[:order].should == "received_at desc"
    end

    it "is listed as search by date" do
      search.sorting_by.should == "date"
    end

    it "switches to relevance search" do
      search.switch_sort.should == "relevance"
    end
  end

  shared_examples_for "by relevance" do
    it "searches by default order" do
      options[:order].should be_nil
    end

    it "is listed as search by relevance" do
      search.sorting_by.should == "relevance"
    end

    it "switches to sort by date" do
      search.switch_sort.should == "date"
    end
  end

  context "by date" do
    let(:search) { SearchOptions.new(q: "taxol", sort: "date") }
    it_behaves_like "by date"
  end

  context "by relevance" do
    let(:search) { SearchOptions.new(q: "taxol", sort: "relevance") }
    it_behaves_like "by relevance"
  end


  context "with no sort type declared" do
    let(:search) { SearchOptions.new(q: "taxol") }
    it_behaves_like "by date"
  end

  describe '#search' do
    let(:search) { SearchOptions.new(q: "taxol") }
    let(:article_base) { double("Article") }

    context "when search is offline" do
      before(:each) do
        Array.any_instance.stub(:paginate) { [] }
        article_base.stub(:search).and_raise("offline")
        search.run(article_base)
      end

      it "returns 0 articles" do
        search.articles_count.should == 0
        search.total_count.should == 0
      end

      it "sets an error" do
        search.error.should_not be_nil
      end
    end

    context "when search is working" do
      let(:results) { double(count: 20, total_count: 1228) }
      before(:each) do
        article_base.stub(:search).and_return(results)
        search.run(article_base)
      end

      it "returns results" do
        search.articles.should == results
        search.articles_count.should == 20
        search.total_count.should == 1228
      end
    end
  end
end
