# encoding: utf-8
require 'sinatra'
require "sinatra/reloader"

require 'diversity/registry'

class DiversityWeb < Sinatra::Application
  register Sinatra::Reloader

  enable :reloader
  enable :sessions

  configure :development do
  end

  get "/" do
    "Diversity Templating"
  end

  get "/registry" do
    registry = Diversity::Registry.new('./components', { cache: false })

    registry.installed_components.inspect
  end

  get "/layout" do
    registry = Diversity::Registry.new('./components', { cache: false })
    layout = registry.get_component('layout')
    layout.render({ options: { title: "Hay!" } })
  end
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
