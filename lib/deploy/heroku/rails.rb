require 'net/http'
require 'pty'

module Heroku::Deploy

  class RepoPushError < StandardError; end
  class MigrationError < StandardError; end

  class Rails

    attr_reader :app, :branch, :remote, :force

    def initialize(app, branch, remote, force)
      [:app, :branch, :remote].each do |sym|
        raise ArgumentError, "#{sym} was not supplied" if eval(sym.to_s).empty?
      end

      force_language = force ? 'with force push' : ''
      status "Deploying branch #{branch} to app #{app} at remote #{remote} #{force_language}"
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
      status 'Deployment complete!'
    end

    private

    def force_flag
      '-f' if force
    end

    def migrations_pending?
      status "Checking for pending migrations..."
      `git fetch #{remote}`
      schema_diff = `git diff #{remote}/master..#{branch} -- db/schema.rb 2> /dev/null`
      if $?.to_i == 0
        found_migrations_to_run = !schema_diff.empty?
      else
        status('No remote master branch was found. Assuming this is the first push for this app.')
        found_migrations_to_run = true
      end
      status(found_migrations_to_run ? "found some!" : "found none.")
      found_migrations_to_run
    end

    def push_changes
      status 'Pushing repo'
      # We explicitly push to refs/heads/master so that we cannot inadvertantly
      # create a tag called 'master' if we're pushing a tag.
      success = run_cmd("git push #{force_flag} #{remote} #{branch}:refs/heads/master", true)
      raise(RepoPushError, "Failed to push repository") unless success
    end

    def run_cmd(cmd, output = false)
      puts "--- #{cmd}" if output

      # This madness runs system commands with:
      # 1. Streaming access to stdout, so we can see output from commands as
      #    they run.
      # 2. Access to the exit code of the process so we can tell if it succeeded.
      # It was largely cribbed from http://stackoverflow.com/a/7263243/234158
      begin
        PTY.spawn( cmd ) do |stdin, stdout, pid|
          begin
            stdin.each { |line| print "| #{line}" } if output
          rescue Errno::EIO
          end
          Process.wait(pid)
        end
        success = ($?.to_i == 0)

      rescue PTY::ChildExited
      end

      return success
    end

    def run_migrations
      status 'Running migrations'
      success = run_cmd("heroku maintenance:on --app #{app}", true)
      success = success && run_cmd("heroku run rake db:migrate --app #{app}", true)
      success = success && run_cmd("heroku restart --app #{app}", true)
      success = success && run_cmd("heroku maintenance:off --app #{app}", true)
      raise MigrationError, 'Failed to run migrations' unless success
    end

    def status(text)
      puts "*** #{text}"
    end

    def visit_site
      status 'Visiting site to spin it up'
      Net::HTTP.get(URI.parse("http://#{app}.herokuapp.com"))
    end

  end
end