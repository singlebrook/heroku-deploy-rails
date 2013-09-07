require "heroku/command/base"

# deploy apps to Heroku
#
class Heroku::Command::Deploy < Heroku::Command::Base

  # deploy
  #
  # list all known deployment strategies
  #
  def index
    display "Available deployment strategies:"
    display 'heroku deploy:rails'
  end

  # deploy:rails
  #
  # deploy a Rails app with migrations, etc
  #
  def rails


  end

end
