require 'rails_helper'

RSpec.describe GoogleTransitDataFeedPublicFeed, :type => :model do
  describe "#extract_and_load!" do
    it "persists all public feeds listed on the google transit data feed wiki" do
      wiki_table_row = <<-HTML
        <tr>
          <td style="border: 1px solid #ccc; padding: 5px;">
            <a href="http://www.trimet.org/" rel="nofollow">TriMet</a>
          </td>
          <td style="border: 1px solid #ccc; padding: 5px;"> Portland, OR </td>
          <td style="border: 1px solid #ccc; padding: 5px;">
            <a href="http://developer.trimet.org/schedule/gtfs.zip" rel="nofollow">http://developer.trimet.org/schedule/gtfs.zip</a>
          </td>
          <td style="border: 1px solid #ccc; padding: 5px;"> Use is subject to the terms of their <a href="http://developer.trimet.org/terms_of_use.shtml" rel="nofollow">developer license</a> </td>
        </tr>
      HTML
      parsed_row = Nokogiri::HTML(wiki_table_row)
      binding.pry


=begin

      [5] pry(GoogleTransitDataFeedPublicFeed)> row
      => #(Element:0x3fd57d93578c {
        name = "tr",
        children = [

          #(Element:0x3fd57cfa1784 {
            name = "td",
            attributes = [ #(Attr:0x3fd57cfa0dc0 { name = "style", value = "border: 1px solid #ccc; padding: 5px;" })],
            children = [
              #(Text " "),
              #(Element:0x3fd57cf902cc {
                name = "a",
                attributes = [
                  #(Attr:0x3fd57cf8d9f0 { name = "href", value = "http://www.trimet.org/" }),
                  #(Attr:0x3fd57cf8d9dc { name = "rel", value = "nofollow" })],
                children = [ #(Text "TriMet")]
                }),
              #(Text " ")]
            }),

          #(Element:0x3fd57c993018 {
            name = "td",
            attributes = [ #(Attr:0x3fd57c98fe18 { name = "style", value = "border: 1px solid #ccc; padding: 5px;" })],
            children = [ #(Text " Portland, OR ")]
            }),

          #(Element:0x3fd57c97f734 {
            name = "td",
            attributes = [ #(Attr:0x3fd57c97e870 { name = "style", value = "border: 1px solid #ccc; padding: 5px;" })],
            children = [
              #(Text " "),
              #(Element:0x3fd57c96ba68 {
                name = "a",
                attributes = [
                  #(Attr:0x3fd57c96afdc { name = "href", value = "http://developer.trimet.org/schedule/gtfs.zip" }),
                  #(Attr:0x3fd57c96afc8 { name = "rel", value = "nofollow" })],
                children = [ #(Text "http://developer.trimet.org/schedule/gtfs.zip")]
                }),
              #(Text " ")]
            }),

          #(Element:0x3fd57c95a150 {
            name = "td",
            attributes = [ #(Attr:0x3fd57c957270 { name = "style", value = "border: 1px solid #ccc; padding: 5px;" })],
            children = [
              #(Text " Use is subject to the terms of their "),
              #(Element:0x3fd57c94762c {
                name = "a",
                attributes = [
                  #(Attr:0x3fd57c946c04 { name = "href", value = "http://developer.trimet.org/terms_of_use.shtml" }),
                  #(Attr:0x3fd57c946bf0 { name = "rel", value = "nofollow" })],
                children = [ #(Text "developer license")]
                }),
              #(Text " ")]
            })]
        })

=end

    end
  end
end
