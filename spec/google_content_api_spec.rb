require 'webmock/rspec'
require 'lib/google_content_api'

describe GoogleContentApi do
  let(:user_id) { GoogleContentApi.config["user_id"] }
  it { should respond_to(:config) }
  it { should respond_to(:urls) }

  it "should have a config" do
    subject.config.should be_kind_of(Hash)
  end

  it "has a version" do
    GoogleContentApi::VERSION.should_not be_nil
  end

  describe "Client" do
    subject { GoogleContentApi::Client }
    it { should respond_to(:get_all_sub_accounts) }
  end

  describe "sub-accounts" do
    subject { GoogleContentApi::Client }
    let(:example_create_xml) { %Q|<?xml version=\"1.0\"?>\n<entry xmlns:sc=\"http://schemas.google.com/structuredcontent/2009\" xmlns=\"http://www.w3.org/2005/Atom\">\n  <title>#{sub_account_name}</title>\n  <sc:adult_content>no</sc:adult_content>\n</entry>\n| }
    let(:sub_account_name) { "test account" }
    let(:fake_token) { "123123" }

    it { should respond_to(:create_products) }
    it { should respond_to(:create_sub_account) }

    describe ".create_sub_account" do
      it "creates a sub account" do
        subject.should_receive(:create_sub_account_xml).
          once.with(sub_account_name, false, {}).and_return(example_create_xml)
        subject.should_receive(:fetch_token).once.and_return(fake_token)

        stub_request(:post, GoogleContentApi.urls("managed_accounts", user_id)).
          with(
            :body => example_create_xml,
            :headers => {
              'Accept'=>'*/*',
              'Authorization' => "AuthSub token=#{fake_token}",
              'Content-Length' => example_create_xml.length.to_s,
              'Content-Type' => 'application/atom+xml'
              }).to_return(
                :status => 201,
                :body => "<entry xmlns='...'>stuff</entry>")

        GoogleContentApi::Client.create_sub_account(sub_account_name, false).
          status.should == 201
      end
    end

    describe ".get_all_sub_accounts" do
      context "when status == 200" do
        it "returns the response" do
          subject.should_receive(:fetch_token).once.and_return(fake_token)

          stub_request(:get, GoogleContentApi.urls("managed_accounts", user_id)).
            with(:headers => {
              'Accept'=>'*/*',
              'Authorization' => "AuthSub token=#{fake_token}",
              'Content-Type'  => 'application/atom+xml'
            }).to_return(
              :status => 200,
              :body => "<entry xmlns='...'>blah blah</entry>")

          response = subject.get_all_sub_accounts
          response.status.should == 200
        end
      end

      context "when status != 200" do
        it "raises an error" do
          subject.should_receive(:fetch_token).once.and_return(fake_token)

          stub_request(:get, GoogleContentApi.urls("managed_accounts", user_id)).
            with(:headers => {
              'Accept'=>'*/*',
              'Authorization' => "AuthSub token=#{fake_token}",
              'Content-Type'  => 'application/atom+xml'
            }).to_return(
              :status => 400,
              :body => "<entry xmlns='...'>blah blah</entry>")

          expect { subject.get_all_sub_accounts }.to raise_error
        end
      end
    end

    describe ".delete_sub_account" do
      let(:sub_account_id) { "555555" }
      let(:delete_url) { GoogleContentApi.urls("managed_accounts", user_id) + "/#{sub_account_id}" }

      context "when status == 200" do
        it "returns the response" do
          subject.should_receive(:fetch_token).once.and_return(fake_token)
          Faraday.should_receive(:delete).
            with(delete_url).
            and_return( double("response", :status => 200) )

          response = subject.delete_sub_account sub_account_id
          response.status.should == 200
        end
      end

      context "when status != 200" do
        let(:example_delete_error_xml) { %Q|<?xml version='1.0' encoding='UTF-8'?><errors xmlns='http://schemas.google.com/g/2005'><error><domain>GData</domain><code>ResourceNotFoundException</code><internalReason>Managed account 15794381 not found</internalReason></error></errors>| }


        it "raises error" do
          subject.should_receive(:fetch_token).once.and_return(fake_token)
          Faraday.should_receive(:delete).
            with(delete_url).
            and_return( double("response",
              :status => 404,
              :body => example_delete_error_xml) )

          expect { subject.delete_sub_account(sub_account_id) }.to raise_error
        end
      end
    end
  end

end