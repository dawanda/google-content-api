require "lib/google_content_api"

describe GoogleContentApi do

  it "has a version" do
    GoogleContentApi::VERSION.should_not be_nil
  end

  describe GoogleContentApi, 'Client' do
    subject { GoogleContentApi::Client }
    it { should respond_to(:get_all_sub_accounts) }
  end

  describe "sub-accounts" do
    xit "gets all subaccounts" do
      client = GoogleContentApi.new
      response = client.subaccounts.get_all
      response.should_not be_nil
    end
  end

end