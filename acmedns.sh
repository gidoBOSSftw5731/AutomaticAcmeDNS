#!/bin/bash


#If you want your zone files for the ACME subdomain (see README) to be somewhere else, make sure
#you declare that here. This is the standard path for bind9, hence why it is the default.
export dir=/var/cache/bind/


#You HAVE TO change these to fit your file paths and domains
case $CERTBOT_DOMAIN in
	#This is the domain you want to verify, you must add one entry PER DOMAIN
	#Even if multiple domains share one SSL cert.
	#The switch statement (standard bash syntax for a switch/case statement) should contain as many case
	#statements as there are domains that are being verified by this script.
	"example.clickable.systems")
		#This is the zone file that your master bind9 zone file points to (see README)
		#it can be anything, but I reccomend making it make sense. It is also standard
		#for zone files to start with "db." however that is just a convention and is not
		#required. My personal naming convention for these acme files is "db.acme.(nickname for domain)"
		#so it is easy for me to tell where they are. The master zone file in my config is "db.acme" so
		#anyone looking in that directory can understand that these files are below the master zone file.
		export file=db.acme.example
		
		#This zone is the name/nickname of the domain. It can be anything, but it has to match the
		#subdomain that is configured as the CNAME to the alias which is located at
		#_acme-challenge.$DOMAIN (which would be _acme-challenge.example.clickable.systems in this example)
		#The difference between the Canonical Name (CNAME) and alias/label is clarified in
		#RFC2181 page 11 section 10.1.1.
		export zone=example
	;;
	*)
	#if this is ever run, it means certbot tried to verify a domain that was not in this case statement.
	#It should fail out and certbot should not continue, but configuring this in the first place isn't so
	#hard, is it?
		exit 1
	;;
esac

#This is how it updates the zone file, it completely overwrites it as adding smarts to pick the correct
#line in bash was more effort than I felt like putting in.
echo "$zone	IN	TXT	$CERTBOT_VALIDATION" > $dir$file
#Reload BIND9 to read the new config. This is preferable to reloading the entire service as 1. it
#communicates directly to the daemon, 2. can be run as a non-root user to increase security (assuming
#the user is in the bind group and has write access to the zone files which also have to be accessible to
#the bind user.
rndc reload
