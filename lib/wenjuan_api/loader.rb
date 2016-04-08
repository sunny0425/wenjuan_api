module WenjuanApi
  module Loader
    def self.with(options)
      c = ApiLoader.config

      if c.site && c.secret_key
        # Wechat::Api.new(c.appid, c.secret, token_file, c.timeout, c.skip_verify_ssl, js_token_file)
      else
        puts <<-HELP
Need create ~/.wenjuan_api.yml with wenjuan site and secret_key
or running at rails root folder so wenjuan_api can read config/wenjuan_api.yml
HELP
        exit 1
      end
    end

    @config = nil

    def self.config
      return @config unless @config.nil?
      @config ||= loading_config!
      @config
    end

    private

    def self.loading_config!
      config ||= config_from_file
      # config[:timeout] ||= 20
      config.symbolize_keys!
      @config = OpenStruct.new(config)
    end

    def self.config_from_file
      if defined?(::Rails)
        config_file = Rails.root.join('config/wenjuan_api.yml')
        return YAML.load(ERB.new(File.read(config_file)).result)[Rails.env] if File.exist?(config_file)
      else
        rails_config_file = File.join(Dir.getwd, 'config/wenjuan_api.yml')
        home_config_file = File.join(Dir.home, '.wenjuan_api.yml')
        if File.exist?(rails_config_file)
          rails_env = ENV['RAILS_ENV'] || 'default'
          config = YAML.load(ERB.new(File.read(rails_config_file)).result)[rails_env]
          if config.present? && (config['site'] || config['secret_key'])
            puts "Using rails project config/wenjuan_api.yml #{rails_env} setting..."
            return config
          end
        end
        if File.exist?(home_config_file)
          return YAML.load ERB.new(File.read(home_config_file)).result
        end
      end
    end

    def self.class_exists?(class_name)
      return Module.const_get(class_name).present?
    rescue NameError
      return false
    end
  end
end
