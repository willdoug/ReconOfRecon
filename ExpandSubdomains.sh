#!/bin/bash
# This is very simple script to expand area of atack while yout recon fase of subdomains.
# Where you dont have buy apis to increase you results, you can try force get more subdomains by certificates associates to main domain.
# Let me to show how i do this:
#how to use:
#./ExpandSubdomains.sh domain.com

#first step you need get you subdomains by tool prefered (assetfinder, subfinder, findomain...)
subfinder -d $1 -silent -o $1.subdomains.txt
#
assetfinder -subs-only $1 | anew $1.subdomains.txt
#
findomain -t $1 | egrep -v "A error|Searching|Target|Job finished|Good luck" | anew $1.subdomains.txt

#after yout need send to nuclei use ssl names template
nuclei -l $1.subdomains.txt -t ssl/ssl-dns-names.yaml -o $1.subdomains_ssl.txt 
rm $1.subdomains.txt

#this step i just make regular expression to clear results and save using anew
cat $1.subdomains_ssl.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | egrep -v "microsoft.com" | anew $1.subdomains_ssl_cleaned.txt
rm $1.subdomains_ssl.txt

#here i just show quantity
cat $1.subdomains_ssl_cleaned.txt | wc -l

####
####

#make again recon of recon
nuclei -l $1.subdomains_ssl_cleaned.txt -t ssl/ssl-dns-names.yaml -o $1.subdomains_ssl_cleaned_2recon.txt
rm $1.subdomains_ssl_cleaned.txt
#this step i just make regular expression to clear results and save using anew
cat $1.subdomains_ssl_cleaned_2recon.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | egrep -v "microsoft.com" | anew $1.subdomains_ssl_cleaned_2recon_2cleaned.txt
rm $1.subdomains_ssl_cleaned_2recon.txt
#here i just show quantity
cat $1.subdomains_ssl_cleaned_2recon_2cleaned.txt | wc -l


####
####

#Now i check who is online and active using tool httpx
cat $1.subdomains_ssl_cleaned_2recon_2cleaned.txt | httpx -silent | anew $1.subdomains_ssl_cleaned_2recon_2cleaned_httpx200.txt 
rm $1.subdomains_ssl_cleaned_2recon_2cleaned.txt

#Here i show results and quantity
cat $1.subdomains_ssl_cleaned_2recon_2cleaned_httpx200.txt
ehco ""
echo "Total subdomains founds:"
cat $1.subdomains_ssl_cleaned_2recon_2cleaned_httpx200.txt | wc -l
echo ""
echo "Result save into the file:"
echo $1.subdomains_ssl_cleaned_2recon_2cleaned_httpx200.txt

#no more...
#keep hacking, @OPenTester
