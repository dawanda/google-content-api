module GoogleContentApi

  class SubAccount
    class << self

      def get_all
        token            = Authorization.fetch_token
        sub_accounts_url = GoogleContentApi.urls("managed_accounts", google_user_id)
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

      def create(title, adult_content = false, attributes = {})
        token            = fetch_token
        sub_accounts_url = GoogleContentApi.urls("managed_accounts", google_user_id)
        xml              = create_xml(title, adult_content, attributes)
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

      def delete(id)
        token            = fetch_token
        sub_account_url = GoogleContentApi.urls("managed_accounts", google_user_id) + "/#{id}"
        Faraday.headers  = { "Authorization"  => "AuthSub token=#{token}" }
        response = Faraday.delete sub_account_url

        if response.status == 200
          response
        else
          raise "Unable to create sub account - received status #{response.status}. body: #{response.body}"
        end
      end

      private
        def create_xml(title, adult_content = false, attributes = {})
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

        def google_user_id
          GoogleContentApi.config["user_id"]
        end
    end
  end

end
