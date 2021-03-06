require 'mongoid'
require 'json'
require 'sinatra/reloader' if development?

## TODO : Develop a valid token algorithm
VALID_KEY = "KH6R643B72V085P2TRK0"

class ExceptionResource < Sinatra::Base
  set :methodoverride, true

  # Loading mongodb with yaml configuration
  Mongoid.load!("mongoid.yml", :development)

  # Models 
  class Project
    include Mongoid::Document

    field :project_code, type: String
    field :name, type: String
    field :description, type: String
    field :logo, type: String
    field :external_order, type: Integer
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

  ## POST : '/projects'
  post '/projects' do
    content_type :json

    exceptions = Project.all
    json_result 200, exceptions
  end

  ## Post a new project
  ## POST : '/projects/new'
  post '/projects/new' do
    content_type :json

    create_params = accept_params(params, :project_code, :name, :description, :logo, :external_order)
    project = Project.new(create_params)

    if project.save
      json_result 200, project
    else
      json_result 400, project.errors.to_hash
    end
  end

  ## Return a project detail
  ## POST : '/projects/detail'
  post '/projects/detail' do
    content_type :json

    project = Project.find(params[:id])

    json_result 200, project
  end

  ## Return all exceptions
  ## POST : '/exceptions?token=123'
  post '/exceptions' do
    content_type :json

    exceptions = Exception.all.desc(:thrown_date)
    json_result 200, exceptions
  end

  ## Return a exception detail
  ## POST : '/exceptions/detail'
  post '/exceptions/detail' do
    content_type :json

    exception = Exception.find(params[:id])

    json_result 200, exception
  end

  ## Return all the exceptions limited
  ## POST : '/exceptions/{limit}?token=123'
  post '/exceptions/:limit' do
    content_type :json

    exceptions = Exception.all.desc(:thrown_date)
                          .limit(params[:limit])

    json_result 200, exceptions
  end

  ## Return all exceptions by project
  ## POST : '/exceptions/{project-code}?token=123'
  post '/exceptions/:pcode' do
    content_type :json

    exceptions = Exception.where(project_code: params[:pcode])
                          .desc(:thrown_date)

    json_result 200, exceptions
  end

  ## Return all exceptions by project
  ## POST : '/exceptions/{project-code}/{limit}?token=123'
  post '/exceptions/:pcode/:limit' do
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
      json_result 200, exception
    else
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
