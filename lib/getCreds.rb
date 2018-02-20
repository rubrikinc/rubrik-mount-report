# Simple Parser for Credential File, normally ~/.rubrik/creds.json
# Format of creds.json :
# {
#        "server": "[cluster_address]",
#        "username": "[username]",
#        "password": "[password]"
#}
# Most routines will accept login info as arguments (arg1 arg2 node username password)
require 'json'
def getCreds
	begin
		return JSON.parse(File.read('.creds'))
	rescue StandardError=>e
		return e
	end
end
