class PagesController < ApplicationController
  MAX_EVENTS_COUNT = 5
  CITIES = [["San Francisco, CA","San Francisco, CA"], ["Atlanta, GA", "Atlanta, GA"], ["Austin, TX","Austin, TX"], ["Boston, MA","Boston, MA"], ["Chicago, IL","Chicago, IL"],
            ["Dallas, TX", "Dallas, TX"], ["Denver, CO","Denver, CO"], ["Houston, TX", "Houston, TX"], ["Los Angeles, CA","Los Angeles, CA"],
            ["Miami, FL","Miami, FL"], ["New York, NY","New York, NY"], ["Philadelphia, PA", "Philadelphia, PA"], ["Phoenix, AZ","Phoenix, AZ"],
            ["San Jose, CA","San Jose, CA"], ["Seattle, WA","Seattle, WA"], ["Washington, DC","Washington, DC"]]
<<<<<<< HEAD
  BAD_WEATHER = ["chancerain", "rain"]
=======
  EVENTBRITE_CATEGORIES = "entertainment, others, performances, social, sports, travel, fairs, food, music, recreation"

>>>>>>> 53b2635718d0684b9f35ffdb97977c513eda6cfa
  def home

  end
  
  #search driver
  def search
    location = params[:location].to_s
    interests_list = params[:interests].to_s
    start_date = params[:start_date].to_s
    end_date = params[:end_date].to_s

    city, region = get_city_region_from_input(location)
    interests = interests_list.split(',').join('%20OR%20').gsub(' ', '')
   
    eventbrite_date_array = generate_date_array(start_date, end_date)
    forecast_days = get_weather(city, region)

    filtered_date = filter_bad_weather(forecast_days, eventbrite_date_array)

    results = eventbrite_api_search(interests, city, region, eventbrite_date_array) rescue nil
    return render :json => {}, :status => 500 if results.blank?
    summary = results.first.last.shift
    events = results.first.last
 
    @stripped_events = strip_event_results(events) rescue {}
    
    render partial: "search_results", :content_type => 'text/html'
  end

  private

<<<<<<< HEAD
    def filter_bad_weather(forecast_days, eventbrite_date_array)
      eventbrite_date_array.reject!{|day| BAD_WEATHER.include?(forecast_days[day]) }
    end

    def get_weather(city, region)
      w_api = Wunderground.new("2064437974116822")
      forecast = w_api.forecast10day_for(region,city.gsub(" ","%20"))["forecast"]["txt_forecast"]["forecastday"]
      forecast_days =  {}

      forecast.each_with_index do |item,index| 
        if index % 2 == 0 
          day = (Time.now + (index/2).days).strftime("%Y/%m/%d").to_s
 
          forecast_days[day] = item["icon"]
        end
      end
      forecast_days
    end

=======
    #strip full events hash to relevant info to display in view
>>>>>>> 53b2635718d0684b9f35ffdb97977c513eda6cfa
    def strip_event_results(events)
      stripped_events = []
      events.each do |e|
        event_hash =  {}
        event = e["event"]

        logo_url = event["logo"]
        url = event["url"]
        event_name = event["title"].downcase.titleize
        address = event["venue"]["address"].to_s + ", " + event["venue"]["city"] + ", " + event["venue"]["country"]
        address.sub!(", ", "") if address[0,2] == ", "

        event_hash = { logo_url: logo_url,
                       url: url,
                       event_name: event_name,
                       address: address }

        stripped_events << event_hash
      end
      stripped_events
    end

    #split location string and return city, region
    def get_city_region_from_input(location)
      city_region = location.split(',')
      city = city_region.first.strip.titleize rescue ""
      region = city_region.last.strip.upcase rescue ""
      return city, region
    end

<<<<<<< HEAD
    def eventbrite_api_search(interests, city, region, date_array)
=======
    #eventbrite api call
    def eventbrite_api_search(interests, city, region, date_range)
>>>>>>> 53b2635718d0684b9f35ffdb97977c513eda6cfa
      eb_auth_tokens = { app_key: 'HKZFAX6AT4QX2JVNN7',
                         user_key: '134983204943172706728' }

      eb_client = EventbriteClient.new(eb_auth_tokens)
<<<<<<< HEAD

      response_array = []
      date_array.each do |date|
        date_parts = date.scan(/[0-9]+/)
        ruby_date = Date.strptime("{ #{date_parts[0]}, #{date_parts[1]}, #{date_parts[2]} }", "{ %Y, %m, %d }")

        next_day = (ruby_date + 1.days).strftime("%Y/%m/%d").to_s

        date_range =generate_date_string(date, next_day)
        response = eb_client.event_search({ keywords: interests,
                                            city: city,
                                            region: region,
                                            date: date_range })
        response_array << response
      end
      response_array
=======
      response = eb_client.event_search({ keywords: interests,
                                          city: city,
                                          region: region,
                                          date: date_range,
                                          max: MAX_EVENTS_COUNT,
                                          category: EVENTBRITE_CATEGORIES })
>>>>>>> 53b2635718d0684b9f35ffdb97977c513eda6cfa
    end

    #generate date string for eventbrite api call
    def generate_date_string(start_date, end_date)
      start_array = start_date.scan(/[0-9]+/)
      end_array = end_date.scan(/[0-9]+/)
      eventbrite_date =  start_array.join('-') + " " + end_array.join('-')
    end

    def generate_date_array(start_date, end_date)
      start_array = start_date.scan(/[0-9]+/)
      end_array = end_date.scan(/[0-9]+/)
      ruby_start_date = Date.strptime("{ #{start_array[2]}, #{start_array[0]}, #{start_array[1]} }", "{ %Y, %m, %d }")
      ruby_end_date =Date.strptime("{ #{end_array[2]}, #{end_array[0]}, #{end_array[1]} }", "{ %Y, %m, %d }")
      num_of_days = (ruby_end_date-ruby_start_date).to_i + 1
      date_array=[]
      index = 0
      num_of_days.times do
        date_array << (ruby_start_date + index.days).strftime("%Y/%m/%d").to_s
        index += 1
      end
      date_array
    end
end
