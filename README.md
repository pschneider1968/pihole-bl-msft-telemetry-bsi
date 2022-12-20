# pihole-bl-msft-telemetry-bsi
Pi-Hole blocklist for hosts involved in Microsoft Windows telemetry, as documented by BSI Bund in Germany.

Thanks to:  
- [BSI Bund](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Telemetrie-Endpunkte_Windows10_Build_Build_21H2.html)  
- [Karsten Neß](https://www.privacy-handbuch.de/autoren.htm)  


I also added my list of 68 blocklists that I found on the Interwebs by craft of my Google-Fu.  

Thanks to:  
- [WaLLy3K](https://firebog.net/)  
- [hagezi](https://github.com/hagezi)  
- [sjhgvr](https://oisd.nl/)  


Usage:  

    cd /etc/pihole
    git clone https://github.com/pschneider1968/pihole-bl-msft-telemetry-bsi.git
    cd pihole-bl-msft-telemetry-bsi
    sh refresh_all.sh

Install a crontab like this with crontab -e

    40 0 * * * sh /etc/pihole/pihole-bl-msft-telemetry-bsi/refresh_all.sh


**TODO**

Currently, there is no way of importing the ad lists programmatically via CLI. So unfortunately, you have to add the contents of the
file `list_of_blocklists.txt` manually using the web interface. **Sorry!**  


I will try to check for updates and new lists on a regular basis, but I can't promise anything.
As of today (Dec 16, 2022) the total number of blocked unique domains from all these lists is 6121357.

If something does not work, or you suspect false positives, check against the commonly whitelisted domains at [Pi-Hole Discourse](https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212)  

Hope this helps...  
Peter
