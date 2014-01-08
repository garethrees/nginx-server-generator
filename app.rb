require 'sinatra'

get '/' do
  content_type 'text/plain'

  if params.empty?
    render_help
  else
    NginxServer.new(params).render
  end
end

helpers do
  def render_help
    help = <<-END.gsub(/^ {6}/, '')
      Accepted Query Parameters
      -------------------------

      * app_name:     The name of the application
      * app_hostname: The FQDN of the application
      * app_port:     Port of the application service (default: 3000)

      Example
      -------

      $ curl -i "http://nginx-server-generator.herokuapp.com/?app_name=example-app&app_url=example.com"

      Source
      ------

      https://github.com/garethrees/nginx-server-generator
    END
  end
end

class NginxServer < ERB

  def self.template
    @template or './server.conf.erb'
  end

  def self.template=(template)
    @template = template
  end

  attr_accessor :app_name,
                :app_port,
                :app_url,
                :template

  def initialize(args)
    self.template = args.fetch(:template, self.class.template)
    self.app_name = slugify(args[:app_name])
    self.app_url  = args[:app_url]
    self.app_port = args.fetch('app_port', 3000)
    super(File.read(template))
  end

  def render
    result(binding)
  end

  def filename
    "#{ app_name }.conf"
  end

  private

  def slugify(name)
    name.downcase.gsub(/[^a-z1-9]+/, '-').chomp('-')
  end

  def generate_filename
    template.split('/').last.chomp('.erb')
  end

end
