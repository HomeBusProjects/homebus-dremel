require 'homebus'
require 'homebus_app'
require 'mqtt'
require 'dotenv'
require 'net/http'
require 'json'

class DremelHomeBusApp < HomeBusApp
  DDC_3DPRINTER = 'org.homebus.experimental.3dprinter'
  DDC_COMPLETED_JOB = 'org.homebus.experimental.3dprinter-completed-job'

  def initialize(options)
    @options = options

    Dotenv.load('.env')

    @server_url = options[:server] || ENV['DREMEL_SERVER_URL']
    @https = @server_url.include? 'https'

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

  def _get_dremel
    begin
      if @https
        uri = URI(@server_url)

        req = Net::HTTP::Post.new('/getHomeMessage')
        resp = Net::HTTP.start(uri.host,
                               uri.port,
                               use_ssl: true,
                               verify_mode: OpenSSL::SSL::VERIFY_NONE) do |https|
          https.request(req)
        end
      else
        resp = Net::HTTP.post(URI(@server_url +  '/getHomeMessage'), '')
        JSON.parse resp.body
      end
    rescue
      nil
    end
  end

  def work!
    dremel = _get_dremel

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
        timestamp: Time.now.to_i
      }

      results[DDC_3DPRINTER] = {
        status: {
          state: state,
          total_prints: dremel["UsageCounter"]
        },
        job: {
          file: file,
          progress: completion,
          print_time_total: dremel["RemainTime"],
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

      publish! DDC_3DPRINTER, results
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
    @server_url
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
        wo_topics: [ DDC_3DPRINTER ],
        ro_topics: [ ],
        rw_topics: []
      }
    ]
  end
end
