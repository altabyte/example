class EmailValidator < ActiveModel::EachValidator
  # validate if an mx exists on domain - overriding to only check when online

  def has_mx?(domain)
    require 'resolv'
    require 'socket'
    begin
      TCPSocket.new 'google.com', 80
      mx = []
      Resolv::DNS.open do |dns|
        mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
      end
      not mx.nil? and mx.size > 0
    rescue SocketError
      true
    end

  end
end
