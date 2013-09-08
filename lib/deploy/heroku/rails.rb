require 'net/http'
require 'open3'

module Heroku::Deploy

  class RepoPushError < StandardError; end
  class MigrationError < StandardError; end

  class Rails

    attr_reader :app, :branch, :remote, :force

    def initialize(app, branch, remote, force)
      raise ArgumentError, 'args must not be empty' if app.empty? || branch.empty? || remote.empty?

      force_language = force ? 'with force push' : ''
      puts "Deploying branch #{branch} to app #{app} at remote #{remote} #{force_language}"
      @app = app
      @branch = branch
      @remote = remote
      @force = force
    end

    def deploy
      run_migrations_after_push = migrations_pending?
      push_changes
      run_migrations if run_migrations_after_push
      visit_site
      puts 'Deployment complete!'
    end

    private

    def force_flag
      '-f' if force
    end

    def migrations_pending?
      puts "Checking for pending migrations..."
      `git fetch #{remote}`
      schema_diff = `git diff #{remote}/master..#{branch} -- db/schema.rb`
      found_migrations_to_run = !schema_diff.empty?
      puts (found_migrations_to_run ? "found some!" : "found none.")
      found_migrations_to_run
    end

    def push_changes
      puts 'Pushing repo'
      puts '--------------'
      success = run_cmd("git push #{force_flag} #{remote} #{branch}:master", true)
      puts '--------------'
      raise(RepoPushError, "Failed to push repository") unless success
    end

    def run_cmd(cmd, output = true)
      exit_status = Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        out = stdout.gets
        err = stderr.gets
        puts out.chomp if output && out
        puts err.chomp if output && err
        wait_thr.value
      end
      success = (exit_status.to_i == 0)
    end

    def run_migrations
      puts 'Running migrations'
      success = run_cmd("heroku maintenance:on --app #{app}")
      success = success && run_cmd("heroku run rake db:migrate --app #{app}")
      success = success && run_cmd("heroku restart --app #{app}")
      success = success && run_cmd("heroku maintenance:off --app #{app}")
      raise MigrationError, 'Failed to run migrations' unless success
    end

    def visit_site
      puts 'Visiting site'
      Net::HTTP.get(URI.parse("http://#{app}.herokuapp.com"))
    end

  end
end