#!/usr/bin/env ruby

require './options'
require './app'

octo_app_options = DremelHomebusAppOptions.new

octo = DremelHomebusApp.new octo_app_options.options
octo.run!
