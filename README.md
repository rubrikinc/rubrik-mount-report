# rubrik_mount_report

# Overview
* Rubrik Script to report on Live Mount recoveries between two dates

# Dependencies
* Ruby 2.4.x or greater
* Faraday Gem

# How to Use
```
.creds - JSON formatted configuration (or resort to including credentials in command line execution)

        {
                "rubrik": {
                        "servers":["ip","ip",...],
                        "username": "[username]",
                        "password": "[password]"
                }
        }

Usage: report_live_mounts.rb [options]

Specific options:
    -l, --login                      Perform no operations but test Rubrik Connectivity

Report options:
    -f, --from [string]              Start Date (MM-DD-YYYY)
    -t, --to [string]                End Date (MM-DD-YYYY)

Common options:
    -n, --node [Address]             Rubrik Cluster Address/FQDN
    -u, --username [username]        Rubrik Cluster Username
    -p, --password [password]        Rubrik Cluster Password
    -h, --help                       Show this message
```

# Example:
```
Command -  ruby .\rubrik_mount_report.rb -f 01-01-2018 -t 02-01-2018

Output - 

Getting report data from Rubrik
Page 1
Page 2
Page 3
Page 4
Page 5
Page 6
Page 7
Page 8
Page 9
Page 10
Page 11
Page 12
Page 13
Page 14
Page 15
Page 16
Page 17
Report was saved as 01-01-2018-to-02-01-2018
```

# Result File Excerpt

```
Mount Time, Object Name, Message
Wed Jan 31 23:02:24 UTC 2018,SE-KCARLSON-WIN,Mounted vSphere VM 'SE-KCARLSON-WIN 01-27 23:10 0'
Wed Jan 31 22:42:44 UTC 2018,SE-ALEWIS-LINUX,Mounted vSphere VM 'SE-ALEWIS-LINUX 01-31 04:14 0'
Wed Jan 31 21:49:59 UTC 2018,SE-JMCNEIL-WIN,Mounted vSphere VM 'SE-JMCNEIL-WIN 01-31 18:59 0'
Wed Jan 31 21:43:53 UTC 2018,SE-RMATTHEW-WIN,Mounted vSphere VM 'SE-RMATTHEW-WIN 01-30 19:37 0'
Wed Jan 31 21:16:38 UTC 2018,SE-CCARLTON-LINUX,Mounted vSphere VM 'SE-CCARLTON-LINUX 01-30 08:28 0'
Wed Jan 31 20:45:37 UTC 2018,SE-RFELIX-LINUX,Mounted vSphere VM 'SE-RFELIX-LINUX 01-29 00:17 0'
Wed Jan 31 20:28:09 UTC 2018,SE-DLANDO-LINUX,Mounted vSphere VM 'SE-DLANDO-LINUX 01-02 23:51 1'
Wed Jan 31 20:25:30 UTC 2018,SE-LSTEVENS-WIN,Mounted vSphere VM 'SE-LSTEVENS-WIN 01-24 21:42 0'
```
