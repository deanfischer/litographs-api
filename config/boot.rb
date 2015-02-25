# Defines our constants
RACK_ENV = ENV['RACK_ENV'] ||= 'development'  unless defined?(RACK_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__) unless defined?(PADRINO_ROOT)

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default, RACK_ENV)

Padrino::Logger::Config[:test] = { log_level: :debug, stream: :to_file }
Padrino::Logger::Config[:development] = { log_level: :devel, stream: :stdout }
Padrino::Logger::Config[:production] = { log_level: :info,  stream: :to_file }

Padrino.before_load do
  Padrino.dependency_paths << Padrino.root('api/*.rb')
end

Padrino.after_load do
  DataMapper.finalize
end

Padrino.load!