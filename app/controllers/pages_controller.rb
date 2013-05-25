class PagesController < ApplicationController

  def home

  end
  
  def search
    location = params[:location].to_s
    interests_list = params[:interests].to_s
    start_date = params[:start_date].to_s
    end_date = params[:end_date].to_s

    city, region = get_city_region_from_input(location)
    interests = interests_list.split(',').join('%20OR%20').gsub(' ', '')
    eventbrite_date_range = generate_date_string(start_date, end_date)

    results = eventbrite_api_search(interests, city, region, eventbrite_date_range) rescue nil
    
    summary = results.first.last.shift
    events = results.first.last

    render nothing: true
  end

  private

    def get_city_region_from_input(location)
      city_region = location.split(',')
      return city_region.first.strip, city_region.last.strip
    end

    def eventbrite_api_search(interests, city, region, date_range)
      eb_auth_tokens = { app_key: 'HKZFAX6AT4QX2JVNN7',
                         user_key: '134983204943172706728' }

      eb_client = EventbriteClient.new(eb_auth_tokens)
      response = eb_client.event_search({ keywords: interests,
                                          city: city,
                                          region: region,
                                          date: date_range })
    end

    def generate_date_string(start_date, end_date)
      # [mm,dd,yyyy]
      start_array = start_date.scan(/[0-9]+/)
      end_array = end_date.scan(/[0-9]+/)

      # [yyyy,dd,mm]
      start_array.reverse!
      end_array.reverse!

      # [yyyy,mm,dd]
      start_array[1], start_array[2] = start_array[2], start_array[1]
      end_array[1], end_array[2] = end_array[2], end_array[1]

      eventbrite_date =  start_array.join('-') + " " + end_array.join('-')
    end
end
