require 'sinatra'
require 'houston'
require 'json'

class PushIt < Sinatra::Base
  register Sinatra::Initializers
  attr_reader :apn_certificate, :apn_environment

  def initialize
    super()
    @apn_certificate = ENV['APN_CERTIFICATE'] || 'apple_push_notification.pem'
    @apn_environment = ENV['APN_ENVIRONMENT'] || 'development'
  end

  before do
    content_type :json
  end

  head '/message' do
    status 503 and return unless client

    status 204
  end

  post '/message' do
    params = JSON.parse(request.body.read)
    status 503 and return unless client
    status 503 and return unless params["payload"]

    tokens = params["tokens"] || []

    options = params["payload"]
    alert = options["aps"]["alert"]
    badge = options["aps"]["badge"]
    sound = options["aps"]["sound"]
    category = options["aps"]["category"]
    expiry = options["aps"]["expiry"]
    id = options["aps"]["id"]
    priority = options["aps"]["priority"]
    content_available = options["aps"]["content_available"] || options["aps"]["content-available"]
    options.delete("aps")

    begin
      notifications = tokens.collect do |token|
        notification = Houston::Notification.new(options.update({device: token, alert: alert, badge: badge, sound: sound}))
        notification.category = category if category
        notification.expiry = expiry if expiry
        notification.id = id if id
        notification.priority = priority if priority
        notification.content_available = 1 if content_available
        notification
      end
      client.push(*notifications)

      status 204
    rescue => error
      status 500

      {error: error}.to_json
    end
  end

  private

  def client
    @client ||= begin
      return nil unless apn_certificate and ::File.exist?(apn_certificate)

      client = case apn_environment.to_sym
               when :development
                 Houston::Client.development
               when :production
                 Houston::Client.production
               end

      client.certificate = ::File.read(apn_certificate)

      return client
    rescue
      return nil
    end
  end
end
