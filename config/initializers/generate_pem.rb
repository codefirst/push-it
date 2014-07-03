require 'base64'

if ENV['APN_CERTIFICATE_BASE64']
  pem_path = File.dirname(__FILE__) + "/../../tmp/apple_push_notification.pem"
  puts "Generating #{pem_path}"
  content = Base64.decode64(ENV['APN_CERTIFICATE_BASE64'])
  File.write(pem_path, content)
  ENV['APN_CERTIFICATE'] = pem_path
end
