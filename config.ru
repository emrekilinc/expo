require 'sinatra'
require 'rubygems'

root_dir = File.dirname(__FILE__)
require File.join(root_dir, 'app.rb')

run ExceptionResource
