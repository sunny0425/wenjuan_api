# wenjuan_api gem

https://www.wenjuan.com/open/devdocument_v3/?chapter=1_1

Wenjuan API Version 3

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

wenjuan_api.get_login_url('wj_user', 'wj_email')

```

## get report chart url

```ruby
wenjuan_api.project_chart_url('username', 'wj_short_id')
```

## get project answer list

```ruby
results = wenjuan.project_detail_list('username', 'wj_short_id')
# Be careful, here the username should be the wenjuan account username, not answerer's user name.
```ruby
