require 'yaml'
require 'google/api_client'

require 'google_content_api/version'
require 'google_content_api/client'

module GoogleContentApi
  def self.config(options = {})
    @@config ||= YAML.load( File.read(options[:config_file] || "config/google_content_api.yml") )
  end

  def self.urls
    @@urls ||= {
      "managed_accounts" => "https://content.googleapis.com/content/v1/#{config["user_id"]}/managedaccounts"
    }
  end
end
