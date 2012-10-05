require 'clamp'
require 'highline/import'

module KindleUtil
  class CLI < Clamp::Command

    ACTIONS = {
      "list" => "Display the selected items",
      "reset_lpr" => "Reset the last page read marker"
    }
    
    option ["-u", "--username"], "USERNAME", "Your amazon username/email"
    option ["-p", "--password"], "PASSWORD", "Your amazon password"
    option ["-a", "--action"], "ACTION", "The action to perform on all the selected\n" +
        "books, where action is one of:" +
        ACTIONS.collect {|k, v| "\n  #{k}: #{v}"}.join("") +
        "\n ", :default => "list" do |action|
      if ACTIONS[action].nil?
        msg = "Invalid action: '#{action}'"
        msg += "\nAction must be one of:"
        ACTIONS.each do |k, v|
          msg += "\n\t#{k}: #{v}"
        end
        raise ArgumentError, msg
      end
      action
    end
    option ["-c", "--[no-]cache"], :flag, "Cache (or not) the full list of purchased\nitems", :default => true
    option ["-d", "--debug"], :flag, "More verbose logging"
    option ["-v", "--version"], :flag, "Show version and exit" do
      puts "kindle_util v#{KindleUtil::VERSION}"
      exit
    end

    parameter "[FILTER] ...", "The filters to limit the items acted upon.\n" +
        "These should be given as 'field_name=value',\n" +
        "where value is treated as a regex.  Perform\n" +
        "the list action with --debug to see all\n" +
        "possible fields"
    
    def execute
      Logging.logger.root.appenders = Logging.appenders.stdout
      Logging.logger.root.level = debug? ? :debug : :info
      
      self.username ||= ask("Enter amazon username: ")
      self.password ||= ask("Enter amazon password: ") { |q| q.echo = false }
      
      crawler = AmazonCrawler.new(username, password, cache?)
      
      items = crawler.owned_items
      filter_list.each do |name, pattern|
        items = items.select {|item| item[name] =~ pattern }
      end
      
      case action
        when "list"
          items.each  do |item|
            puts debug? ? item.pretty_inspect : format_item(item)
          end
        when "reset_lpr"
          items.each do |item|
            logger.info "Resetting last page read for: #{format_item(item)}"
            crawler.reset_lpr(item)
          end
        else
          logger.error "Unknown action: #{action}"
      end
    end
    
    def filter_list=(filters)
      @filter_list = filters.collect {|f| f.split('=') }.collect {|k,v| [k, /#{v}/]}
    end
  
    def format_item(item)
      "[#{item['asin']}] #{item['title']} (#{item['author']})"
    end

  end

end
