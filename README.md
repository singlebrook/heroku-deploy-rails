# Heroku Deploy Rails

<img src="https://d3s6mut3hikguw.cloudfront.net/github/singlebrook/heroku-deploy-rails.png">

Helps deploy Rails apps to Heroku, without forgetting important steps.

Currently, it does the following:

1. Push changes
2. If there are any migrations that need to run:
  * Put the app in maintenance mode
  * Run the migrations
  * Take the app out of maintenance mode
3. Visit the app to spin it up

This might seem like overkill, but we've pushed and forgotten to run migrations
one too many times!

## Installation

    $ heroku plugins:install git://github.com/singlebrook/heroku-deploy-rails.git

## Updating

    $ heroku plugins:update heroku-deploy-rails

## Usage

To list available deployment strategies:

    $ heroku deploy

To deploy a Rails app:

    $ heroku deploy:rails

To deploy a branch/tag other than master:

    $ heroku deploy:rails --branch branch_name

To choose an app to deploy to if you have multiple Heroku remotes, use the standard Heroku flags:

    $ heroku deploy:rails --app app_name
    or
    $ heroku deploy:rails --remote remote_name

To force push:

    $ heroku deploy:rails --force

For a full list of options:

    $ heroku deploy:rails --help
