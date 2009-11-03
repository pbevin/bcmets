module MaxMind
  City = Struct.new(:country, :state, :city)

  def self.lookup(ip_addr)
    # http://geoip3.maxmind.com/b?l=HINZ1x3Xvjap&i=24.24.24.24
    Net::HTTP.start('geoip3.maxmind.com') do |http|
      response = http.get("/b?l=HINZ1x3Xvjap&i=#{ip_addr}")
      # US,NJ,Jersey City,40.724499,-74.062103
      return parse(response.body)
    end
  end
  
  def self.parse(maxmind)
    country, state, city, rest = maxmind.split(",", 4).gsub("(null)", nil)
    City.new(country, state, city)
  end
  
  class City
    def to_s
      self.country = "UK" if country == "GB"
      if country == "US"
        "#{city}, #{state}"
      elsif state =~ /\d/
        "#{city} #{country}"
      elsif city == nil
        if state == nil
          country
        else
          "#{state}, #{country}"
        end
      else
        if state == nil
          "#{city} #{country}"
        else
          "#{city}, #{state}, #{country}"
        end
      end
    end
  end
end


class Array
  def gsub(from, to)
    map { |x| x == from ? to : x }
  end
end
