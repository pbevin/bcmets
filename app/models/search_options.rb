require 'will_paginate/array'

class SearchOptions
  extend Forwardable
  attr_reader :articles, :error, :query
  attr_reader :sort_order, :total_count

  delegate [:sorting_by, :switch_sort,
            :switch_url, :search_options] => :sort_order

  def initialize(params)
    @query = params[:q]
    @sort_order = SearchOptions.for(params)
  end

  def run(searcher = Article)
    _run(searcher)
    self
  end

  def _run(searcher)
    @articles = searcher.search(sort_order.q, search_options)
    @total_count = @articles.total_count
  rescue
    search_error
  end

  def search_error
    @articles = [].paginate
    @total_count = 0
    @error = "Sorry, search isn't working right now. " \
      "Please give <a href=\"mailto:owner@bcmets.org\">Pete</a> a kick."
  end

  def articles_count
    @articles.count
  end

  class SearchOptions
    attr_reader :params
    def initialize(params)
      @params = params
    end

    def q
      params[:q].gsub("@", "\\@")
    end

    def search_options
      {
        page: params[:page] || 1,
        field_weights: {
          "subject" => 10,
          "name" => 5,
          "email" => 5,
          "body" => 1
        }
      }
    end

    def self.for(params)
      case params[:sort]
      when 'date', nil
        ByDate.new(params)
      else
        ByRelevance.new(params)
      end
    end
  end

  class ByDate < SearchOptions
    def search_options
      super.merge(order: "received_at desc")
    end

    def sorting_by
      "date"
    end

    def switch_sort
      "relevance"
    end

    def switch_url
      { action: "search", q: q, sort: 'relevance' }
    end
  end

  class ByRelevance < SearchOptions
    def sorting_by
      "relevance"
    end

    def switch_sort
      "date"
    end

    def switch_url
      { action: "search", q: q, sort: 'date' }
    end
  end
end
