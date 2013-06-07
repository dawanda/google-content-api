require 'yaml'
require 'nokogiri'
require 'google/api_client'

require 'google_content_api/version'
require 'google_content_api/authorization'
require 'google_content_api/sub_account'
require 'google_content_api/product'

module GoogleContentApi
  def self.config(options = {})
    @@config ||= YAML.load( File.read(options[:config_file] || "config/google_content_api.yml") )
  end

  def self.urls(type, account_id, dry_run = false)
    url = case type
      when "managed_accounts"
        "https://content.googleapis.com/content/v1/#{account_id}/managedaccounts"
      when "products"
        "https://content.googleapis.com/content/v1/#{account_id}/items/products/schema/batch?warnings"
      else
        raise "unknown zone"
      end

    dry_run ? url + "&dry-run" : url
  end
end
