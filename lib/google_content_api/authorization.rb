module GoogleContentApi

  class Authorization
    class << self

      def fetch_token
        @@client ||= Google::APIClient.new(
          :application_name    => GoogleContentApi.config["application_name"],
          :application_version => GoogleContentApi.config["application_version"]
        )

        @@client.authorization.client_id     = GoogleContentApi.config["client_id"]
        @@client.authorization.client_secret = GoogleContentApi.config["client_secret"]
        @@client.authorization.redirect_uri  = GoogleContentApi.config["redirect_uri"]
        @@client.authorization.refresh_token = GoogleContentApi.config["refresh_token"]
        @@client.authorization.scope         = GoogleContentApi.config["content_api_scope"]

        refresh_token
      end

      private
        def refresh_token
          @@token_date ||= nil
          time_now = Time.now
          if @@token_date.nil? || (@@token_date + 120 < time_now)
            @@client.authorization.fetch_access_token!
            @@token_date = time_now
          end
          @@client.authorization.access_token
        end
          # p.s - we can consider using:
          # client.authorization.update_token!
    end
  end

end