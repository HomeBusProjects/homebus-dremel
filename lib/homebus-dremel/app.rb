require 'homebus'

require 'dotenv'
require 'net/http'
require 'json'

class HomebusDremel::App < Homebus::App
  DDC_3DPRINTER = 'org.homebus.experimental.3dprinter'
  DDC_COMPLETED_JOB = 'org.homebus.experimental.3dprinter-completed-job'

  def initialize(options)
    @options = options

    super
  end

  def update_interval
    60
  end

  def setup!
    Dotenv.load('.env')

    @server_url = options[:server] || ENV['DREMEL_SERVER_URL']
    @https = @server_url.include? 'https'

    @old_state = ''
    @old_file = ''
    @old_completion = ''

    @device = Homebus::Device.new name: "Dremel ",
                                  manufacturer: 'Homebus',
                                  model: 'Dremel 3D printer publisher',
                                  serial_number: @server_url
  end

  def _get_dremel
    begin
      if @https
        uri = URI(@server_url + '/getHomeMessage')
        
        Net::HTTP.start(uri.host,
                        uri.port,
                        use_ssl: uri.scheme == 'https',
                        verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
          req = Net::HTTP::Post.new uri
          resp = http.request(req)
          JSON.parse resp.body
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

      @device.publish! DDC_3DPRINTER, results
    end

    sleep update_interval
  end

  def name
    'Homebus Dremel 3d printer publisher'
  end

  def publishes
    [ DDC_3DPRINTER, DDC_COMPLETED_JOB ]
  end

  def devices
    [ @device ]
  end
end
