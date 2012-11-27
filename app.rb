require 'sinatra'
require 'json'

class ExceptionResource < Sinatra::Base
  set :methodoverride, true

  get '/exceptions' do
    content_type :json

    test_data = [
      { "key" => "value" },
      { "key2" => "value2" }
    ]

    test_data.to_json
  end

end
