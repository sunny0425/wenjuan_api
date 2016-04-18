# wenjuan_api gem, not finished

1. add config file:

$ rails generate wenjuan_api:install

2. In rails console:

```ruby
include WenjuanApi

WenjuanApi.config

WenjuanApi.get_login_url('user', 'nickname', 'email')

```

3. test md5

```ruby
WenjuanApi.test_md5(user: 'name', nickname: 'name', email: 'name@company.com', ctime: Time.now.strftime('%Y-%m-%d %H:%M'))
```
