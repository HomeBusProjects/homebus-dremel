#!/usr/bin/env ruby

require './options'
require './app'

octo_app_options = DremelHomeBusAppOptions.new

octo = DremelHomeBusApp.new octo_app_options.options
octo.run!
