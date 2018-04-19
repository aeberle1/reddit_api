class Url < ApplicationRecord

  def hello
    p "Hello"
  end


  def lookup_stats url

    reddit_api_url = "https://www.reddit.com/submit.json?url=" + url

    begin
      response = Net::HTTP.get(URI.parse(reddit_api_url))
      result = JSON.parse(response)
      resp = result["data"]["children"]
      @engagements = (0...resp.count).map { |n| resp[n]["data"]["ups"] + resp[n]["data"]["num_comments"] + 1 }.reduce(:+)
    rescue =>e
      @error = e.message
    end


  end

end