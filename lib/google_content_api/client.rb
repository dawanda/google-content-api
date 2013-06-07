module GoogleContentApi

  class Client
    class << self
      def get_all_sub_accounts
        token            = fetch_token
        sub_accounts_url = GoogleContentApi.urls("managed_accounts", user_id)
        Faraday.headers  = {
          "Content-Type"  => "application/atom+xml",
          "Authorization" => "AuthSub token=#{token}"
        }

        response = Faraday.get sub_accounts_url

        if response.status == 200
          response
        else
          raise "request unsuccessful - received status #{response.status}"
        end
      end

      def create_sub_account(title, adult_content = false, attributes = {})
        token            = fetch_token
        sub_accounts_url = GoogleContentApi.urls("managed_accounts", user_id)
        xml              = create_sub_account_xml(title, adult_content, attributes)
        Faraday.headers  = {
          "Content-Type"   => "application/atom+xml",
          "Content-Length" => xml.length.to_s,
          "Authorization"  => "AuthSub token=#{token}"
        }

        response = Faraday.post sub_accounts_url, xml

        if response.status == 201
          response
        else
          raise "Unable to create sub account - received status #{response.status}. body: #{response.body}"
        end
      end

      def delete_sub_account(id)
        token            = fetch_token
        sub_account_url = GoogleContentApi.urls("managed_accounts", user_id) + "/#{id}"
        Faraday.headers  = { "Authorization"  => "AuthSub token=#{token}" }
        response = Faraday.delete sub_account_url

        if response.status == 200
          response
        else
          raise "Unable to create sub account - received status #{response.status}. body: #{response.body}"
        end
      end

      def create_products(sub_account_id, products)
        token            = fetch_token
        products_url     = GoogleContentApi.urls("products", sub_account_id)
        xml              = create_product_items_batch_xml(products)
        Faraday.headers  = {
          "Content-Type"   => "application/atom+xml",
          "Authorization"  => "AuthSub token=#{token}"
        }

        response = Faraday.post products_url, xml

        if response.status == 200
          response
        else
          raise "Unable to batch insert products - received status #{response.status}. body: #{response.body}"
        end
      end
      alias_method :create_items, :create_products

      private
        def user_id
          GoogleContentApi.config["user_id"]
        end

        def fetch_token
          client = Google::APIClient.new(
            :application_name    => GoogleContentApi.config["application_name"],
            :application_version => GoogleContentApi.config["application_version"]
          )

          client.authorization.client_id     = GoogleContentApi.config["client_id"]
          client.authorization.client_secret = GoogleContentApi.config["client_secret"]
          client.authorization.redirect_uri  = GoogleContentApi.config["redirect_uri"]
          client.authorization.refresh_token = GoogleContentApi.config["refresh_token"]
          client.authorization.scope         = GoogleContentApi.config["content_api_scope"]

          # but we have the refresh token, so we just:
          client.authorization.fetch_access_token!

          # if we need to refresh:
          # client.authorization.update_token!

          client.authorization.access_token
        end

        def create_product_items_batch_xml(items)
          mandatory_values = [:id, :title, :description, :link, :image, :content_language, :target_country, :channel]
          # 120.days.from_now.strftime("%Y-%m-%d")

          Nokogiri::XML::Builder.new do |xml|
            xml.feed('xmlns' => 'http://www.w3.org/2005/Atom', 'xmlns:batch' => 'http://schemas.google.com/gdata/batch') do
              items.each do |attributes|
                xml.entry('xmlns' => 'http://www.w3.org/2005/Atom', 'xmlns:sc' => 'http://schemas.google.com/structuredcontent/2009', 'xmlns:scp' => 'http://schemas.google.com/structuredcontent/2009/products', 'xmlns:app' => 'http://www.w3.org/2007/app') do
                  xml['batch'].operation_(:type => 'INSERT')
                  xml['sc'].id_ attributes[:id]
                  xml.title_ attributes[:title]
                  xml.content_ attributes[:description], :type => 'text'
                  xml.link_(:rel => 'alternate', :type => 'text/html', :href => attributes[:link])
                  xml['sc'].image_link_ attributes[:image]
                  xml['sc'].content_language_ attributes[:content_language]
                  xml['sc'].target_country_   attributes[:target_country]
                  xml['sc'].expiration_date_  attributes[:expiration_date] if attributes[:expiration_date]
                  xml['sc'].adult_ attributes[:adult] if attributes[:adult]
                  xml['scp'].availability_ "in stock"
                  xml['scp'].condition_(attributes[:condition] != 9 ? "new" : "used")
                  xml['scp'].price_ attributes[:price], :unit => attributes[:currency]

                  # optional values
                  if attributes[:additional_images]
                    attributes[:additional_images].each { |image_link| xml['sc'].additional_image_link_ }
                  end
                  if attributes[:product_type]
                    xml['scp'].product_type_ attributes[:product_type]
                  end
                  if attributes[:google_product_category]
                    xml['scp'].google_product_category_ attributes[:google_product_category]
                  end
                  if attributes[:brand]
                    xml['scp'].brand_ attributes[:brand]
                  end
                  if attributes[:mpn]
                    xml['scp'].mpn_ attributes[:mpn]
                  end

                end
              end
            end
          end.to_xml
        end

        def create_sub_account_xml(title, adult_content = false, attributes = {})
          adult_content = !adult_content ? "no" : "yes"
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.entry('xmlns' => 'http://www.w3.org/2005/Atom', 'xmlns:sc' => 'http://schemas.google.com/structuredcontent/2009') do
              xml.title_ title
              xml['sc'].adult_content adult_content
              xml.content_ attributes[:description]                     if attributes[:description]
              xml.link_(:rel => 'alternate', :type => 'text/html', :href => attributes[:link]) if attributes[:link]
              xml['sc'].internal_id_ attributes[:internal_id]           if attributes[:internal_id]
              xml['sc'].reviews_url_ attributes[:reviews_url]           if attributes[:reviews_url]
              xml['sc'].adwords_accounts_ attributes[:adwords_accounts] if attributes[:adwords_accounts]
            end
          end.to_xml
        end
    end
  end
end