module GoogleContentApi

  class Product
    class << self

      def create_products(sub_account_id, products, dry_run = false)
        token            = Authorization.fetch_token
        products_url     = GoogleContentApi.urls("products", sub_account_id, :dry_run => dry_run)
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

      def update_products(sub_account_id, products, dry_run = false)
        token            = Authorization.fetch_token
        products_url     = GoogleContentApi.urls("products", sub_account_id, :dry_run => dry_run)
        @sub_account_id  = sub_account_id
        xml              = update_product_items_batch_xml(products)
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

      def delete(sub_account_id, params)
        token           = Authorization.fetch_token
        product_url     = GoogleContentApi.urls("product", sub_account_id, :language => params[:language], :country => params[:country], :item_id => params[:item_id], :dry_run => params[:dry_run])
        Faraday.headers = { "Authorization" => "AuthSub token=#{token}" }

        response = Faraday.delete product_url

        if response.status == 200
          response
        else
          raise "Unable to delete product - received status #{response.status}. body: #{response.body}"
        end
      end

      def create
        raise "not implemented"
      end

      def update
        raise "not implemented"
      end

      private
        def create_item_xml(item)
          item[:id] = item_url(item[:id])

          NokogiriwXML::Builder.new do |xml|
            xml.entry(
                'xmlns'     => 'http://www.w3.org/2005/Atom',
                'xmlns:app' => 'http://www.w3.org/2007/app',
                'xmlns:sc'  => 'http://schemas.google.com/structuredcontent/2009',
                'xmlns:scp' => 'http://schemas.google.com/structuredcontent/2009/products',
                'xmlns:gd'  => 'http://schemas.google.com/g/2005') do
              add_mandatory_values(xml, item)
              add_optional_values(xml, item)
            end
          end.to_xml
        end

        def create_product_items_batch_xml(items)
          generalized_product_items_batch_xml(items, :type => 'INSERT')
        end

        def update_product_items_batch_xml(items)
          generalized_product_items_batch_xml(items, :type => 'UPDATE')
        end

        def generalized_product_items_batch_xml(items, opts)
          Nokogiri::XML::Builder.new do |xml|
            xml.feed('xmlns' => 'http://www.w3.org/2005/Atom', 'xmlns:batch' => 'http://schemas.google.com/gdata/batch') do
              items.each do |attributes|
                xml.entry('xmlns' => 'http://www.w3.org/2005/Atom', 'xmlns:sc' => 'http://schemas.google.com/structuredcontent/2009', 'xmlns:scp' => 'http://schemas.google.com/structuredcontent/2009/products', 'xmlns:app' => 'http://www.w3.org/2007/app') do
                  xml['batch'].operation_(:type => opts[:type])
                  add_mandatory_values(xml, attributes, opts)
                  add_optional_values(xml, attributes, opts)
                end
              end
            end
          end.to_xml
        end

        def add_mandatory_values(xml, attributes, opts = {})
          if  opts[:type] == 'UPDATE'
            xml.id_ GoogleContentApi.urls("item_to_update", @sub_account_id, :language => attributes[:content_language], :country => attributes[:target_country], :item_id => attributes[:id])
          else
            xml['batch'].id_ attributes[:id]
          end
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
        end

        def add_optional_values(xml, attributes, opts = {})
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
          if attributes.has_key?(:identifier_exists)
            xml['scp'].identifier_exists_ attributes[:identifier_exists]
          end
          if attributes[:unit_pricing_base_measure] && attributes[:unit]
            xml['scp'].unit_pricing_base_measure_ attributes[:unit_pricing_base_measure], :unit => attributes[:unit]
          end
          if attributes[:unit_pricing_measure] && attributes[:unit]
            xml['scp'].unit_pricing_measure_ attributes[:unit_pricing_measure], :unit => attributes[:unit]
          end
          if attributes[:sale_price]
            xml['scp'].sale_price_ attributes[:sale_price], :unit => attributes[:currency]
          end
          if attributes[:sale_price_effective_date]
            range = attributes[:sale_price_effective_date]
            format = "%Y-%m-%dT%H:%M:%SZ"
            xml['scp'].sale_price_effective_date range.begin.utc.strftime(format) + "/" + range.end.utc.strftime(format)
          end
          (0..4).each do |i|
            if attributes["custom_label_#{i}".to_sym]
              xml['scp'].send "custom_label_#{i}_".to_sym, attributes["custom_label_#{i}".to_sym]
            end
          end
        end
    end
  end

end
