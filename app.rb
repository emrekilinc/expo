require 'sinatra'
require 'mongoid'
require 'json'
require 'sinatra/reloader' if development?

VALID_KEY = "123"

class ExceptionResource < Sinatra::Base
  set :methodoverride, true

  # Loading mongodb with waml configuration
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

end
