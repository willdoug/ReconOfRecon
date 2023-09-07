#!/bin/bash
# This is very simple script to expand area of atack while yout recon fase of subdomains.
# Where you dont have buy apis to increase you results, you can try force get more subdomains by certificates associates to main domain.
# Let me to show how i do this:

#firs step you need get you subdomains by tool prefered (assetfinder, subfinder, findomain...)
#after yout need send to nuclei use ssl names template
nuclei -l subdomains.txt -t ssl/ssl-dns-names.yaml -o subdomains_ssl.txt 

#this step i just make regular expression to clear results and save using anew
cat subdomains_ssl.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | anew subdomains_ssl_cleaned.txt

#here i just show quantity
cat subdomains_ssl_cleaned.txt | wc -l

#Now i check who is online and active using tool httpx
cat subdomains_ssl_cleaned.txt | httpx -silent | anew subdomains_ssl_cleaned_httpx200.txt 

#Here i show results and quantity
cat subdomains_ssl_cleaned_httpx200.txt
echo "Total subdomains founds:"
cat subdomains_ssl_cleaned_httpx200.txt | wc -l

#no more...
#keep hacking, OPenTester
