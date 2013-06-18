describe GoogleContentApi::SubAccount do
    subject { GoogleContentApi::SubAccount }
    let(:user_id) { GoogleContentApi.config["user_id"] }
    let(:example_create_xml) { %Q|<?xml version=\"1.0\"?>\n<entry xmlns:sc=\"http://schemas.google.com/structuredcontent/2009\" xmlns=\"http://www.w3.org/2005/Atom\">\n  <title>#{sub_account_name}</title>\n  <sc:adult_content>no</sc:adult_content>\n</entry>\n| }
    let(:sub_account_name) { "test account" }

    it { should respond_to(:create) }
    it { should respond_to(:get_all) }
    it { should respond_to(:delete) }

    describe ".create" do
      it "creates a sub account" do
        subject.should_receive(:create_xml).
          once.with(sub_account_name, false, {}).and_return(example_create_xml)
        GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)

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

        response = subject.create(sub_account_name, false)
        response.status.should == 201
      end
    end

    describe ".get_all" do
      before(:each) do
        GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)
      end

      context "when status == 200" do
        it "returns the response" do

          stub_request(:get, GoogleContentApi.urls("managed_accounts", user_id)).
            with(:headers => {
              'Accept'=>'*/*',
              'Authorization' => "AuthSub token=#{fake_token}",
              'Content-Type'  => 'application/atom+xml'
            }).to_return(
              :status => 200,
              :body => "<entry xmlns='...'>blah blah</entry>")

          response = subject.get_all
          response.status.should == 200
        end
      end

      context "when status != 200" do
        it "raises an error" do
          stub_request(:get, GoogleContentApi.urls("managed_accounts", user_id)).
            with(:headers => {
              'Accept'=>'*/*',
              'Authorization' => "AuthSub token=#{fake_token}",
              'Content-Type'  => 'application/atom+xml'
            }).to_return(
              :status => 400,
              :body => "<entry xmlns='...'>blah blah</entry>")

          expect { subject.get_all }.to raise_error
        end
      end
    end

    describe ".delete_sub_account" do
      let(:sub_account_id) { "555555" }
      let(:delete_url) { GoogleContentApi.urls("managed_accounts", user_id) + "/#{sub_account_id}" }

      context "when status == 200" do
        it "returns the response" do
          GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)
          Faraday.should_receive(:delete).
            with(delete_url).
            and_return( double("response", :status => 200) )

          response = subject.delete sub_account_id
          response.status.should == 200
        end
      end

      context "when status != 200" do
        let(:example_delete_error_xml) { %Q|<?xml version='1.0' encoding='UTF-8'?><errors xmlns='http://schemas.google.com/g/2005'><error><domain>GData</domain><code>ResourceNotFoundException</code><internalReason>Managed account 15794381 not found</internalReason></error></errors>| }


        it "raises error" do
          GoogleContentApi::Authorization.should_receive(:fetch_token).once.and_return(fake_token)
          Faraday.should_receive(:delete).
            with(delete_url).
            and_return( double("response",
              :status => 404,
              :body => example_delete_error_xml) )

          expect { subject.delete(sub_account_id) }.to raise_error
        end
      end
    end
  end