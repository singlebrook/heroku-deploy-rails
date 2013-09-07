require "heroku/command/base"

# deploy apps to Heroku
#
class Heroku::Command::Deploy < Heroku::Command::Base

  # deploy
  #
  # list all known deployment strategies
  #
  def index
    deployers = methods(false).except(:index)

    display "Available deployment strategies:"
    deployers.each do |name|
      display name
    end
  end

  # deploy:rails
  #
  # deploy a Rails app with migrations, etc
  #
  def rails


  end

end
