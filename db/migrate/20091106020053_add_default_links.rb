class AddDefaultLinks < ActiveRecord::Migration
  def self.up
    link("How to use the list", "/pages/howto")
    link("AdvancedBC.org", "http://www.advancedbc.org/")
    link("BrainMetsBC.org", "http://www.brainmetsbc.org/")
    link("Picture Trail",
         "http://www.picturetrail.com/sfx/album/listing/user/bcbeauties",
         "(login: bcbeauties/bcmets)")
    link("Where we Live", "http://bcmets.org/archive/article/122736")
    link("Pam's List",
         "http://advancedbc.org/content/pams-list-helpful-products-and-remedies")
    link("Abbreviation List", "http://darkwing.uoregon.edu/%7Ejbonine/abbrevs.html")
  end

  def self.down
    Link.delete_all
  end

  def self.link(title, url, text = nil)
    @@pos ||= 0
    
    Link.create(:title => title, :url => url, :text => text, :position => @@pos)
    @@pos += 1
  end
end
