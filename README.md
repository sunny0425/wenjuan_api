# wenjuan_api gem

```shell
gem install wenjuan_api
```

## add config file:

```shell
$ rails generate wenjuan_api:install
```

## In rails console:

```ruby
wenjuan_api = WenjuanApi.new

wenjuan_api.get_login_url('user', 'nickname', 'email')

```

## test md5

```ruby
wenjuan_api.test_md5(user: 'name', nickname: 'name', email: 'name@company.com', ctime: Time.now.strftime('%Y-%m-%d %H:%M'))
```

## get report chart url

```ruby
wenjuan_api.project_chart_url('username', 'proj_id')
```
