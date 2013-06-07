require 'spec_helper'

describe GoogleContentApi::Product do
  subject { GoogleContentApi::Product }
  it { should respond_to(:create_products) }
end
