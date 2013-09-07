require 'fileutils'
require 'deploy/heroku/command/base'
require 'deploy/heroku/command/deploy'

Heroku::Command.global_option :deploy, ''
