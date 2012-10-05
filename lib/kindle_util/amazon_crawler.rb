require 'json'
require 'mechanize'

module KindleUtil
  class AmazonCrawler
    attr_reader :owned_items
    
    def initialize(user, pass, cache)
      @user = user
      @pass = pass
      @cache_file = File.expand_path("~/.kindle_util.json")
      
      @agent = Mechanize.new do |agent|
        agent.user_agent_alias = 'Mac Safari'
        agent.follow_meta_refresh = true
        agent.redirect_ok = true
      end
      
      @owned_items = JSON.parse(File.read(@cache_file)) rescue []
      if @owned_items.size == 0 || ! cache
        @owned_items = fetch_ownership
        File.write(@cache_file, @owned_items.to_json)
      end
    end
  
    def login
      @manage_kindle_page ||= begin
        logger.debug "Logging into amazon web ui"
        home_page = @agent.get("http://www.amazon.com")
        logger.debug "Got home page: #{home_page.title.strip}"
        signin_page = home_page.link_with(:text => "Manage Your Kindle").click
        logger.debug "Got sign in page: #{signin_page.title.strip}"
        form = signin_page.forms.first
        form.email = @user
        form['ap_signin_existing_radio'] = "1"
        form.password = @pass
        manage_page = form.submit
        logger.debug "Got manage page: #{manage_page.title.strip}"
        manage_page
      end
    end
  
    def unescape(data)
      case data
        when Array then data.collect {|d| unescape(d) }
        when Hash then Hash[data.collect {|k, v| [unescape(k), unescape(v)] }]
        when String then CGI.unescapeHTML(data)
        else data
      end
    end
    
    def fetch_ownership()
      login
      owned_items = []
      ownership_url = "https://www.amazon.com/gp/digital/fiona/manage/features/order-history/ajax/queryOwnership_refactored.html"
      
      offset = 0
      count = 100
      has_more = true
      while has_more do
        logger.debug "Fetching ownership data offset=#{offset}, count=#{count}"
        ownership_data = @agent.post(ownership_url, "contentType" => "all",
                                                    "randomizer" => rand(10000000000000),
                                                    "count" => count,
                                                    "offset" => offset)
        data = JSON.parse(ownership_data.body)
        items = data['data']['items']
        items = unescape(items)
        owned_items.concat(items)
        
        has_more = data['data']['hasMore'].to_i != 0
        offset += count
      end
      logger.debug "Got data for #{owned_items.size} books"
      return owned_items
    end
    
    def reset_lpr(item)
      login
      asin = item['asin']
      sid = @agent.cookies.find {|c| c.name == "session-id" }.value
      reset_lpr_url = "https://www.amazon.com/gp/digital/fiona/du/reset-lpr.html/ref=kinw_myk_lpr"
      logger.debug "Resetting last page read: asin=#{asin}, sid=#{sid}"
      response = @agent.post(reset_lpr_url, "asin" => asin, "sid" => sid)
      data = JSON.parse(response.body.gsub("'", '"'))
      logger.error "Failed to reset last page read for asin=#{asin}: #{data["error"]}" if data["error"]
      data['data'].to_i == 1
    end
  end

end
