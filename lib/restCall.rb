require 'net/https'
require 'getToken.rb'

def restCall(server,endpoint,l,type)
  begin
    endpoint = URI.encode(endpoint)
    if Options.auth == 'token'
      (t,sv) = get_token(server)
      conn = Faraday.new(:url => 'https://' + sv.sample(1)[0], request: {
        open_timeout: 5,   # opening a connection
        timeout: 360         # waiting for response
        })
      conn.authorization :Bearer, t
    else
      (u,pw,sv) = get_token(server)
      conn = Faraday.new(:url => 'https://' + sv.sample(1)[0], request: {
        open_timeout: 5,   # opening a connection
        timeout: 360         # waiting for response
        })
      conn.basic_auth u, pw
      conn.headers['Authorization']
    end
    conn.ssl.verify = false
    response = conn.public_send(type) do |req|
      req.url endpoint
#      req.options.timeout = 0
      req.headers['Content-Type'] = 'application/json'
      req.body  = l.to_json
    end
    if response.status !~ /202|200/
      begin
        return JSON.parse(response.body)
      rescue 
        return "Empty Response"
      end
    end
  rescue Faraday::ConnectionFailed
    @error = "There was a timeout. Please try again."
  end

end
