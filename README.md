# wenjuan_api gem, not finished
1. add config file:
$ rails generate wenjuan_api:install

2. In rails console:

```ruby
include WenjuanApi

WenjuanApi.config

WenjuanApi.get_login_url('user', 'nickname', 'email')

```