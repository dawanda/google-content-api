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

  def self.urls(type, account_id, options = {})
    base_url = "https://content.googleapis.com/content/v1/#{account_id}"
    url = case type
          when "managed_accounts"
            "#{base_url}/managedaccounts"
          when "products"
            "#{base_url}/items/products/schema/batch?warnings="
          when "item", "product"
            raise "must supply language, country and item id" \
              if options[:language].nil? || options[:country].nil? || options[:item_id].nil?

            "#{base_url}/items/products/generic/online:#{options[:language].downcase}:#{options[:country].upcase}:#{options[:item_id]}?warnings"
          when "item_to_update"
             "#{base_url}/items/products/schema/online:#{options[:language].downcase}:#{options[:country].upcase}:#{options[:item_id]}"
          else
            raise "unknown zone"
          end

    options[:dry_run] ? url + "&dry-run=" : url
  end
end
