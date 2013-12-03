# Google Content API [![Gem Version](https://badge.fury.io/rb/google-content-api.png)](http://badge.fury.io/rb/google-content-api)

Gem for interacting with [Google's Content API for Shopping](https://developers.google.com/shopping-content/).

## Installation

Add this line to your application's Gemfile:

    gem 'google-content-api', :require => "google_content_api"

And execute:

    $ bundle

Or install it yourself as:

    $ gem install google-content-api

And `require 'google_content_api'`

## Example Usage

```ruby
GoogleContentApi::SubAccount.get_all
# Get all sub accounts for the user_id specified in conf/google_content_api.yml
# Note: _must_ be a multi-user google account id

GoogleContentApi::SubAccount.create(title, adult_content, attributes)
# Create a new subaccount with _title_.
# Use attributes to include 'description', 'link', 'internal_id',
# 'reviews_url' or 'adwords_accounts'.

GoogleContentApi::SubAccount.delete(sub_account_id)
# Deletes a sub account.

GoogleContentApi::Product.create_products(sub_account_id, products, dry_run)
# Creates products for sub_account_id using batch request. dry_run defaults to false (used for debugging)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
