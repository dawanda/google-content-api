require 'spec_helper'

describe GoogleContentApi do
  it { should respond_to(:config) }
  it { should respond_to(:urls) }

  it "should have a config" do
    subject.config.should be_kind_of(Hash)
  end

  it "has a version" do
    GoogleContentApi::VERSION.should_not be_nil
  end
end
