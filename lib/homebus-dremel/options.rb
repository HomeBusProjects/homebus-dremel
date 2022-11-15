require 'homebus/options'

require 'homebus-dremel/version'

class HomebusDremel::Options < Homebus::Options
  def app_options(op)
    server_help = 'Server URL, like "https://ummon:5000" or "http://10.0.1.104"'

    op.separator 'homebus-dremel options:'
    op.on('-s', '--server-url SERVER-URL', server_help) { |value| options[:server] = value }
  end

  def server_help
  end

  def banner
    'HomeBus Dremel publisher'
  end

  def version
    HomebusDremel::VERSION
  end

  def name
    'homebus-dremel'
  end
end
