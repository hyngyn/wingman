class PagesController < ApplicationController
  MAX_EVENTS_COUNT = 5
  CITIES = [["San Francisco, CA","San Francisco, CA"], ["Atlanta, GA", "Atlanta, GA"], ["Austin, TX","Austin, TX"], ["Boston, MA","Boston, MA"], ["Chicago, IL","Chicago, IL"],
            ["Dallas, TX", "Dallas, TX"], ["Denver, CO","Denver, CO"], ["Houston, TX", "Houston, TX"], ["Los Angeles, CA","Los Angeles, CA"],
            ["Miami, FL","Miami, FL"], ["New York, NY","New York, NY"], ["Philadelphia, PA", "Philadelphia, PA"], ["Phoenix, AZ","Phoenix, AZ"],
            ["San Jose, CA","San Jose, CA"], ["Seattle, WA","Seattle, WA"], ["Washington, DC","Washington, DC"]]

  BAD_WEATHER = ["chancerain", "rain"]

  EVENTBRITE_CATEGORIES = "entertainment, others, performances, social, sports, travel, fairs, food, music, recreation"

  # landing page
  def home
  end
  
  # search driver
  #
  # inputs: params = {  location = user select string location as "San Francisco, CA"
  #                     interests_list = user input string with comma separated interests
  #                     start_date = user select start date with format
  #                     end_date =  user select start date with format  } 
  #
  # outputs: successs = partial 'search_results' if there are results
  #         fail = renders empty json and status 500 if no results    
  def search
    location = params[:location].to_s
    interests_list = params[:interests].to_s
    start_date = params[:start_date].to_s
    end_date = params[:end_date].to_s

    city, region = get_city_region_from_input(location)
    interests = interests_list.split(',').join('%20OR%20').gsub(' ', '')
   
    date_array = generate_date_array(start_date, end_date)
    forecast_days = get_weather(city, region)

    filtered_dates = filter_bad_weather(forecast_days, date_array)

    results = eventbrite_api_search(interests, city, region, date_array) rescue nil
    return render :json => {}, :status => 500 if results.blank?
    summary = results.first.last.shift
    events = results.first.last

    #strip events of days with bad forecast and take first 5
    @stripped_events = strip_event_results(events, filtered_dates).first(5)

    return render :json => {}, :status => 500 if @stripped_events.blank?

    render partial: "search_results", :content_type => 'text/html'
  end

  private

    # filter_bad_weather = filters events with bad forecasts
    #
    # inputs: forecast_days = hash of dates and corresponding forecast
    #         date_array = user selected dates in an array
    #
    # outputs: date_array = an array of days that have good forecast
    def filter_bad_weather(forecast_days, date_array)
      date_array.reject!{|day| BAD_WEATHER.include?(forecast_days[day]) }
      return date_array.blank? ? [] : date_array
    end

    # get_weather = get full weather report for each day from weatherunderground
    #
    # input: city = string of city i.e. "San Francisco"
    #        region = string of region i.e. "CA"
    #
    # outputs: forecast_days = hash of days (string) as keys and day forecast (string) as values i.e. {"2013/06/01": "rain"}
    def get_weather(city, region)
      w_api = Wunderground.new("2064437974116822")
      forecast = w_api.forecast10day_for( region, city.gsub(" ","%20") )["forecast"]["txt_forecast"]["forecastday"]
      forecast_days =  {}

      # API call returns day and night forecast, we only want the day forecast
      forecast.each_with_index do |item,index| 
        if index % 2 == 0 
          day = (Time.now + (index/2).days).strftime("%Y/%m/%d").to_s
          forecast_days[day] = item["icon"]
        end
      end
      forecast_days
    end

    # strip_events_results = strip full events of bad weather days
    #
    # input: events = array of events
    #        good_days = events of good forecast days
    # outputs: stripped_events= array of events without bad forecast days
    def strip_event_results(events, good_days)
      stripped_events = []
      events.each do |e|
        event_hash =  {}
        event = e["event"]
        event_date = event["start_date"][0..9]
        logo_url = event["logo"]
        url = event["url"]
        event_name = event["title"].downcase.titleize
        address = event["venue"]["address"].to_s + ", " + event["venue"]["city"] + ", " + event["venue"]["country"]
        address.sub!(", ", "") if address[0,2] == ", "

        event_hash = { logo_url: logo_url,
                       url: url,
                       event_name: event_name,
                       address: address,
                       date: event_date }

        stripped_events << event_hash
      end
      stripped_events.reject{|event| good_days.include?(event[:date].to_s)}
    end

    # get_city_region_from_input: split location string and return city, region
    #
    # inputs: location = string of city and region as "city, region"
    #
    # outputs: city, region as "City", "REGION"
    def get_city_region_from_input(location)
      city_region = location.split(',')
      city = city_region.first.strip.titleize rescue ""
      region = city_region.last.strip.upcase rescue ""
      return city, region
    end


    # eventbrite_api_search = eventbrite api call
    #
    # inputs: interests = string of formatted interests
    #         city = string of city
    #         region = string of region
    #         date array = array of dates (strings)
    #
    # output: response = raw eventbrite response of events in JSON
    def eventbrite_api_search(interests, city, region, date_array)
      eb_auth_tokens = { app_key: 'HKZFAX6AT4QX2JVNN7',
                         user_key: '134983204943172706728' }

      eb_client = EventbriteClient.new(eb_auth_tokens)

      date_range =generate_date_string(date_array.first, date_array.last)
      response = eb_client.event_search({ keywords: interests,
                                          city: city,
                                          region: region,
                                          date: date_range,
                                          max: 100,
                                          category: EVENTBRITE_CATEGORIES })
    end

    # generate_date_string = generates date string for eventbrite api call
    #
    # inputs: start_date = string in date format yyyy/mm/dd
    #         end_date = string in date format yyyy/mm/dd
    #
    # outputs: eventbrite_date = a string with the start date to end date in format "yyyy-mm-dd yyyy-mm-dd" 
    def generate_date_string(start_date, end_date)
      start_array = start_date.scan(/[0-9]+/)
      end_array = end_date.scan(/[0-9]+/)

      eventbrite_date =  start_array.join('-') + " " + end_array.join('-')
    end

    # generate_date_array = get arrays of days in date format yyyy/mm/dd
    # 
    # inputs: start_date = user input start date
    #         end_date = user input end date
    #
    # outputs: date_array = an array of dates (strings) in date format yyyy/mm/dd
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
