require 'digest/md5'

# 问卷网文档：https://www.wenjuan.com/open/devdocument_v3/?chapter=1_1
class WenjuanApi
  include HTTParty

  attr_accessor :wj_appkey, :config  

  def initialize
    return @config unless @config.nil?
    @config ||= loading_config!
    @wj_appkey = @config.wj_appkey
    @secret_key = @config.secret_key
    return @config
  end

  def get_signature(opts, with_signature=true)
    if @wj_appkey.blank?
      raise 'wenjuan api config wj_appkey is none, Manybe you need init first'
    end

    opts[:wj_appkey] = @wj_appkey
    opts[:wj_timestamp] = Time.now.to_i.to_s if with_signature

    # 按参数字母顺序升序排列
    querys = opts.sort.to_h
    source = querys.values.join('') + @secret_key
    
    opts[:wj_signature] =  Digest::MD5.hexdigest(source)
    return opts
  end

  def get_login_url(wj_user, wj_email)
    opts = {
      wj_user: wj_user,
      wj_email: wj_email
    }
    opts = get_signature(opts)

    login_url = @config.api_url + '/openapi/v3/login/?' + opts.to_query
  end

  def projects(opts)
    custom_get('/openapi/v3/get_proj_list/', opts )
  end

  def project_status(wj_short_id)
    opts = { 
      wj_short_id: wj_short_id
    }
    custom_get('/openapi/v3/get_proj_status/', opts )
  end

  def project_detail(wj_short_id)
    opts = { 
      wj_short_id: wj_short_id
    }
    custom_get('/openapi/v3/get_proj_detail/', opts)
  end

  def project_url(opts)
    opts = get_signature(opts, false)

    _url = @config.api_url + "/s/#{opts[:wj_short_id]}/?" + URI.unescape(opts.to_query)
  end

  def project_chart_url(wj_user, wj_short_id)
    opts = {
      wj_user: wj_user,
      wj_short_id: wj_short_id
    }

    opts = get_signature(opts)
    url = @config.api_url + "/openapi/v3/get_basic_chart/?" + opts.to_query

    return url
  end

  def user_project_latest_result(wj_user, wj_short_id, wj_respondent, wj_datatype='html')
    opts = {
      wj_user: wj_user,
      wj_short_id: wj_short_id,
      wj_respondent: wj_respondent,
      wj_datatype: wj_datatype
    }

    custom_get('/openapi/v3/get_rspd_detail/', opts)
  end

  def create_project(wj_user, wj_ptype, wj_callback)
    opts = {
      wj_user: wj_user,
      wj_ptype: wj_ptype,
      wj_callback: wj_callback
    }

    custom_get('/openapi/v3/create_proj/', opts)
  end

  def change_project_status(wj_user, wj_short_id, wj_tostatus)
    opts = {
      wj_user: wj_user,
      wj_short_id: wj_short_id,
      wj_tostatus: wj_tostatus
    }

    custom_get('/openapi/v3/change_proj_status/', opts)
  end

  def copy_project(wj_from_user, wj_short_id, wj_to_user, wj_title= nil)
    opts = {
      wj_from_user: wj_from_user,
      wj_short_id: wj_short_id,
      wj_to_user: wj_to_user
    }
    
    opts[:wj_title] = wj_title if wj_title.present?

    custom_get('/openapi/v3/copy_proj/', opts)
  end

  def project_detail_list(wj_user, wj_short_id, more_opts={})
    opts = {
      wj_user: wj_user,
      wj_short_id: wj_short_id,
    }.merge(more_opts)

    custom_get('/openapi/v3/get_rspd_detail_list/', opts)
  end

  private
  def custom_get(path, opts)
    opts = get_signature(opts)
    res = HTTParty.get(@config.api_url + path, { query: opts })
  end

  def loading_config!
    config ||= config_from_file
    # @config.timeout ||= 20
    config.symbolize_keys!
    config = OpenStruct.new(config)
  end

  def config_from_file
    if defined?(::Rails)
      config_file = Rails.root.join('config/wenjuan_api.yml')
      return YAML.load(ERB.new(File.read(config_file)).result)[Rails.env] if File.exist?(config_file)
    else
      rails_config_file = File.join(Dir.getwd, 'config/wenjuan_api.yml')
      home_config_file = File.join(Dir.home, '.wenjuan_api.yml')
      if File.exist?(rails_config_file)
        rails_env = ENV['RAILS_ENV'] || 'default'
        config = YAML.load(ERB.new(File.read(rails_config_file)).result)[rails_env]
        if config.present? && (config['wj_appkey'] || config['secret_key'])
          puts "Using rails project config/wenjuan_api.yml #{rails_env} setting..."
          return config
        end
      end
      if File.exist?(home_config_file)
        return YAML.load ERB.new(File.read(home_config_file)).result
      end
    end
  end
end