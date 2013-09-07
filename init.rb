require "fileutils"
require "deploy/heroku/command/deploy"
require "deploy/heroku/command/base"

Heroku::Command.global_option :deploy, "--account ACCOUNT"
