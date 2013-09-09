require 'sinatra'
require 'yaml'
require 'sqlite3'
require 'mysql2'
require 'sequel'
use Rack::Logger

configure do
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

get '/' do
  redirect '/user'
end

get '/user/?' do
  @users = Users.all
  erb :index
end

post '/user/?' do
  Users.create(
    :name => params[:name],
    :age => params[:age]
  )
  redirect '/user'
end

Sequel::Model.plugin(:schema)

data = File.read("#{settings.root}/config/database.yml")
params = YAML.load(data)
Sequel.connect(params[settings.environment.to_s])

class Users < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      column :name, String
      column :age, Integer
    end
    create_table
  end
end
