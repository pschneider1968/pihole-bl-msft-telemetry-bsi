# PIHOLE-BL-MSFT-TELEMETRY-BSI

Pi-Hole blocklist for hosts involved in Microsoft Windows telemetry, as documented by BSI Bund in Germany.

Thanks to:  
- [BSI Bund](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Telemetrie-Endpunkte_Windows10_Build_Build_21H2.html)  
- [Karsten Neß](https://www.privacy-handbuch.de/autoren.htm)  


I also added my list of 68 blocklists that I found on the Interwebs by craft of my Google-Fu.  

Thanks to:  
- [WaLLy3K](https://firebog.net/)  
- [hagezi](https://github.com/hagezi)  
- [sjhgvr](https://oisd.nl/)  



**Usage:**

    cd /etc/pihole
    git clone https://github.com/pschneider1968/pihole-bl-msft-telemetry-bsi.git
    cd pihole-bl-msft-telemetry-bsi
    sh refresh_all.sh


Install a crontab like this with `crontab -e`:

    40 0 * * * sh /etc/pihole/pihole-bl-msft-telemetry-bsi/refresh_all.sh merge


The big domain blocklist from file `list_of_blocklists.txt` as well as the blacklists and whitelists are
loaded with the supplied scripts.  One of those list entries is a pointer to the file `msft_telemetry_bsi.txt`
here in this GitHub repository, which contains the list of Microsoft hosts involved in Windows telemetry,
as documented by the German Federal Bureau of Security in Information Technology (BSI, Bundesamt für Sicherheit
in der Informationstechnik) in their project "SiSyPHuS Win10".

This list will thus be included in the refresh processing when it has changed here in my repo.


You might want to refer to these documents published by the BSI:

https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Analyse_Telemetriekomponente_1_2.html
https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Telemetrie-Endpunkte_Windows10_Build_1809.html
https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Telemetrie-Endpunkte_Windows10_Build_Build_21H2.html
https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/E20172000_BSI_Win10_AFUNKT_TELE_DEAKTIVIEREN_v1_0.html
https://www.bsi.bund.de/DE/Service-Navi/Presse/Alle-Meldungen-News/Meldungen/Tool_Telemetrie-Monitoring_220719.html


The import process can be run in four different modes: ADD, MERGE, DELETE and FULL.
Please call the script import_lists.sh with the parameter HELP to learn more:


    
    $ sh import_lists.sh HELP
    import_lists.sh v0.2 (c) 2022 Peter Schneider, provided under MIT License
    
    Synopsis: import_lists.sh [MODE]
    
    This script will import the contents of the supplied file "list_of_blocklists.txt" into your
    Pi-Hole Gravity DB, where MODE may be one of:
    
    - HELP:    Display this help info

    - ADD:     Only add new lists, don't do anything to existing lists.  This is the recommended mode
               of operation when you have other sources for your block lists, too, other than my repo.
               It is also the default when no MODE is specified.

    - MERGE:   Add new lists, disable missing ones, re-enable disabled existing lists if they are in the
               import file.  This retains group assignments on existing list entries.  This is the recommended
               mode of operation when my repo is the ONLY source of block lists for your Pi-Hole installation.

    - DELETE:  Add new lists, delete missing ones, re-enable disabled existing lists if they are in the
               import file.  Group assignments on deleted groups are of course lost, and they cannot
               just be re-enabled again, but will be newly imported when they happen to be in the
               next version of the import file again.

    - FULL:    Fully replace all existing list entries in Gravity DB with the imported ones.
               Group assignments are thus lost.  That means that before inserting anything from the
               import file, everything is deleted in the Gravity DB.
    
    

I will try to check for updates and new lists on a regular basis, but I can't promise anything.
As of today (Dec 22, 2022) the total number of blocked unique domains from all these lists is 6775012.

If something does not work, or you suspect false positives, check against the commonly whitelisted domains at [Pi-Hole Discourse](https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212)  

Hope this helps...  
Peter
