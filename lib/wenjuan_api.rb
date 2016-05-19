require 'digest/md5'

# 问卷网文档：https://www.wenjuan.com/open/devmanual
class WenjuanApi
  include HTTParty

  attr_accessor :site, :config  

  def initialize
    return @config unless @config.nil?
    @config ||= loading_config!
    @site = @config.site
    @secret_key = @config.secret_key
    return @config
  end

  def get_md5(opts)
    if @site.blank?
      raise 'wenjuan api config site is none, Manybe you need init first'
    end

    opts[:site] = @site

    # 按参数字母顺序升序排列
    querys = opts.sort.to_h
    source = querys.values.join('') + @secret_key
    
    opts[:md5] =  Digest::MD5.hexdigest(source)
    return opts
  end

  def test_md5(opts)
    # res = custom_get('/openapi/testmd5/', opts)
    
    opts = get_md5(opts)
    res = HTTParty.get(@config.api_url + '/openapi/testmd5/', { query: opts })

    our_md5 = opts[:md5]
    if res.match(our_md5)
      return { result: true, md5: our_md5 }
    else
      return { result: false, message: res.body, our_md5: our_md5 }
    end
  end

  def get_login_url(user, nickname, email)
    # site  String  网站编号，由问卷网分配 必须
    # user  String  用户编号,接入方用户的唯一标识 必须
    # nickname  String  用户姓名或昵称, 将与唯一字段拼接， 作为问卷网登录名, 当昵称不存在时, 选用user拼接  可选
    # ctime DateTime  登录时间戳 "yyyy-mm-dd HH:MM"  必须
    # email String  用户邮件  必须
    # mobile  String  用户手机号码  可选
    opts = {
      user: user,
      nickname: nickname,
      email: email,
      ctime: Time.now.strftime('%Y-%m-%d %H:%M')
    }
    opts = get_md5(opts)

    login_url = @config.api_url + '/openapi/login/?' + opts.to_query
  end

  # site  String  网站编号，由问卷网分配 必须
  # user  String  用户编号  可选
  # type  String  项目类型(form或survey, 默认全部) 可选
  # page  String  查看第几页, 如果不带page参数，则返回所有项目列表 可选
  # num String  每页包含多少条目,默认20条  可选
  # status  String  问卷状态
  def projects(opts)
    custom_get('/openapi/proj_list/', opts )
  end

  def project_status(proj_id)
    opts = { proj_id: proj_id }
    custom_get('/openapi/proj_status/', opts )
  end

  def project_detail(proj_id)
    opts = { proj_id: proj_id }
    custom_get('/openapi/proj_detail/', opts)
  end

  # proj_id String  项目ID  必须
  # user  String  答题者编号 必须
  # repeat  String  同一答题者可重复答题  可选（1-可重复答题）
  # callback  String  回调地址,需要escape转义,计算md5时使用未转义的callback字符串 可选
  # redirect_uri  String  答题重定向地址,需要escape转义,计算md5时使用未转义的redirect_uri字符串  可选
  # test  String  如果test=1, 那么为答卷预览 可选
  def project_url(opts)
    opts = get_md5(opts)
    login_url = @config.api_url + "/s/#{opts[:proj_id]}/?" + opts.to_query
  end

  def project_chart_url(user, proj_id)
    opts = {
      user: user,
      proj_id: proj_id
    }

    opts = get_md5(opts)
    url = @config.api_url + "/openapi/basic_chart/?" + opts.to_query

    return url
  end

  # user  String  用户编号  必须
  # proj_id String  项目ID  必须
  # respondent  String  答题者编号 必须
  # datatype  String  返回数据类型(json或html, 默认html) 可选
  def user_project_latest_result(user, proj_id, respondent, datatype='html')
    opts = {
      user: user,
      proj_id: proj_id,
      respondent: respondent,
      datatype: datatype
    }

    custom_get('/openapi/detail', opts)
  end

  def create_project(user, type)
    opts = {
      user: user,
      type: type
    }

    custom_get('/openapi/create', opts)
  end

  def delete_project(user, proj_id)
    opts = {
      user: user,
      proj_id: proj_id
    }

    custom_get('/openapi/delete', opts)
  end

  def change_project_status(user, proj_id, tostatus)
    opts = {
      user: user,
      proj_id: proj_id,
      tostatus: tostatus
    }

    custom_get('/openapi/changestatus', opts)
  end

  def copy_project(fromuser, proj_id, touser)
    opts = {
      fromuser: fromuser,
      proj_id: proj_id,
      touser: touser
    }

    custom_get('/openapi/copy', opts)
  end

  def project_detail_list(user, proj_id, begin_seq=1, length=50)
    opts = {
      user: user,
      proj_id: proj_id,
      begin_seq: begin_seq,
      length: length
    }

    custom_get('/openapi/detail_list', opts)
  end

  private
  def custom_get(path, opts)
    opts = get_md5(opts)
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
end