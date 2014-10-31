# encoding: utf-8
require 'sinatra/base'
require 'json'

#require "sinatra/reloader"

require 'diversity'

class DiversityWeb < Sinatra::Base #Sinatra::Application
  #register Sinatra::Reloader

  #enable :reloader, :sessions, :dump_errors

  set :root, File.dirname(__FILE__)

  configure :development do
    enable :dump_errors
  end

  def initialize(app = nil)
    super

    @registry = Diversity::Registry::DiversityApi.new(
      { backend_url: "http://api.diversity.io:8181/" }
    )
    @local_registry = Diversity::Registry::Local.new({
      base_path: File.join(settings.root, 'components'),
    })
    @engine = Diversity::Engine.new({
                                      registry: @registry,
                                      debug_logger: $stdout,
                                    })
  end

  error 500 do |err|
    puts "500"
    puts (Time.now.strftime('%F %T ') <<
          "#{err.class} - #{err.message}\n")
    err.backtrace.each do |step|
      puts "\t#{step}\n"
    end
    response.headers['Content-Type'] = 'text/plain'
    halt 'Internal server error'
  end

  get "/" do
    "Hej"
  end

  get "*" do
    path = params[:splat]

    filename = File.join(settings.root, 'site', path)

    halt 404 unless File.exist?(filename)


    puts "File #{File.join(settings.root, path)} exists."

    context = { "language" => "en" }

    settings = JSON.parse(File.read(filename))

    # @todo Registries must really have a super-registry...
    component = @local_registry.get_component(settings['component'])

    unless component
      puts "No local component #{settings['component']}\n"
      component = @registry.get_component(settings['component'])
    end

    @engine.render(component, context, settings['settings'])
  end

  run! if app_file == $0
end

# Todo:
#
# * File structure
# * Setup CI
#
# Structure:
#
# public - Holding md or html?
# ...
