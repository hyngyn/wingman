class PagesController < ApplicationController
  MAX_EVENTS_COUNT = 5
  
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
    return render :json => {}, :status => 500 if results.blank?
    summary = results.first.last.shift
    events = results.first.last
 
    @stripped_events = strip_event_results(events) rescue {}
    
    render partial: "search_results", :content_type => 'text/html'
  end

  private

    def strip_event_results(events)
      stripped_events = []
      events.each do |e|
        event_hash =  {}
        event = e["event"]

        logo_url = event["logo"]
        url = event["url"]
        event_name = event["title"].downcase.titleize
        address = event["venue"]["address"].to_s + ", " + event["venue"]["city"] + ", " + event["venue"]["country"]
        
        event_hash = { logo_url: logo_url,
                       url: url,
                       event_name: event_name,
                       address: address }
        stripped_events << event_hash
      end
      stripped_events
    end

    def get_city_region_from_input(location)
      city_region = location.split(',')
      city = city_region.first.strip.titleize rescue ""
      region = city_region.last.strip.upcase rescue ""
      return city, region
    end

    def eventbrite_api_search(interests, city, region, date_range)
      eb_auth_tokens = { app_key: 'HKZFAX6AT4QX2JVNN7',
                         user_key: '134983204943172706728' }

      eb_client = EventbriteClient.new(eb_auth_tokens)
      response = eb_client.event_search({ keywords: interests,
                                          city: city,
                                          region: region,
                                          date: date_range,
                                          max: MAX_EVENTS_COUNT })
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
