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
      :image            => "http://testing.is/fun.jpg",
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


  describe ".update" do
    it "status == 200" do
      GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)
      stub_request(:post, GoogleContentApi.urls("products", sub_account_id, :dry_run => dry_run)).
        with(:headers => {
        'Content-Type'  => 'application/atom+xml',
        'Authorization' => "AuthSub token=#{fake_token}"
      }).to_return(:status => 200)

      subject.update_products(sub_account_id, [], dry_run).status.should == 200
    end
  end

  describe "private" do
    describe ".create_product_items_batch_xml" do
      it "creates an xml with all given product attributes" do
        result_xml = subject.send(:create_product_items_batch_xml, [product_attributes])

        result_xml.should match 'xmlns:batch="http://schemas.google.com/gdata/batch"'
        result_xml.should match 'xmlns:scp="http://schemas.google.com/structuredcontent/2009/products"'
        result_xml.should match 'batch:operation type="INSERT"'
        product_attributes.each { |attribute, value| result_xml.should match /#{value}/ }
      end

      it "calls .add_optional_values" do
        GoogleContentApi::Authorization.stub(:fetch_token).and_return(fake_token)
        Faraday.stub(:post).and_return(successful_response)

        subject.should_receive(:add_optional_values).once
        subject.create_products(sub_account_id, [product_attributes], dry_run)
      end
    end

    describe ".update_product_items_batch_xml" do
      it "creates an xml with all given product attributes" do
        result_xml = subject.send(:update_product_items_batch_xml, [product_attributes])
        result_xml.should match 'batch:operation type="UPDATE"'
        result_xml.should_not match 'batch:id'
        result_xml.should match 'items/products/schema/online'
        product_attributes.each{ |attribute,value| result_xml.should match /#{value}/ }
      end
    end

    describe ".add_optional_values" do
      let(:unit) { "g" }
      let(:unit_pricing_measure) { 100 }
      it "creates the xml with the given optional values" do
        result_xml = subject.send(:create_product_items_batch_xml, [product_attributes.merge(:unit => unit, :unit_pricing_measure => unit_pricing_measure)])
        result_xml.should match "<scp:unit_pricing_measure unit=\"#{unit}\">#{unit_pricing_measure}</scp:unit_pricing_measure>"
      end
    end
  end
end
