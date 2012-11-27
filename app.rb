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

    field :project_code, type: String
    field :name, type: String
    field :description, type: String
  end

  class Exception
    include Mongoid::Document

    field :project_code, type: String
    field :friendly, type: String
    field :thrown_date, type: DateTime
    field :message, type: String
    field :class_name, type: String
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

    # Returns a JSON object with status
    # code and data in it
    def json_result code, result
      {
        :status => code,
        :data => result
      }.to_json
    end

    # Helper method for setting the 
    # sent form attributes
    def accept_params params, *fields
      ps = { }
      fields.each do |name|
        ps[name] = params[name] if params[name]
      end

      ps
    end
  end

  # Check the key before every route
  before do
    error 401 unless valid_key?(params[:token])
  end

  ## GET : '/' 
  get '/' do
    json_status 404, "No such route has been found."
  end

  ## Return all exceptions
  ## GET : '/exceptions?token=123'
  get '/exceptions' do
    content_type :json

    exceptions = Exception.all.desc(:thrown_date)
    json_result 200, exceptions
  end

  ## Return all the exceptions limited
  ## GET : '/exceptions/{limit}?token=123'
  get '/exceptions/:limit' do
    content_type :json

    exceptions = Exception.all.desc(:thrown_date)
                          .limit(params[:limit])

    json_result 200, exceptions
  end

  ## Return all exceptions by project
  ## GET : '/exceptions/{project-code}?token=123'
  get '/exceptions/:pcode' do
    content_type :json

    exceptions = Exception.where(project_code: params[:pcode])
                          .desc(:thrown_date)

    json_result 200, exceptions
  end

  ## Return all exceptions by project
  ## GET : '/exceptions/{project-code}/{limit}?token=123'
  get '/exceptions/:pcode/:limit' do
    content_type :json

    exceptions = Exception.where(project_code: params[:pcode])
                          .desc(:thrown_date)
                          .limit(params[:limit])

    json_result 200, exceptions
  end

  ## Post a new exception
  ## POST : '/exception/new'
  post '/exception/new' do
    content_type :json

    create_params = accept_params(params, :project_code, :friendly, :thrown_date, :message, :class_name, :backtrace)
    exception = Exception.new(create_params)

    if exception.save
      # If successful then return the exception
      # with the status of 200
      json_result 200, exception
    else
      # If not successful then return HTTP 400
      # with the json of the errors
      json_result 400, exception.errors.to_hash
    end
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
