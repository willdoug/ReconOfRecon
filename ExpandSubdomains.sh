#!/bin/bash
# This is very simple script to "EXPAND AREA OF ATACK" while yout recon fase of subdomains.
# Where you dont have buy apis to increase you results, you can try force get more subdomains by certificates associates to main domain.
# Let me to show how i do this:

#TOOLS: assetfinder, subfinder, findomain, anew, nuclei, httpx

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
cat $1.subdomains_ssl.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | egrep -v "microsoft.com|cloudflare.com|big-ip.com|f5.com" | anew $1.subdomains_ssl_cleaned.txt
#TODO: list of waf's to remove from results
rm $1.subdomains_ssl.txt


####
####

#make again recon of recon
cat $1.subdomains_ssl_cleaned.txt | cut -d "." -f2,3,4 | sort | uniq | grep "\." | anew $1.subdomains_ssl_news_domains.txt
#
nuclei -l $1.subdomains_ssl_news_domains.txt -t ssl/ssl-dns-names.yaml -o $1.subdomains_2recon.txt
rm $1.subdomains_ssl_news_domains.txt
#
cat $1.subdomains_ssl_cleaned.txt | anew $1.subdomains_2recon.txt
#
#this step i just make regular expression to clear results and save using anew
cat $1.subdomains_2recon.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | egrep -v "microsoft.com|cloudflare.com|big-ip.com|f5.com" | anew $1.subdomains_ssl_cleaned_2recon_2cleaned.txt
#TODO: list of waf's to remove from results
rm $1.subdomains_2recon.txt
#here i just show quantity
cat $1.subdomains_ssl_cleaned_2recon_2cleaned.txt | wc -l


####
####

#Now i check who is online and active using tool httpx
cat $1.subdomains_ssl_cleaned_2recon_2cleaned.txt | httpx -silent | anew $1_subdomains.txt 
rm $1.subdomains_ssl_cleaned_2recon_2cleaned.txt

#Here i show results and quantity
cat $1_subdomains.txt
#here i just show quantity
echo ""
echo "Preview of subdomains founds before clean:"
cat $1.subdomains_ssl_cleaned.txt | wc -l
rm $1.subdomains_ssl_cleaned.txt
echo ""
echo "Total subdomains founds:"
cat $1_subdomains.txt | wc -l
echo ""
echo "Result save into the file:"
echo $1_subdomains.txt

#no more...
#keep hacking, @OPenTester
