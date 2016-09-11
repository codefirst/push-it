require 'sinatra'
require 'lowdown'
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
    status 503 and return unless clients and !clients.empty?

    status 204
  end

  post '/message' do
    params = JSON.parse(request.body.read)
    status 503 and return unless clients and !clients.empty?
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
        notification = Lowdown::Notification.new(token: token.gsub(/[< >]/, ''), payload: { alert: alert, badge: badge, sound: sound })
        notification.payload["category"] = category if category
        notification.expiration = expiry if expiry
        notification.id = id if id
        notification.priority = priority if priority
        notification.payload["content-available"] = 1 if content_available
        notification
      end

      clients.each do |client|
        client.connect do |group|
          notifications.each do |notification|
            group.send_notification(notification) do |response|
              p response
            end
          end
        end
      end

      status 204
    rescue => error
      status 500

      {error: error}.to_json
    end
  end

  private

  
  def cert
    @cert ||= begin
      return nil unless apn_certificate and ::File.exist?(apn_certificate)
      File.read(apn_certificate)
    end
  end

  def clients
    @clients ||= begin
      envs = apn_environment.split
      [
        envs.include?('production') ? client_production : nil,
        envs.include?('development') ? client_development : nil,
      ].compact
    rescue
      return nil
    end
  end

  def client_development
    Lowdown::Client.production(false, certificate: cert)
  end

  def client_production
    Lowdown::Client.production(true, certificate: cert)
  end
end
