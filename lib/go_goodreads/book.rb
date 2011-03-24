module GoGoodreads
  class Book
    include GoGoodreads::Resource
    extend GoGoodreads::Request

    def self.show_by_isbn(isbn, options = {})
      params = { :isbn => isbn }
      params.merge!(options)

      request('/book/isbn', params) do |xml|
        book = initialize_with_node(xml)
        book.current_page = params[:page] || 1
        book
      end
    end

    attr :title, :isbn, :isbn13, :image_url,
         :small_image_url, :description,
         :asin, :url, :link,
         :num_pages, :authors, :reviews

    attr_accessor :current_page

    def self.initialize_with_node(xml)
      attrs = {}
      attrs[:title] = xml.at('title').text
      attrs[:isbn] = xml.at('isbn').text
      attrs[:isbn13] = xml.at('isbn13').text
      attrs[:image_url] = xml.at('image_url').text
      attrs[:small_image_url] = xml.at('small_image_url').text
      attrs[:description] = xml.at('description').text
      attrs[:num_pages] = xml.at('num_pages').text.to_i
      attrs[:asin] = xml.at('asin').text
      attrs[:url] = xml.at('url').text
      attrs[:link] = xml.at('link').text
      attrs.delete_if { |k,v| v.respond_to?(:empty?) && v.empty? }

      book = new(attrs)
      book.initialize_authors_with_nodeset(xml.search('authors > author'))
      book.initialize_reviews_with_nodeset(xml.search('reviews > review'))
      book
    end

    def initialize_authors_with_nodeset(xml)
      @authors = xml.map {|n| GoGoodreads::Author.initialize_with_node(n) }
    end

    def initialize_reviews_with_nodeset(xml)
      @reviews = xml.map {|n| GoGoodreads::Review.initialize_with_node(n) }
    end
  end
end
