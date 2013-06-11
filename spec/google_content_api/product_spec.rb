require 'spec_helper'

describe GoogleContentApi::Product do
  subject { GoogleContentApi::Product }
  it { should respond_to(:create_products) }
  let(:sub_account_id) { "9898988" }
  let(:dry_run) { true }

  describe ".create_products" do
    it "status == 200" do
      GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)
      stub_request(:post, GoogleContentApi.urls("products", sub_account_id, dry_run)).
        with(:headers => {
          'Content-Type'  => 'application/atom+xml',
          'Authorization' => "AuthSub token=#{fake_token}"
        }).to_return(:status => 200)

      subject.create_products(sub_account_id, [], dry_run).status.should == 200
    end
  end

  describe "private" do
    describe ".create_product_items_batch_xml" do
      it "test xml creation"
    end

    describe ".create_product_items_batch_xml" do
      it "calls .add_optional_values"
    end
  end
end
