# Seed add you the ability to populate your db.
# We provide you a basic shell for interaction with the end user.
# So try some code like below:
#
#   name = shell.ask("What's your name?")
#   shell.say name
#

require File.expand_path("../../config/boot.rb", __FILE__)
require 'logger'

LOG_PATH = Padrino.root('tmp', 'seed_log.txt')
SEED_DATA_BASEPATH = File.join(File.dirname(__FILE__), 'seeds/')

puts "Logging details to #{LOG_PATH}."
$seed_logger = Logger.new(LOG_PATH)


if ["y", "yes"].include?(shell.ask "Do you want to seed GENRES? (y/n)")
  seed 'genres' do |genre|
    begin
      new_genre = Genre.create(genre)
    rescue => e
      $seed_logger.error "Unexpected error: #{e.to_s}."
    end
  end
end


if ["y", "yes"].include?(shell.ask "Do you want to seed USERS? (y/n)")
  User.all.destroy
  seed 'users' do |user|
    begin
      new_user = User.create(user)
    rescue => e
      $seed_logger.error "Unexpected error: #{e.to_s}."
    end
  end
end