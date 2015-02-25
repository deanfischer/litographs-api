source 'https://rubygems.org'

# Server requirements
gem "passenger"

# Frameworks
gem 'grape'
gem 'grape-entity'
gem 'padrino', '0.12.4'

# Templating
gem 'rabl'

# Optional JSON codec (faster performance)
gem 'oj'

# Project requirements
gem 'foreman'
gem 'rake'

# Humanising
gem 'chronic'

# Component requirements
gem 'bcrypt'
gem 'erubis', '~> 2.7.0'
gem 'dm-validations'
gem 'dm-timestamps'
gem 'dm-migrations'
gem 'dm-constraints'
gem 'dm-aggregates'
gem 'dm-types'
gem 'dm-core'
gem 'dm-observer'
gem 'dm-postgres-adapter'
gem 'dm-postgres-types'

# Server extensions
gem 'rack-rewrite', '~> 1.2.1'
gem 'rack-jsonp-middleware'
gem 'rack-parser', :require => 'rack/parser'
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-ssl-enforcer'

group :test do
  # gem 'mocha'
  # gem 'rspec'
  # gem 'rack-test', :require => 'rack/test'
  gem 'airborne', :require => false
  gem 'pry'
end

group :development do
  # debugging
  gem 'pry'
end
