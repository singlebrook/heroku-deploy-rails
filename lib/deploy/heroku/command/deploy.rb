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
    # The heroku-deploy plugin offers deployment of .war files.
    display 'heroku deploy:war' if `heroku plugins`.match(/^heroku-deploy$/)
  end

  # deploy:rails
  #
  # Deploy a Rails app with migrations, etc
  #
  # -b BRANCH, --branch BRANCH # Specify a branch/tag to deploy. Defaults to master.
  # -f, --force                # Force push repo.
  #
  def rails
    deployer = Heroku::Deploy::Rails.new(app, branch, git_remote_name, force?)
    begin
      deployer.deploy
    rescue StandardError => e
      raise Heroku::Command::CommandFailed, e.message
    end
  end

  private

  def branch
    options[:branch] || 'master'
  end

  def force?
    options[:force] || false
  end

  def git_remote_name
    git_remotes('.').each do |name, appname|
      return name if appname == app
    end
  end

end
