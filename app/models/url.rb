class Url < ApplicationRecord


  def self.resolve url
    original_url = url
    get_response_cookie = nil
    static_headers = {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36", "Accept" => "*/*", "Accept-Encoding" => "plain"}
    loop_counter = 0
    loop do
      begin
        Rails.logger.info "Url.resolve: loop_counter #{loop_counter} retrieving #{url}"
        # TODO This timeout 1 may be too aggressive
        response = get(url, timeout: 1, verify: false, follow_redirects: false,
          headers: (get_response_cookie ? static_headers.merge('Set-Cookie' => get_response_cookie.to_cookie_string) : static_headers))
        loop_counter += 1
        Rails.logger.info "Url.resolve: " + response.code.try(:to_s).to_s
        Rails.logger.info "Url.resolve: " + response.headers.try(:inspect).to_s
        Rails.logger.info "Url.resolve: " + ""
        current_url = url
        if response.headers['location']
          # Do a merge with the previous URL in case the new location is relative
          url = URI.parse(url).merge(response.headers['location']).to_s
        end
        get_response_cookie = parse_cookie(response)
        if loop_counter >= 20
          return [original_url, 200, response.message + " [SM: " + response.code.to_s + " but loop_counter exhausted]", get_response_cookie]
        end
        if response.code==301 || response.code==302
          redo
        elsif response.code==303 && current_url != url
          redo
        elsif response.code==303 && current_url == url
          return [url, 200, response.message + " [SM: 303 but same URL]", get_response_cookie]
        else
          return [url, response.code, response.message, get_response_cookie]
        end
      rescue Exception => e
        return [url, nil, e.message]
      end
    end # loop
  end


  def get_url_metadata

    # resolve_url, resolve_code, resolve_message, cookies = Url.resolve(url)
    # self.url = resolve_url
    # static_headers = {"Accept-Encoding" => "plain", "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36", "Accept" => "*/*"}
    # header_to_send = (cookies ? static_headers.merge('Set-Cookie' => cookies.to_cookie_string) : static_headers)
    encoded_url = URI.encode(self.url)
    response = HTTParty.get(encoded_url, timeout: 5, verify: false)
    h = Nokogiri::HTML(response.body)
    published_at = extract_published_at(h, self.url)
  end

  def extract_published_at(h, url)

    Rails.logger.info "Trying to find pubdate for: #{url} "

    p = h.css('meta[property="article:published_time"]')
    p = h.css('meta[property="article:published"]') if p.empty?
    p = h.css('meta[name="date"]') if p.empty?
    unless p.empty?
      return attempt_parse(p.attr('content').to_s)
    end

    p = h.css('[itemprop="published"]')
    p = h.css('[itemprop="datePublished"]') if p.empty?
    p = h.css('[pubdate]') if p.empty?
    unless p.empty?
      p = p.first
      datetime = p.attr('datetime')
      datetime = p.attr('content') if datetime.nil?
      datetime = p.text if datetime.nil?
      return attempt_parse(datetime)
    end

    p = h.css('script[type="application/ld+json"]')
    unless p.empty?
      p.each do |chunk|
        lds = JSON.parse(chunk.text) rescue {}
        lds = [lds] unless lds.is_a?(Array)
        lds.each do |ld|
          if ld['@type']=='NewsArticle' || ld['@type']=='Article'
            datetime = ld['datePublished']
            return attempt_parse(datetime)
          end
        end
      end
    end

    p = h.css('[class="articledate"]')
    p = h.css('[class="post__date"]') if p.empty?  # example -- thinkprogress.org
    unless p.empty?
      datetime = p.first.attr('title')
      datetime = p.attr('datetime') if datetime.nil?
      return attempt_parse(datetime)
    end

    # Try to get it from the URL, e.g. look for yyyy/mm/dd
    m = url.match(%r{(\d{4}/\d{2}/\d{2})})
    if m
      return attempt_parse(m[0])
    end

  end

  def attempt_parse(datetime)
    begin
      return Time.parse(datetime)
    rescue Exception => e
      return Chronic.parse(datetime, context: :past)
    end
  end


  def lookup_reddit
    reddit_api_url = "https://www.reddit.com/search.json?q=" + self.url
    begin
      response = RestClient.get(reddit_api_url)
      result = JSON.parse(response)
      result = result[0] if result.is_a?(Array) == true 
      Rails.logger.info result
      api_data = result["data"]["children"]      
      reddit = (0...api_data.count).map { |n| api_data[n]["data"]["ups"] + api_data[n]["data"]["num_comments"] + 1 }.reduce(:+) rescue 0
      reddit_data = (0...api_data.count).map { |n| [api_data[n]["data"]["name"], api_data[n]["data"]["ups"], api_data[n]["data"]["downs"], api_data[n]["data"]["num_comments"]] } rescue ''
      return reddit, reddit_data
    rescue =>e
      @error = e.message
    end
  end



end
