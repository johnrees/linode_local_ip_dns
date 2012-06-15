#!/usr/bin/env ruby

# http://github.com/johnrees/linode_local_ip_dns

##-----
# Usage:
##-----

# Set the Parameters below.
# KEY will be the subdomain e.g. 'local' would result in 'local.mydomain.com'

# Required Parameters
LINODE_API_KEY = 'XXXXXXXXXXXX' # https://manager.linode.com/profile/index#apikey
DOMAIN = 'mydomain.com'

# Optional Parameters
KEY = 'local'
RECORD_TYPE = 'a' # could be cname
TTL = 300
DEBUG = true


##-----
## Now start the ugly code party!
##-----


def log msg
  if DEBUG
    begin
      Rails.logger.info msg
    rescue
      p msg
    end
  end
end

if (defined? Rails and Rails.env.development?) || (!defined? Rails)

  require 'json'
  require 'open-uri'
  require 'socket'

  url = "https://api.linode.com/?api_key=#{LINODE_API_KEY}"
  IP = UDPSocket.open {|s| s.connect('64.233.187.99', 1); s.addr.last }

  raise 'Local IP not found' unless defined? IP

  domains_list_url = "#{url}&api_action=domain.list"
  p "Getting Domains List - #{domains_list_url}"
  result = JSON.parse(open(domains_list_url).read)
  result['DATA'].each do |domain|
    if domain['DOMAIN'] == DOMAIN
      log 'Found Domain'
      DOMAINID = domain['DOMAINID']
    end
  end

  raise "'#{DOMAIN}' not found in your domains list - https://manager.linode.com/dns" unless defined? DOMAINID

  resources_list_url = "#{url}&api_action=domain.resource.list&DomainID=#{DOMAINID}"
  log "Getting Resources List - #{resources_list_url}"
  result = JSON.parse(open(resources_list_url).read)
  result['DATA'].each do |resource|
    if resource['NAME'] == KEY
      log 'Found Resource'
      RESOURCEID = resource['RESOURCEID']
    end
  end

  if defined? RESOURCEID

    update_resource_url = "#{url}&api_action=domain.resource.update&DomainID=#{DOMAINID}&ResourceID=#{RESOURCEID}&Target=#{IP}&TTL_sec=#{TTL}"
    log "Updating #{KEY}.#{DOMAIN} to point to #{IP}"
    result = JSON.parse(open(update_resource_url).read)
    if result['ERRORARRAY'].empty?
      log "Updated Resource, please allow up to #{15 + TTL/60} minutes for changes to take effect"
    end

  else

    create_resource_url = "#{url}&api_action=domain.resource.create&DomainID=#{DOMAINID}&Target=#{IP}&Type=a&Name=#{KEY}&TTL_sec=#{TTL}"
    log "Creating #{KEY}.#{DOMAIN}, to point to #{IP}"
    result = JSON.parse(open(create_resource_url).read)
    if result['ERRORARRAY'].empty?
      log "Created Resource, please allow up to #{15 + TTL/60} minutes for changes to take effect"
    end
  end

end
