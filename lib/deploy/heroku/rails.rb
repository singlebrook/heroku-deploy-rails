module Heroku::Deploy
  class Rails

    attr_reader :app, :branch, :remote

    def initialize(app, branch, remote)
      raise ArgumentError, 'args must not be empty' if app.empty? || branch.empty? || remote.empty?

      puts "Deploying branch #{branch} to app #{app} at remote #{remote}"
      @app = app
      @branch = branch
      @remote = remote
    end

    def deploy
      run_migrations = migrations_pending?
    end

    private

    def migrations_pending?
      puts "Checking for pending migrations..."
      #system("git fetch #{remote}")
      schema_diff = `git diff #{remote}/master..#{branch} -- db/schema.rb`
      found_migrations_to_run = !schema_diff.empty?
      puts (found_migrations_to_run ? "found some!" : "found none.")
      found_migrations_to_run
    end

    # git fetch $REMOTE
    # MIGRATIONS_PENDING=`git diff $REMOTE/master..$BRANCH -- db/schema.rb | wc -l`

    # echo "Pushing changes to $REMOTE..."
    # git push $REMOTE $BRANCH:master
    # PUSH_RETURN_VAL=$?

    # if [[ $PUSH_RETURN_VAL -eq 0 && $MIGRATIONS_PENDING -ne 0 ]]; then
    #   echo "Running pending migrations..."
    #   heroku maintenance:on --app $APP &&
    #   heroku run rake db:migrate --app $APP &&
    #   heroku restart --app $APP &&
    #   heroku maintenance:off --app $APP
    # else
    #   echo "No migrations pending."
    # fi

    # echo "Hitting site to spin it up..."
    # curl $URL &> /dev/null
    # echo "Production deployment complete!"

  end

end