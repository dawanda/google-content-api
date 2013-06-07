module GoogleContentApi

  class Authorization
    class << self

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

    end
  end

end