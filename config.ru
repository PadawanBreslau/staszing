require 'dashing'
require 'yaml'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

if File.exists?('config/application.yml')
  YAML.load_file('config/application.yml').each do |key, value|
    ENV[key] = value unless ENV.key?(key)
  end
end

run Sinatra::Application
