# Establish Token for subsequent requests during this run
# No arguments needed

require 'base64'
require 'json'
require 'faraday'
require 'base64'

def get_token(server)
 if Options.n then
    sv = []
    sv << Options.n
    un=Options.u
    pw=Options.p
  else
    rh=Creds[server]
    sv = rh['servers']
    un = rh['username']
    pw = rh['password']
  end
  if Options.auth == 'token'
    conn = Faraday.new(:url => 'https://' + sv)
    conn.basic_auth(un, pw)
    conn.ssl.verify = false
    response = conn.post '/api/v1/session'
    if response.status != 200
       msg = JSON.parse(response.body)['message']
       raise "Rubrik - Unable to authenticate (#{msg})"
    else
      token = JSON.parse(response.body)['token']
      return token,sv
    end
  else
    return un,pw,sv
  end
end
