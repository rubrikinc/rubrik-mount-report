$LOAD_PATH.unshift File.expand_path('../lib/', __FILE__)
require 'parseoptions.rb'
require 'pp'
require 'getCreds.rb'
require 'restCall.rb'
require 'json'
require 'uri'

# Global options
Options = ParseOptions.parse(ARGV)
Creds = getCreds();

class DateTime
  def to_time
    Time.local( *strftime( "%Y-%m-%d %H:%M:%S" ).split )
  end
end

class Hash
   def Hash.nest
     Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
   end
end

if Options.login then
  pp restCall("rubrik","/api/v1/cluster/me",'','get') 
  exit()
end

if !Options.from_date || !Options.to_date 
  print "Message: --from and --to must be specified"
  exit()
end

dataset = Array.new
last = false
done = false
page=0
puts "Getting report data from Rubrik"
from_date=URI::encode(Options.from_date.gsub(/\-/,'/'))
to_date=URI::encode(Options.to_date.gsub(/\-/,'/'))
until done
  if last
    page += 1
    go="after_id=#{last}"
    call = "/api/internal/event?limit=100&object_type=VmwareVm&event_type=Recovery&before_date=#{to_date}&after_date=#{from_date}&#{go}"
    puts "Page #{page}"
  else
    page += 1
    call = "/api/internal/event?limit=100&object_type=VmwareVm&event_type=Recovery&before_date=#{to_date}&after_date=#{from_date}"
    puts "Page #{page}"
  end
  o=restCall('rubrik',call,'','get')
  o['data'].each do |l|
  #  if l['eventInfo'].include? "Mounted" 
      dataset << l
      last = l['id']
  #  end
  end
  if o['hasMore'] == false
    done=1
  end
end

header="Mount Time, Object Name, Message"
reportname = Options.from_date + "-to-" + Options.to_date
IO.write(reportname + ".csv",header + "\n") 
dataset.each do |d|
  line = (d['time'] +","+d['objectName']+","+JSON.parse(d['eventInfo'])['message'])
  IO.write(reportname + ".csv",line + "\n",mode: 'a') 
end
pp "Report was saved as " + reportname + ".csv"
