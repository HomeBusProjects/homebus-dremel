require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'dotenv'
require 'net/http'
require 'json'

class DremelHomeBusApp < HomeBusApp
  def initialize(options)
    @options = options

    Dotenv.load('.env')

    @server_url = options[:server] || ENV['DREMEL_SERVER_URL']

    @old_state = ''
    @old_file = ''
    @old_completion = ''

    super
  end

  def update_delay
    60
  end

  def setup!
  end

  def work!
    resp = Net::HTTP.post(URI(@server_url +  '/getHomeMessage'), '')

    dremel = JSON.parse resp.body

    if options[:verbose]
      pp dremel
    end

    state = dremel["PrinterStatus"]
    file = dremel["PrintingFileName"]
    completion = dremel["PrintingProgress"]

    if state != @old_state || file != @old_file || completion != @old_completion
      @old_state = state
      @old_file = file
      @old_completion = completion

      results = {
        id: @uuid,
        timestamp: Time.now.to_i,
        status: {
          state: state,
          total_prints: dremel["UsageCounter"]
        },
        job: {
          file: file,
          progress: completion,
          print_time_total: dremel["RemainTime"]*
          print_time_remaining: dremel["RemainTime"],
          filament_length: nil
        },
        temperatures: {
          tool0_actual: dremel["NozzleTemp"],
          tool0_target: dremel["NozzleTempTarget"],
          bed_actual: dremel["BedTemp"],
          bed_target: dremel["BedTempTarget"]
        }
      }

    if options[:verbose]
      pp results
    end

      @mqtt.publish "/homebus/device/#{@uuid}",
                    JSON.generate(results),
                    true
    end

    sleep update_delay
  end

  def manufacturer
    'HomeBus'
  end

  def model
    'Dremel publisher'
  end

  def friendly_name
    "Dremel server at #w{@server_url}"
  end

  def friendly_location
    'CTRLH'
  end

  def serial_number
    ''
  end

  def pin
    ''
  end

  def devices
    [
      { friendly_name: 'Dremel',
        friendly_location: @server_url,
        update_frequency: update_delay,
        index: 0,
        accuracy: 0,
        precision: 0,
        wo_topics: [ '/dremel' ],
        ro_topics: [ '/dremel/cmd' ],
        rw_topics: []
      }
    ]
  end
end
