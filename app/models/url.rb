class Url < ApplicationRecord

  def hello
    p "Hello"
  end


  def lookup_stats url

    reddit_api_url = "https://www.reddit.com/submit.json?url=" + url
    p reddit_api_url

    begin
      response = RestClient.get(reddit_api_url)
      result = JSON.parse(response)
      eng_data = result["data"]["children"]
      engagements = (0...eng_data.count).map { |n| eng_data[n]["data"]["ups"] + eng_data[n]["data"]["num_comments"] + 1 }.reduce(:+)
      engagement_data = (0...eng_data.count).map { |n| [eng_data[n]["data"]["name"], eng_data[n]["data"]["ups"], eng_data[n]["data"]["num_comments"]] }
      Rails.logger.info "engagement_data: #{engagement_data}"
      return engagements, engagement_data
    rescue =>e
      @error = e.message
    end


  end

end
