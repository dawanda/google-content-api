module GoogleContentApi

  class Product
    class << self

      def create_products(sub_account_id, products, dry_run = false)
        token            = Authorization.fetch_token
        products_url     = GoogleContentApi.urls("products", sub_account_id, dry_run)
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
        def create_product_items_batch_xml(items)
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
                  xml['scp'].availability_ attributes[:availability]
                  xml['scp'].condition_(attributes[:condition] != 9 ? "new" : "used")
                  xml['scp'].price_ attributes[:price], :unit => attributes[:currency]

                  # optional values
                  add_optional_values(xml, attributes)
                end
              end
            end
          end.to_xml
        end

        def add_optional_values(xml, attributes)
          if attributes[:expiration_date]
            xml['sc'].expiration_date_  attributes[:expiration_date]
          end
          if attributes[:adult]
            xml['sc'].adult_ attributes[:adult]
          end
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
          if attributes[:adwords_grouping]
            xml['scp'].adwords_grouping_ attributes[:adwords_grouping]
          end
          if attributes[:adwords_labels]
            xml['scp'].adwords_labels_ attributes[:adwords_labels]
          end
          if attributes[:adwords_redirect]
            xml['scp'].adwords_redirect_ attributes[:adwords_redirect]
          end
          if attributes[:shipping]
            xml['scp'].shipping_ do
              xml['scp'].shipping_country_ attributes[:shipping][:shipping_country]
              xml['scp'].shipping_price_ attributes[:shipping][:shipping_price], :unit => attributes[:currency]
              xml['scp'].shipping_service_ attributes[:shipping][:shipping_service]
            end
          end
          if attributes[:size]
            xml['scp'].size_ attributes[:size]
          end
          if attributes[:gender]
            xml['scp'].gender_ attributes[:gender]
          end
          if attributes[:age_group]
            xml['scp'].age_group_ attributes[:age_group]
          end
        end
    end
  end

end