require 'sinatra'
require 'json'

class ExceptionResource < Sinatra::Base
  set :methodoverride, true

  helpers do
    def valid_key? key
      key == "123"
    end
  end

  get '/exceptions' do
    p params[:key]
    error 401 unless valid_key?(params[:key])
    content_type :json

    test_data = [
      { "key" => "value" },
      { "key2" => "value2" }
    ]

    test_data.to_json
  end

end
