#!/bin/bash
# This is very simple script to "EXPAND AREA OF ATACK" while yout recon fase of subdomains.
# Where you dont have buy apis to increase you results, you can try force get more subdomains by certificates associates to main domain.
# Let me to show how i do this:

#TOOLS: assetfinder, subfinder, findomain, anew, nuclei, httpx

#how to use:
#./ExpandSubdomains.sh domain.com

#first step you need get you subdomains by you prefered tool (assetfinder, subfinder, findomain...)
subfinder -d $1 -silent -o $1_subdomains.txt
#
assetfinder -subs-only $1 >> $1_subdomains.txt
#
findomain -t $1 | egrep -v "A error|Searching|Target|Job finished|Good luck" >> $1_subdomains.txt
#
#after you need send to nuclei use ssl names template
echo "START FIND SSL NAMES ON CERTIFICATES FROM SUBDOMAINS:"
nuclei -l $1_subdomains.txt -t ssl/ssl-dns-names.yaml -o $1_subdomains_ssl.txt 
echo "TOTAL CERTIFICATES FOUND: " 
cat $1_subdomains_ssl.txt | wc -l
#this step i just make regular expression to clear results and save using anew
echo ""
echo "STARTED EXPRESSION REGULAR TO ESTRUCTURE AND CLEAN:"
cat $1_subdomains_ssl.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | anew $1_subdomains_ssl_new.txt 
echo "TOTAL NEWS SUBDOMAINS FOUND: " 
cat $1_subdomains_ssl_new.txt | wc -l
echo ""
echo "STARTED EXPRESSION REGULAR TO REMOVE THE 3RD SUBDOMAINS:"
cat $1_subdomains_ssl_new.txt | grep -v -E "\*\|microsoft.com|cloudflare.com|big-ip.com|f5.com|teams.com|office365.com|microsoft365.com|microsoftonline-p.com|microsoftonline.com|live.com|live.net|office.net|trafficmanager.net|officeppe.net|cloudflare-dns.com|hotmail.com|office.com|microsoft|meet.lync.com|o365.com|outlook.com|officeppe.net|cloudfront|cloudflaressl.com|tls.automattic.com|wordpress.com" | anew $1_subdomains_ssl_cleaned.txt
echo ""
echo "TOTAL SUBDOMAINS CLEAN FOUND: " 
cat $1_subdomains_ssl_cleaned.txt | wc -l
#TODO: list of waf's to remove from results



####
####
#make again RECON OF RECON
echo "START FILTER TO GET 2 AND 3 LEVELS OF TLD SUBDOMAINS: " 
cat $1_subdomains_ssl_cleaned.txt | cut -d "." -f2,3,4 | sort | uniq | grep "\." | anew $1_subdomains_ssl_news_domains.txt
echo ""
echo "TOTAL OF NEWS SUBDOMAINS FOUND: " 
cat $1_subdomains_ssl_news_domains.txt | wc -l
#
echo "START FIND SSL NAMES ON CERTIFICATES FROM SUBDOMAINS AGAIN:"
nuclei -l $1_subdomains_ssl_news_domains.txt -t ssl/ssl-dns-names.yaml -o $1_subdomains_2recon.txt
echo ""
echo "TOTAL CERTIFICATES FOUND: " 
cat $1_subdomains_2recon.txt | wc -l
#this step i just make regular expression to clear results and save using anew
echo "STARTED EXPRESSION REGULAR TO ESTRUCTURE AND CLEAN:"
cat $1_subdomains_2recon.txt | cut -d "[" -f5 | cut -d "]" -f1 | tr ',' '\n' | anew $1_subdomains_ssl_new2.txt 
echo ""
#put first results of first recon into file of second recon
echo "PUT FIRST RESULTS OF SUBDOMAINS IN TO FILE FROM SECOND RESULTS RECON: " 
cat $1_subdomains.txt $1_subdomains_ssl_cleaned.txt | anew $1_subdomains_ssl_new2.txt
#
echo "STARTED EXPRESSION REGULAR TO REMOVE THE 3RD SUBDOMAINS:"
cat $1_subdomains_ssl_new2.txt | grep -v -E "\*\|microsoft.com|cloudflare.com|big-ip.com|f5.com|teams.com|office365.com|microsoft365.com|microsoftonline-p.com|microsoftonline.com|live.com|live.net|office.net|trafficmanager.net|officeppe.net|cloudflare-dns.com|hotmail.com|office.com|microsoft|meet.lync.com|o365.com|outlook.com|officeppe.net|cloudfront|cloudflaressl.com|tls.automattic.com|wordpress.com" | anew $1_subdomains_ssl_cleaned_2recon_2cleaned.txt
echo ""
echo "TOTAL SUBDOMAINS CLEAN FOUND: " 
cat $1_subdomains_ssl_cleaned_2recon_2cleaned.txt | wc -l
#TODO: list of waf's to remove from results
####
####



#Now i check who is online and active using tool httpx
cat $1_subdomains_ssl_cleaned_2recon_2cleaned.txt | httpx -silent | anew $1_sub_domains.txt 

#Here i show results and quantity
cat $1_sub_domains.txt

echo ""
echo "Total initial of subdomains founds before second recon:"
cat $1_subdomains.txt | wc -l
echo ""
echo "Subtotal of subdomains founds after second recon, but, before of clean:"
cat $1_subdomains_ssl_new.txt | wc -l
echo ""
echo "Total subdomains founds after second recon:"
cat $1_sub_domains.txt | wc -l
echo ""
echo "Result save into the file:"
echo $1_sub_domains.txt
echo ""
echo -e "\e[32mkeep hacking, Artefact of software from course RECON OF RECON by @OPenTester\e[0m"

#clear old files
#rm $1_subdomains*
 


#no more...
#keep hacking, by @OPenTester
