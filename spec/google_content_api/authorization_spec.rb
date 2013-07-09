require 'spec_helper'

describe GoogleContentApi::Authorization do
  subject { GoogleContentApi::Authorization }

  describe ".refresh_token" do
    context "when 2 minutes didn't pass" do
      it "doesn't call fetch_access_token!" do
        subject.send :class_variable_set, :@@token_date, Time.now
        Signet::OAuth2::Client.any_instance.should_not_receive(:fetch_access_token!)
        subject.fetch_token
      end
    end

    context "when 2 minutes have passed" do
      it "calls fetch_access_token!" do
        subject.send :class_variable_set, :@@token_date, Time.now - 121
        Signet::OAuth2::Client.any_instance.should_receive(:fetch_access_token!)
        subject.fetch_token
      end
    end
  end

  describe ".fetch_token" do
    it "always returns a token" do
      Signet::OAuth2::Client.any_instance.stub(:fetch_access_token!)
      Signet::OAuth2::Client.any_instance.stub(:access_token).and_return(fake_token)
      2.times { subject.fetch_token.should == fake_token }
    end
  end
end
