require 'heroku/command/base'

# deploy apps to Heroku
#
class Heroku::Command::Deploy < Heroku::Command::Base

  # deploy
  #
  # list all known deployment strategies
  #
  def index
    display 'Available deployment strategies:'
    display 'heroku deploy:rails'
  end

  # deploy:rails
  #
  # deploy a Rails app with migrations, etc
  #
  # -b BRANCH, --branch BRANCH # Specify a branch/tag to deploy. Defaults to master.
  #
  def rails
    deployer = Heroku::Deploy::Rails.new(app, branch, git_remote_name)
    deployer.deploy
  end

  private

  def branch
    options[:branch] || 'master'
  end

  def git_remote_name
    git_remotes('.').each do |name, appname|
      return name if appname == app
    end
  end

end
