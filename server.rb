require 'sinatra'
require 'sinatra/cookies'
require 'redis'
require 'securerandom'
require 'uri'

# Connect to redis
redis = Redis.new

# Update cookie settings (1 year storage)
set :cookie_options, :expires => Time.now + (60 * 60 * 24 * 365 * 1)

# Handle middleware
before do
  # Read user id
  user_id = cookies[:user_id]

  # Check if user id exists
  if user_id.nil?
    # Generate and store new user id
    cookies[:user_id] = SecureRandom.hex 16
  end
end

# Handle GET routes
get '/' do
  # Render index view
  erb :index
end

get '/urls' do
  # Read user id
  user_id = cookies[:user_id]

  # Read urls for user
  urls = redis.lrange("user:#{user_id}:urls", 0, -1)

  # Render urls view
  erb :urls, :locals => {
    :user_id => user_id,
    :urls => urls
  }
end

get '/recover' do
  # Render recover page
  erb :recover
end

get '/:url' do
  # Get url from redis
  url = redis.get("url:#{params[:url]}")

  # Check if url exists
  if !url.nil?
    # Redirect
    redirect url, 302
  end

  # Render not found request
  not_found
end

get '/:url/view' do
  # Get url from redis
  url = redis.get("url:#{params[:url]}")

  # Check if url exists
  if !url.nil?
    # Render page
    erb :url, :locals => {
      :url => url,
      :url_id => params[:url]
    }
  else
    # Render not found request
    not_found
  end
end

# Handle POST routes
post '/urls' do
  # Read user id
  user_id = cookies[:user_id]

  # Read form body
  url = params['url']

  # Validate url
  if url =~ URI::regexp
    # Generate new url id
    # until unique one found
    loop do
      # Generate new id
      url_id = SecureRandom.hex 2

      # Check if id is used
      if !redis.exists("url:#{url_id}")
        # Store url
        redis.set("url:#{url_id}", url)

        # Push to user urls
        redis.lpush("user:#{user_id}:urls", url_id)

        # Redirect
        redirect "/#{url_id}/view", 302

        # Break loop
        break
      end
    end
  else
    # Render invalid request
    error 403
  end
end

post '/recover' do
  # Read recovered user id
  user_id = params['user_id']

  # Check length
  if user_id.length == 32
    # Update cookie
    cookies[:user_id] = user_id

    # Redirect to urls overview
    redirect '/urls', 302
  end

  # Render invalid request
  error 403
end

# Handle errors
not_found do
  # Rendner an 404 not found error page
  erb :error, :locals => {
    :error_code => 404,
    :error_message => "not found"
  }
end

error do
  # Rendner an 500 internal error page
  erb :error, :locals => {
    :error_code => 500,
    :error_message => "internal error"
  }
end

error 403 do
  # Redner an 500 internal error page
  erb :error, :locals => {
    :error_code => 403,
    :error_message => "invalid request"
  }
end
