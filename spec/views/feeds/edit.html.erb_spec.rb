require 'rails_helper'

RSpec.describe "feeds/edit", :type => :view do
  before(:each) do
    @feed = assign(:feed, Feed.create!(
      :source_url => "MyText"
    ))
  end

  it "renders the edit feed form" do
    render

    assert_select "form[action=?][method=?]", feed_path(@feed), "post" do

      assert_select "textarea#feed_source_url[name=?]", "feed[source_url]"
    end
  end
end
