require "spec_helper"
describe PagesController do
  before(:each) do
    @expected_fail = { }.to_json
  end

  describe "search" do
    it "should render error because of empty input" do
      #default location set as San Francisco, CA
      get :search, location: "San Francisco, CA"
      response.body.should == @expected_fail
      response.code.should == "500"
    end

    it "should render error because of partial search" do
      get :search, location: "San Francisco, CA", start_date: "06/01/2013"
      response.body.should == @expected_fail
      response.code.should == "500"
    end

    it "should render success with no interests" do
      get :search, location: "San Francisco, CA", start_date: "06/01/2013", end_date: "06/08/2013"
      response.should render_template(partial: '_search_results')
      response.code.should == "200"
    end

    it "should render success with interests" do
      get :search, location: "San Francisco, CA", start_date: "06/01/2013", end_date: "06/08/2013", interests: "coffee, outdoors"
      response.should render_template(partial: '_search_results')
      response.code.should == "200"
    end

    it "should render error because mispelled or nonexistent interests" do
      get :search, location: "San Francisco, CA", start_date: "06/01/2013", end_date: "06/08/2013", interests: "dawerasdfad"
      response.body.should == @expected_fail
      response.code.should == "500"
    end

  end


end



 
