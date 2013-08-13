require 'spec_helper'
require 'ostruct'

describe GoogleContentApi::Product do
  subject { GoogleContentApi::Product }
  it { should respond_to(:create_products) }
  let(:sub_account_id) { "9898988" }
  let(:product_id) { "123123" }
  let(:dry_run) { true }
  let(:successful_response) { OpenStruct.new(:status => 200) }
  let(:product_attributes) {
    {
      :id               => "x",
      :title            => "Title",
      :description      => "desc",
      :link             => "http://testing.is/fun",
      :image            => "http://testting.is/fun.jpg",
      :content_language => "en",
      :target_country   => "US",
      :currency         => "USD",
      :price            => 0.99,
      :condition        => "new"
    }
  }

  describe ".create_products" do
    it "status == 200" do
      GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)
      stub_request(:post, GoogleContentApi.urls("products", sub_account_id, :dry_run => dry_run)).
        with(:headers => {
          'Content-Type'  => 'application/atom+xml',
          'Authorization' => "AuthSub token=#{fake_token}"
        }).to_return(:status => 200)

      subject.create_products(sub_account_id, [], dry_run).status.should == 200
    end
  end

  describe ".delete" do
    it "status == 200" do
      GoogleContentApi::Authorization.stub(:fetch_token).and_return(fake_token)
      Faraday.stub(:delete).and_return(successful_response)
      subject.delete(sub_account_id, :language => "de", :country => "de", :item_id => product_id).status.should == 200
    end
  end

  describe "private" do
    describe ".create_product_items_batch_xml" do
      it "test xml creation"
    end

    describe ".create_product_items_batch_xml" do
      it "calls .add_optional_values" do
        GoogleContentApi::Authorization.stub(:fetch_token).and_return(fake_token)
        Faraday.stub(:post).and_return(successful_response)

        subject.should_receive(:add_optional_values).once
        subject.create_products(sub_account_id, [product_attributes], dry_run)
      end
    end
  end
end
