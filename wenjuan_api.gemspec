Gem::Specification.new do |s|
  s.name        = 'wenjuan_api'
  s.version     = '0.0.1'
  s.date        = '2016-04-07'
  s.summary     = 'Wenjuan Api'
  s.description = 'Wenjuan Api integration gem'
  s.authors     = ['luoping']
  s.email       = 'luoping0425@gmail.com'
  s.files       = ['lib/wenjuan_api.rb']
  s.files = Dir['Gemfile', 'README.md', 'lib/**/*']
  # s.homepage    =
  #   'http://rubygems.org/gems/wenjuan_api'
  s.license       = 'MIT'
  s.add_dependency 'httparty'
end