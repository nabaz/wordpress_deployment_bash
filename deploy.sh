#!/bin/bash

SVNHOST="URL"
BACKUPDATE=`date +%Y-%m-%d`
#
#
#
# Todo:  move uploads directory to /var/www/{environment}-uploads
#  	 symlink {environment-uploads} to /var/www/releases/RELEASE/wp-content/uploads
#  	 add additional error checking to all commands.
#	 test, test, test, then test once more!
#

export LANG=en_US.UTF-8

if [ -z "$1" ]
	then 
	  echo "Usage:  deploy.sh {environment} {release id}"
	  echo  "Example: deploy.sh ehubut1 20150101_1"
	  exit
	fi

case "$1" in
	deploy)
	echo "We're Deploying ... "       
	 #if [ -z "$3" ]
          #then
           # echo "Please specify importing source is Tag or Branch"
        #exit
        #fi

	if [ -d "/var/www/releases/$2/$3" ] 
	then
	 echo "This release had been deployed already, please delete, or change release number"
	exit
	fi
	#mkdir /var/www/releases/$1/$2/
	if mkdir -p /var/www/releases/$2/$3
	 then echo "the directrory created"
	else
	 exit $?
	fi 
	
	#echo "Importing from SVN started ..."
	# Importing from Brnache
	#$BRANCHES = "branches"
	#$TAGS = "tags"
	#if [ $3 = "branches" ]
	 #then echo "Importing from branches started"
          if svn  export --force https://${SVNHOST}/tags/$3 /var/www/releases/$2/$3
         	then 
		echo "Importing from Branch Ended"
		else 
		exit $?
		fi
	#else	
 	 #   if [ $3 = "tags" ]
         #then "Importing from Tags started"
          #    if svn export --force https://${SVNHOST}/tags/$2 /var/www/releases/$1/$2
          #    then 
	   #     echo "Importing from SVN - Ended ..."
	#	else 
	#	exit $?
	#	fi
 	#else
	 #exit $?
	#fi
	#fi

	# move upload folder to the new release folder
	echo "Moving the Upload Folder to new release..."
	if  /bin/mv -f /var/www/$2/$2-upload /var/www/releases/$2/$3
	 then echo "uploaded folder copied over ..."
	else
	 exit $?
	fi
	
	# remove symlink pointing to last release
	# but 1st lets backup the old webroot

	#if /bin/tar -cvzf $1-$BACKUPDATE.tar.gz --exclude="$1-$BACKUPDATE.tar.gz" --exclude="/var/www/$1/$1-upload/*" --exclude="/var/www/$1/wp-content/*" /var/www/$1
	 #then echo "backup completed"
	#else
	 #exit $?
	#fi
	
	# remove symlink pointing to last release
	
	sudo /bin/rm /var/www/$2 
	sudo /bin/ln -s /var/www/releases/$2/$3 /var/www/$2
        #if /bin/cp -rf /var/www/releases/$1/$2/* /var/www/$1
	 #then echo "files moved to the environmet $1"
	#else
	 #exit $?
	#fi
	echo "Restoring wp-config for $2 "
	if /bin/cp -f /var/www/wp_configs/$2/wp-config.php /var/www/releases/$2/$3/	
	#ln -s  	
	 then echo "deployment ended successfully .."
	else
	 exit $?
	fi
	# Lets try to restart apache gracefuly so we don't interrupt any process now.
 	sudo /sbin/service httpd graceful
	# LETS try to restart varnish also (this is important for live site especially TheHive)
	#/bin/service varnish restart

	;;
	rollback)
	echo "we're rolling back"
	now="$(date +'%d-%m-%Y')"
	# move upload folder to the new release folder
        #if  /bin/mv -f /var/www/releases/$2/$3 /var/www/releases/$2/$3_bk_1_$now
	 #then echo "backed up current release $3"
	#else
	 #exit $?
	#fi
	echo "Moving the Upload Folder to new release..."
        if  /bin/mv -f /var/www/releases/$2/$3/$2-upload /var/www/releases/$2/$4/
         then echo "uploaded folder copied over ..."
        else
         exit $?
        fi
	if [ ! -d "/var/www/releases/$2/$4" ]
	then
	 echo "This rollback release is not exist, please check release number"
	exit
	fi	
	sudo /bin/rm /var/www/$2
        sudo /bin/ln -s /var/www/releases/$2/$4 /var/www/$2
	
 	echo "Restoring wp-config for $2 "
        if /bin/cp -f /var/www/wp_configs/$2/wp-config.php /var/www/releases/$2/$4/
        #ln -s          
         then echo "deployment ended successfully .."
        else
         exit $?
        fi
        # Lets try to restart apache gracefuly so we don't interrupt any process now.
        sudo /sbin/service httpd graceful
        # LETS try to restart varnish also (this is important for live site especially)
        #/bin/service varnish restart

	;;
	esac
	exit
fi
