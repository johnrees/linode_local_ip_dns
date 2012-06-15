# Linode Local IP DNS
### Awful name. A genuinely useful tool...

I built this out of frustration with testing on various devices and from different networks. When testing on mobiles etc, my development website runs on 127.0.0.1/0.0.0.0/localhost and then navigate to 192.168.0.1 (or whatever my development machine's IP was) from my various devices.

However, whenever I changed network I would be assigned a different DHCP IP so I'd have to use a different IP address each time.

This attempts to simplify the process by grabbing your Local IP and then creating or updating a Linode subdomain to point to it. If you save it as a Rails initializer it will then update the subdomain whenever you start up your server, or if you are like me, restart pow.

### Notes

If you do use [pow](http://pow.cx) you can run `website` on 0.0.0.0 as well as website.dev by copying the ~/.pow/website to ~/.pow/default
