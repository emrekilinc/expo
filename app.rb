require 'sinatra'
require 'mongoid'
require 'json'
require 'sinatra/reloader' if development?

VALID_KEY = "123"

class ExceptionResource < Sinatra::Base
  set :methodoverride, true

  # Loading mongodb with yaml configuration
  Mongoid.load!("mongoid.yml")

  # Models 
  class Project
    include Mongoid::Document

    field :project_code, type: Integer
    field :name, type: String
    field :description, type: String
  end

  class Exception
    include Mongoid::Document

    field :project_code, type: Integer
    field :friendly, type: String
    field :thrown_date, type: DateTime
    field :message, type: String
    field :class, type: String
    field :backtrace, type: String
  end

  helpers do
    # Checks the query string or
    # post params for valid key
    def valid_key? key
      key == VALID_KEY
    end

    # Returns a JSON object with status
    # code and explanation in it
    def json_status code, reason
      {
        :status => code,
        :reason => reason
      }.to_json
    end
  end

  # Check the key before every route
  before do
    error 401 unless valid_key?(params[:key])
  end

  ## GET : '/' 
  get '/' do
    json_status 404, "No such route has been found."
  end

  get '*' do
    status 404
  end

  post '*' do
    status 404
  end

  put '*' do
    status 404
  end

  delete '*' do
    status 404
  end

  not_found do
    json_status 404, "No such route has been found."
  end

  error do
    json_status 500, "Internal Server Error : #{env['sinatra.error'].message}"
  end

end
