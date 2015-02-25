# ##
# # A MySQL connection:
# # DataMapper.setup(:default, 'mysql://user:password@localhost/the_database_name')
# #
# # # A Postgres connection:
# # DataMapper.setup(:default, 'postgres://user:password@localhost/the_database_name')
# #
# # # A Sqlite3 connection
# # DataMapper.setup(:default, "sqlite3://" + Padrino.root('db', "development.db"))


DataMapper.logger = logger
DataMapper::Property::String.length(255)

case Padrino.env
  when :development then DataMapper.setup(:default, "postgres://localhost/litographs_api_development")
  when :test        then DataMapper.setup(:default, "postgres://localhost/litographs_api_test")
  when :production  then DataMapper.setup(:default, {
      adapter: 'postgres',
      encoding: 'utf8',
      database: ENV['RDS_DB_NAME'],
      username: ENV['RDS_USERNAME'],
      password: ENV['RDS_PASSWORD'],
      host: ENV['RDS_HOSTNAME'],
      port: ENV['RDS_PORT'].to_i
    })
end
