require 'sinatra'
require 'json'

VALID_KEY = "123"

class ExceptionResource < Sinatra::Base
  set :methodoverride, true

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
    json_status 404, "No such route has been found"
  end

end
