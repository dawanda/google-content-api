module GoogleContentApi

  class Client
    class << self

    def get_all_sub_accounts
      token            = fetch_token
      sub_accounts_url = GoogleContentApi.urls["managed_accounts"]
      Faraday.headers  = {
        "Content-Type"  => "application/atom+xml",
        "Authorization" => "AuthSub token=#{token}"
      }

      response = Faraday.get sub_accounts_url

      if response.status == 200
        response.body
      else
        raise "request unsuccessful - received status #{response.status}"
      end
    end

    def created_sub_account(title, adult_content = false, attributes = {})
      token            = fetch_token
      sub_accounts_url = GoogleContentApi.urls["managed_accounts"]
      xml              = create_sub_account_xml(title, adult_content, attributes)
      Faraday.headers  = {
        "Content-Type"   => "application/atom+xml",
        "Content-Length" => xml.length.to_s,
        "Authorization"  => "AuthSub token=#{token}"
      }

      response = Faraday.post sub_accounts_url, xml

      if response.status == 201
        response.body
      else
        raise "Unable to create sub account - received status #{response.status}"
      end
    end

    private
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

      def create_sub_account_xml(title, adult_content = false, attributes = {})
        adult_content = !adult_content ? "no" : "yes"
        xml = %Q|<entry xmlns='http://www.w3.org/2005/Atom' xmlns:sc='http://schemas.google.com/structuredcontent/2009'>
                  <title>#{title}</title>
                  <sc:adult_content>#{adult_content}</sc:adult_content>|
        xml << "<content>#{attributes[:description]}</content>"                if attributes[:description]
        xml << "<link>#{attributes[:link]}</link>"                             if attributes[:link]
        xml << "<sc:internal_id>#{attributes[:internal_id]}</sc:internal_id>"  if attributes[:internal_id]
        xml << "<sc:reviews_url>#{attributes[:reviews_url]}</sc:reviews_url>"  if attributes[:reviews_url]
        xml << "<sc:adwords_accounts>#{attributes[:adwords_accounts]}</sc:adwords_accounts>" if attributes[:adwords_accounts]
        xml << "</entry>"
      end

    end
  end

end