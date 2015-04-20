require 'rails_helper'

RSpec.describe "feeds/new", :type => :view do
  before(:each) do
    assign(:feed, Feed.new(
      :source_url => "MyText"
    ))
  end

  it "renders new feed form" do
    render

    assert_select "form[action=?][method=?]", feeds_path, "post" do

      assert_select "textarea#feed_source_url[name=?]", "feed[source_url]"
    end
  end
end
