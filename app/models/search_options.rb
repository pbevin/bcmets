class SearchOptions
  attr_reader :sorting_by, :switch_sort, :switch_url
  attr_reader :articles, :error
  attr_reader :search_options

  def initialize(params)
    @q = params[:q]
    order = params[:sort] || 'date'

    @search_options = {
      page: params[:page] || 1,
      field_weights: {
        "subject" => 10,
        "name" => 5,
        "email" => 5,
        "body" => 1
      }
    }
    if order == 'date'
      @search_options.merge!(order: "received_at desc")
      @sorting_by = "date"
      @switch_sort = "relevance"
      @switch_url = { action: "search", q: @q, sort: 'relevance' }
    else
      @sorting_by = "relevance"
      @switch_sort = "date"
      @switch_url = { action: "search", q: @q, sort: 'date' }
    end
  end

  def run(searcher=Article)
    begin
      @articles = searcher.search(@q, @search_options)
      @total_count = @articles.total_count
    rescue
      @articles = [].paginate
      @total_count = 0
      @error = "Sorry, search isn't working right now. " +
        "Please give <a href=\"mailto:owner@bcmets.org\">Pete</a> a kick."
    end
    self
  end

  def query
    @q
  end

  def articles_count
    @articles.count
  end

  def total_count
    @total_count
  end
end
