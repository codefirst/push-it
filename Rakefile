require 'base64'

task default: :encode

task :encode do
  file = ENV['APN_CERTIFICATE'] || "apple_push_notification.pem"
  puts Base64.encode64(File.read(file)).split.join
end

task :decode do
  puts Base64.decode64(ENV['APN_CERTIFICATE_BASE64'])
end

