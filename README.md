# A vast and useful collection of Pi-Hole block lists

Here I publish a big collection of Pi-Hole blocklists, including a blocklist disallowing well known
Microsoft(tm) Windows(R) Telemetry hosts, as documented by BSI Bund in Germany in their project "SiSyPHuS Win10".
The BSI is the "German Federal Bureau of Security in Information Technology" (in German: Bundesamt für Sicherheit in der Informationstechnik).

Thanks to:  
- [BSI Bund](https://www.bsi.bund.de/)  
- [Karsten Neß, principal author of "The Privacy Handbook"](https://www.privacy-handbuch.de/autoren.htm)  


You might want to refer to these documents published by the BSI:

[Analysis of Telemetry component in Windows 10, V1.2](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Analyse_Telemetriekomponente_1_2.html)

[Telemetry end-points in Windows 10 Build 1809](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Telemetrie-Endpunkte_Windows10_Build_1809.html)

[Telemetry end-points in Windows 10 Build 21H2](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/Telemetrie-Endpunkte_Windows10_Build_Build_21H2.html)

[Deactivation of the Telemetry component in Windows 10 Build 21H2 V1.0](https://www.bsi.bund.de/SharedDocs/Downloads/DE/BSI/Cyber-Sicherheit/SiSyPHus/E20172000_BSI_Win10_AFUNKT_TELE_DEAKTIVIEREN_v1_0.html)

[Windows 10: BSI offers tool for Telemetry monitoring, July 7, 2022](https://www.bsi.bund.de/DE/Service-Navi/Presse/Alle-Meldungen-News/Meldungen/Tool_Telemetrie-Monitoring_220719.html)


I also added my list of ~100 blocklists that I found on the Interwebs by craft of my Google-Fu.  

Thanks to:  
- [WaLLy3K](https://firebog.net/)  
- [hagezi](https://github.com/hagezi)  
- [sjhgvr](https://oisd.nl/)  
- [ookangzheng](https://github.com/ookangzheng)
- [The Blocklist Project](https://github.com/blocklistproject)
and many others, please see their respective GitHub repos.

I did not include every list I found.  Especially, I decided against censoring certain content like social networks,
crypto, porn or gambling.  I included only such lists of domains which obviously target your privacy (like ads and trackers)
or are outright dangerous for your computer safety, like sites spreading malware, known phishing sites etc.

Furthermore, I included commonly whitelisted domains from the Pi-Hole Discourse page (see at the bottom)
as well as some of my own personal whitelist entries.  This whitelist is far from complete, so some sites
you use might not work.  Please let me know, so that I can include them.  Please post this information
also to the Pi-Hole discourse list.

It should be noted that currently, the import process will completely replace all blacklist and whitelist entries
in your Pi-Hole installation from the files I supply here.  This will probably be improved in a future version.
For progress on this necessary enhancement, see also [Issue #7](https://github.com/pschneider1968/pihole-bl-msft-telemetry-bsi/issues/7)



**Usage:**

    cd /etc/pihole
    git clone https://github.com/pschneider1968/pihole-bl-msft-telemetry-bsi.git
    cd pihole-bl-msft-telemetry-bsi
    sh refresh_all.sh


Install a crontab like this with `crontab -e` to regularly update from my repo at 0:40 AM in the night:

    40 0 * * * /bin/bash /etc/pihole/pihole-bl-msft-telemetry-bsi/refresh_all.sh merge


The big domain blocklist from file `list_of_blocklists.txt` as well as the blacklists and whitelists are
loaded with the supplied scripts.  One of those list entries is a pointer to the file `msft_telemetry_bsi.txt`
here in this GitHub repository, which contains the list of Microsoft hosts involved in Windows telemetry,
as documented by the BSI.

This list will thus be included in the refresh processing when it has changed here in my repo.


The import process can be run in four different modes: ADD, MERGE, DELETE and FULL.
Please call the script import_lists.sh with the parameter HELP to learn more:


    
    $ sh import_lists.sh HELP
    import_lists.sh v0.4  (c) 2022,2023 by Peter Schneider - provided under MIT License
    
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
As of today (Jan 9, 2023) the total number of blocked unique domains from all 101 lists is 
roughly 8.0 million.

You should be aware that importing these lists may take upto 10 minutes or even more, depending on
the hardware on which you Pi-Hole installation is running.  That amount of time is mostly due to the fact
that in the last step of the import process, the Pihole service program counts the number of unique domains
in the gravity table, which causes a lot of I/O in the SQLite3 database and takes a lot of time.
Please be patient and don't interrupt the import process at this step, as this might corrupt the database.
If you are running your Pi-Hole in a VM or container, giving it more resources, e.g. at least 2 vCPU cores
and 512 MiB of RAM during the import process might help speeding things up.

It is a good idea to have this in a cronjob late at night so that it does not matter much how long it takes.


If something does not work, or you suspect false positives, check against the commonly whitelisted domains
at [Pi-Hole Discourse](https://discourse.pi-hole.net/t/commonly-whitelisted-domains/212)


I hope you find this collection of lists and the synchronization scripts useful.  Please let me know if you have
any suggestions for improvement, issues, bug fixes.  Feel free to fork the repo and work on your own copy.
I am open for pull requests of improvements or fixes!

Peter

