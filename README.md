# wenjuan_api gem, not finished

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
