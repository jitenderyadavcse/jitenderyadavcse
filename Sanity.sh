[monitoring@N2VL-PA-AMIA01 sanity]$ cat Mobility_hourly_report.sh
#!/bin/bash


#. ~/.profile
. ~/.bashrc
set -vx
cd /home/monitoring/sanity
wd="/home/monitoring/sanity"

count=`ps -ef |grep Mobility_hourly_report.sh |grep -v grep|wc -l`
if [ $count -gt 2 ]
then
echo "Previous run still in progress, Exiting"
exit
fi

rm *.tux_service
rm -rf $wd/Sanity.html ngr_result.txt
rm -rf server*
touch $wd/Sanity.html
rm $wd/clone1 $wd/http1 check ;
rm $wd/BT_check $wd/BT_http1 $wd/BT_clone1 $wd/BT_ds1  $wd/BT_ls1  $wd/BT_as1
rm $wd/BT_service1
rm $wd/service1_*

echo "From:Sanity_Alerts@airtel.com"  >> $wd/Sanity.html
#echo "To:GiTechIndiaAirtelMiddleware@amdocs.com;GSSiTechnologiesAmdocs_ButterflyMW@amdocs.com" >> $wd/Sanity.html
echo "To:GiTechIndiaAirtelMiddleware@amdocs.com" >> $wd/Sanity.html
echo "Mime-Version:1.0;" >> $wd/Sanity.html
echo "Content-Type:text/html;"            >> $wd/Sanity.html
echo "Subject:MIDDLEWARE SANITY REPORT `date +%F`  "  >> $wd/Sanity.html

echo "
<HTML>

<HEAD>
<TITLE > APPLICATION SANITY REPORT </TITLE>
<META http-equiv=Content-Type content=\"text/html; charset=iso-8859-1\">
<META content=\"MSHTML 6.00.2300.3059\" name=GENERATOR>
<STYLE type=TEXT/CSS>
<!--BODY { font-family: Tahoma; font-size:9pt} TABLE { background-color:#F3B2AA  } SPAN { font-family: Tahoma; font-size:9pt}   TD  { font-family: Tahoma; font-size:9pt; padding: 2}   TH {
 background-color:#cccc99;           color:#336699;           font-family: Tahoma;           font- weight:bold; padding: 2;           font-size: 11pt; }   TR { background-color:#f9f9ef;}
BR {font-size: 4pt}-->
</STYLE>

</HEAD>

<body>
<h5>Date - <i>`date +\"%d-%b-%Y %X\"`  </i></h5>

" >> $wd/Sanity.html

echo "<table align=center border=0 width=\"100%\"  background-color: #F3B2AA  >"  >> $wd/Sanity.html
echo "<tr style=\"background-color:  #F3B2AA\">"  >> $wd/Sanity.html
echo "<td>"  >> $wd/Sanity.html


echo "<table align=center border=0 width=\"100%\" background-color: #F3B2AA     >"  >> $wd/Sanity.html
echo "<tr><td>"  >> $wd/Sanity.html
echo "</br>"   >> $wd/Sanity.html




echo "<H3 align="center"> WAS APPLICATION SANITY REPORT </H3> "  >> $wd/Sanity.html
echo "<table align=center border=1>" >> $wd/Sanity.html
echo "<th>Application</th><th>FS Utilization</th><th>HTTP Status</th><th>CLONES Status</th><th>Data Source</th><th>Listener Status</th><th>Cron Status</th>" >> $wd/Sanity.html


for i in `cat app_list`
do



echo "<tr>" >> $wd/Sanity.html
echo "<td>$i</td>" >> $wd/Sanity.html



####################### FS ################

grep -i $i FS_LIST.txt > server_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./fs_check  $server $description $user1 $i  >> jjk


grep -i "utilization_is_high" jjk
cv=`echo $?`
if [ $cv -eq 0 ];then
  while read x
  do
    echo " $x " >> jk
  done < jjk
fi
grep -i "ssh failed" jjk

cv1=`echo $?`
if [ $cv1 -eq 0 ];then
echo " ** SSH failed  on $server " >> jk
echo " ** SSH failed  on $server " >> jfailed
fi

rm jjk

done < /home/monitoring/sanity/server_$i

################################################







########################## HTTP ###################

grep -i $i http_server > server_http_$i


while read line1
do


lob=`echo $line1 | cut -d" " -f1`
description=`echo $line1 | cut -d" " -f2`

server=`echo $description | cut -d"@" -f2`


./http_check  $server $description $i  >> hk

done < /home/monitoring/sanity/server_http_$i



####################################





####################### clones monitor ################
getusername()
{
lob=`grep -i $i config_pass`

split=`echo $lob|awk -F'"' '{print $2}'`


user=`echo $split|awk -F',' '{print $1}'`

pass=`echo $split|awk -F',' '{print $2}'`

echo $user $pass


}

getusername;

grep -i $i Clone_List.txt > server_clones_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./clones_check  $server $description $user1 $user $pass $i   >> ck

done < /home/monitoring/sanity/server_clones_$i


################################################



####################### DS monitor ################
getusername()
{
lob=`grep -i $i config_pass`

split=`echo $lob|awk -F'"' '{print $2}'`


user=`echo $split|awk -F',' '{print $1}'`

pass=`echo $split|awk -F',' '{print $2}'`

echo $user $pass


}


getusername;

grep -i $i DS_LIST.txt > server_clones_ds_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./ds_check  $server $description $user1 $user $pass $i   >> ds

done < /home/monitoring/sanity/server_clones_ds_$i

################################################

####################### Listener ################

grep -i $i LS_LIST.txt > server_ls_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`


./listener_check  $server $description $user1 $user $pass $i  >> ls

done < /home/monitoring/sanity/server_ls_$i

################################################

####################### CRONTAB monitor ################
getusername()
{
lob=`grep -i $i config_pass`

split=`echo $lob|awk -F'"' '{print $2}'`


user=`echo $split|awk -F',' '{print $1}'`

pass=`echo $split|awk -F',' '{print $2}'`

echo $user $pass


}


getusername;

grep -i $i Clone_List.txt > server_cron_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./cron_check  $server $description $user1 $user $pass $i   >> crk

done < /home/monitoring/sanity/server_cron_$i

################################################




res=`echo $description | cut -d"_" -f1,2`

if [  -s server_$i ];then

  if [ -s jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else

      if [ -s jk  ];then



     echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
     else

     echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
     fi
   fi

else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi


if [  -s server_http_$i ];then

  if [ -s jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s hk  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi

else

echo "<td style=color:black;background-color:#E6EEA7;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi



if [  -s server_clones_$i ];then
  if [ -s jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s ck  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi



if [  -s server_clones_ds_$i ];then
  if [ -s jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s ds  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi

if [  -s server_ls_$i ];then
  if [ -s jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
      if [ -s ls  ];then



     echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
     else

     echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
     fi
  fi
else

echo "<td style=color:black;background-color:#E6EEA7;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi


if [  -s server_cron_$i ];then
  if [ -s jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s crk  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi

echo "</tr>"  >> $wd/Sanity.html




cat /home/monitoring/sanity/jk >> check
rm /home/monitoring/sanity/jk
rm /home/monitoring/sanity/jfailed

cat /home/monitoring/sanity/hk >> $wd/http1
rm /home/monitoring/sanity/hk

cat /home/monitoring/sanity/ck >> $wd/clone1
rm /home/monitoring/sanity/ck

cat /home/monitoring/sanity/ds >> ds1
rm /home/monitoring/sanity/ds


cat /home/monitoring/sanity/ls >> ls1
rm /home/monitoring/sanity/ls



cat /home/monitoring/sanity/crk >> crk1
rm /home/monitoring/sanity/crk



done



echo "</table>" >> $wd/Sanity.html
echo "</br>" >> $wd/Sanity.html

##########################################################################################

echo "<h3 align=\"center\">WAS TUX REPORT</h3>" >>  $wd/Sanity.html

echo "<table align=\"center\" border=\"1\">" >> $wd/Sanity.html
echo "<th>Application</th><th>FS Utilization</th><th>TUX Queue</th><th>TUX Services</th>" >> $wd/Sanity.html


for i in `cat tux_app_list`
do
echo "<tr>" >> $wd/Sanity.html
echo "<td>$i</td>" >> $wd/Sanity.html

####################### FS ################

grep $i FS_LIST.txt > server_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./fs_check  $server $description $user1 $i  >> jk_tux

grep -i "utilization_is_high" jk_tux
cv=`echo $?`
if [ $cv -eq 0 ];then
  while read x
  do
    echo " $x " >> legacy_tux
  done < jk_tux
fi

grep -i "ssh failed" jk_tux

cv1=`echo $?`
if [ $cv1 -eq 0 ];then
echo " ** SSH failed  on $server " >> legacy_tux
echo " ** SSH failed  on $server " >> legacy_jfailed
fi

rm jk_tux




done < /home/monitoring/sanity/server_$i

################################################



########################## TUX QUEUE Monitor  ###################

grep $i TUX_LIST.txt > server_tux_$i


while read line1
do


lob=`echo $line1 | cut -d" " -f1`
description=`echo $line1 | cut -d" " -f2`

server=`echo $lob | cut -d"@" -f2`


./tux_check  $lob $description   >> tk

done < /home/monitoring/sanity/server_tux_$i



####################################

####################### TUX SERVICES MONITOR #########################

grep $i TUX_LIST.txt > server_tux_s_$i


while read line1
do


lob=`echo $line1 | cut -d" " -f1`
description=`echo $line1 | cut -d" " -f2`

server=`echo $lob | cut -d"@" -f2`


./tux_service  $lob $description $server  >> sk_$i

done < /home/monitoring/sanity/server_tux_s_$i



#####################################################################


if [  -s server_$i ];then

  if [ -s legacy_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
      if [ -s legacy_tux  ];then



     echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
     else

     echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
     fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi






if [  -s server_tux_$i ];then

   if [ -s legacy_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else

   if [ -s tk  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi


if [  -s server_tux_s_$i ];then

   if [ -s legacy_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s sk_$i  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi



echo "</tr>"  >> $wd/Sanity.html

cat /home/monitoring/sanity/legacy_tux >> check_tux
rm /home/monitoring/sanity/legacy_tux
rm /home/monitoring/sanity/legacy_jfailed


cat /home/monitoring/sanity/tk >> tux1
rm /home/monitoring/sanity/tk

cat /home/monitoring/sanity/sk_$i >> service1_$i
rm /home/monitoring/sanity/sk_$i

done


echo "</table>" >> $wd/Sanity.html
echo "</br>" >> $wd/Sanity.html




############################################################################ ButterFLY ####################################################################################


echo "<H3 align="center">BUTTERFLY APPLICATION SANITY REPORT </H3> "  >> $wd/Sanity.html
echo "<table align=center border=1>" >> $wd/Sanity.html
echo "<th>Application</th><th>FS Utilization</th><th>Application Status</th><th>JVM Status</th><th>Data Source</th><th>Thread Monitor</th>" >> $wd/Sanity.html



for i in `cat BT_app_list`
do



echo "<tr>" >> $wd/Sanity.html
echo "<td>$i</td>" >> $wd/Sanity.html



####################### BT_FS ################

grep -i $i BT_FS_LIST.txt > server_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./BT_fs_check  $server $description $user1 $i  >> BT_jk


grep -i "utilization_is_high" BT_jk
cv=`echo $?`
if [ $cv -eq 0 ];then
  while read x
  do
    echo " $x " >> $wd/BT_new
  done < BT_jk
fi
grep -i "ssh failed" BT_jk

cv1=`echo $?`
if [ $cv1 -eq 0 ];then
echo " ** SSH failed  on $server " >>$wd/BT_new
echo " ** SSH failed  on $server " >> BT_jfailed
fi



rm BT_jk

done < /home/monitoring/sanity/server_$i

################################################






####################### BT clones monitor ################
getusername()
{
lob=`grep -i $i BT_config_pass`

split=`echo $lob|awk -F'"' '{print $2}'`


user=`echo $split|awk -F',' '{print $1}'`

pass=`echo $split|awk -F',' '{print $2}'`

echo $user $pass


}


getusername;

grep -i $i BT_Clone_List.txt > server_clones_$i
while read line
do

server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./BT_clones_check  $server $description $user1 $user $pass $i   >> BT_ck

done < /home/monitoring/sanity/server_clones_$i

################################################



####################### DS monitor ################
getusername()
{
lob=`grep -i $i BT_config_pass`

split=`echo $lob|awk -F'"' '{print $2}'`


user=`echo $split|awk -F',' '{print $1}'`

pass=`echo $split|awk -F',' '{print $2}'`

echo $user $pass



}


getusername;

grep -i $i BT_DS_LIST.txt > server_clones_ds_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./BT_ds_check  $server $description $user1 $user $pass $i   >> BT_ds

done < /home/monitoring/sanity/server_clones_ds_$i

################################################

#######################APPS monitor ################
getusername()
{
lob=`grep -i $i BT_config_pass`

split=`echo $lob|awk -F'"' '{print $2}'`


user=`echo $split|awk -F',' '{print $1}'`

pass=`echo $split|awk -F',' '{print $2}'`

echo $user $pass


}



getusername;

grep -i $i BT_AS_LIST.txt > server_clones_as_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./BT_as_check  $server $description $user1 $user $pass $i   >> BT_as

done < /home/monitoring/sanity/server_clones_as_$i

################################################


####################### BT_STUCK_THREAD ################


grep -i $i BT_Clone_List.txt > server_stuck_$i
while read line
do

server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`


user1=`echo $line | cut -d"@" -f1`


./BT_stuck_check  $server $description $user1 $i   >> BT_st

done < /home/monitoring/sanity/server_stuck_$i

################################################









res=`echo $description | cut -d"_" -f1,2`

if [  -s server_$i ];then

  if [ -s BT_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
      if [ -s $wd/BT_new ];then



     echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
     else

     echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
     fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi

if [  -s server_clones_as_$i ];then

  if [ -s BT_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s BT_as  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi




if [  -s server_clones_$i ];then

   if [ -s BT_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s BT_ck  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi


if [  -s server_clones_ds_$i ];then
  if [ -s BT_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s BT_ds  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi

if [  -s server_stuck_$i ];then

  if [ -s BT_jfailed ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s BT_st  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi


echo "</tr>"  >> $wd/Sanity.html




cat /home/monitoring/sanity/BT_new >> $wd/BT_check
rm /home/monitoring/sanity/BT_new
rm /home/monitoring/sanity/BT_jfailed

cat /home/monitoring/sanity/BT_hk >> $wd/BT_http1
rm /home/monitoring/sanity/BT_hk

cat /home/monitoring/sanity/BT_ck >> $wd/BT_clone1
rm /home/monitoring/sanity/BT_ck

cat /home/monitoring/sanity/BT_ds >> $wd/BT_ds1
rm /home/monitoring/sanity/BT_ds


cat /home/monitoring/sanity/BT_ls >> $wd/BT_ls1
rm /home/monitoring/sanity/BT_ls

cat /home/monitoring/sanity/BT_as >> $wd/BT_as1
rm /home/monitoring/sanity/BT_as


cat /home/monitoring/sanity/BT_st >> $wd/BT_st1
rm /home/monitoring/sanity/BT_st


done



echo "</table>" >> $wd/Sanity.html
echo "</br>" >> $wd/Sanity.html

echo "</br>" >> $wd/Sanity.html

#########

#####################################################################BUTTERFLY TUX ##################################################################

##########################################################################################

echo "<h3 align=\"center\">BUTTERFLY TUX REPORT</h3>" >>  $wd/Sanity.html

echo "<table align=\"center\" border=\"1\">" >> $wd/Sanity.html
echo "<th>Application</th><th>FS Utilization</th><th>TUX Queue</th><th>TUX Services</th>" >> $wd/Sanity.html


for i in `cat BT_tux_app_list`
do
echo "<tr>" >> $wd/Sanity.html
echo "<td>$i</td>" >> $wd/Sanity.html

####################### BT FS ################

grep $i BT_FS_LIST.txt > server_$i
while read line
do


server=`echo $line | cut -d" " -f1`
description=`echo $line | cut -d" " -f2`

user1=`echo $line | cut -d"@" -f1`


./BT_fs_check  $server $description $user1 $i  >> BT_jk_tux

grep -i "utilization_is_high" BT_jk_tux
cv=`echo $?`
if [ $cv -eq 0 ];then
  while read x
  do
    echo " $x " >> jkb_tux
  done < BT_jk_tux
fi

grep -i "ssh failed" BT_jk_tux

cv1=`echo $?`
if [ $cv1 -eq 0 ];then
echo " ** SSH failed  on $server " >> jkb_tux
echo " ** SSH failed  on $server " >> BT_jfailed_tux
fi

rm BT_jk_tux





done < /home/monitoring/sanity/server_$i

################################################



########################## TUX QUEUE Monitor  ###################

grep $i BT_TUX_LIST.txt > server_tux_$i


while read line1
do


lob=`echo $line1 | cut -d" " -f1`
description=`echo $line1 | cut -d" " -f2`

server=`echo $lob | cut -d"@" -f2`


./BT_tux_check  $lob $description   >> BT_tk

done < /home/monitoring/sanity/server_tux_$i



####################################

####################### TUX SERVICES MONITOR #########################

grep $i BT_TUX_LIST.txt > server_tux_s_$i


while read line1
do


lob=`echo $line1 | cut -d" " -f1`
description=`echo $line1 | cut -d" " -f2`

server=`echo $lob | cut -d"@" -f2`


./BT_tux_service  $lob $description $server  >> BT_sk

done < /home/monitoring/sanity/server_tux_s_$i



#####################################################################


if [  -s server_$i ];then

  if [ -s BT_jfailed_tux ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
      if [ -s jkb_tux  ];then



     echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
     else

     echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
     fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi






if [  -s server_tux_$i ];then

  if [ -s BT_jfailed_tux ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s BT_tk  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
   fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi


if [  -s server_tux_s_$i ];then

  if [ -s BT_jfailed_tux ];then
       echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
  else
   if [ -s BT_sk  ];then


    echo "<td style=color:white;background-color:red;text-align:center><h5 >NOT OK </h5></td>"  >> $wd/Sanity.html
    else

    echo "<td style=color:white;background-color:green;text-align:center><h5 > OK </h5></td>"  >> $wd/Sanity.html
    fi
  fi
else

echo "<td style=color:black;background-color:white;text-align:center><h5 > NA </h5></td>"  >> $wd/Sanity.html

fi



echo "</tr>"  >> $wd/Sanity.html

cat /home/monitoring/sanity/jkb_tux >> BT_check_tux
rm /home/monitoring/sanity/jkb_tux
rm /home/monitoring/sanity/BT_jfailed_tux

cat /home/monitoring/sanity/BT_tk >> BT_tux1
rm /home/monitoring/sanity/BT_tk

cat /home/monitoring/sanity/BT_sk >> $wd/BT_service1
rm /home/monitoring/sanity/BT_sk

done


echo "</table>" >> $wd/Sanity.html
echo "</br>" >> $wd/Sanity.html
echo "</br>" >> $wd/Sanity.html

echo "</br>" >> $wd/Sanity.html
echo "</br>" >> $wd/Sanity.html

echo "</td></tr></table> "  >> $wd/Sanity.html









############################################################################################################################################################################









































################################### To Print Error  ###############################################



echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
echo  "<tr>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html

done < $wd/check

echo "</table>" >> $wd/Sanity.html

rm $wd/check

echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/http1

echo "</table>" >> $wd/Sanity.html

rm $wd/http1

echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/clone1

echo "</table>" >> $wd/Sanity.html

rm $wd/clone1

echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/ds1

echo "</table>" >> $wd/Sanity.html

rm $wd/ds1


echo  "</td>"  >> $wd/Sanity.html

echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/ls1

echo "</table>" >> $wd/Sanity.html

rm $wd/ls1


echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/crk1

echo "</table>" >> $wd/Sanity.html

rm $wd/crk1


echo  "</td>"  >> $wd/Sanity.html





echo  "</tr>"  >> $wd/Sanity.html
echo "</table>" >> $wd/Sanity.html

#####################################################################

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
echo  "<tr>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html

done < $wd/check_tux

echo "</table>" >> $wd/Sanity.html

rm $wd/check_tux

echo  "</td>"  >> $wd/Sanity.html






echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/tux1


rm $wd/tux1

echo "</table>" >> $wd/Sanity.html

echo  "</td>"  >> $wd/Sanity.html

echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/service1


#rm $wd/service1

echo "</table>" >> $wd/Sanity.html

echo  "</td>"  >> $wd/Sanity.html



echo  "</tr>"  >> $wd/Sanity.html
echo "</table>" >> $wd/Sanity.html

##########################################################

##################################################################################Butterfly Error Report ###################################################################


################################### To Print Error  ###############################################



echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
echo  "<tr>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html

done < BT_check

echo "</table>" >> $wd/Sanity.html

rm BT_check

echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/BT_as1

echo "</table>" >> $wd/Sanity.html

rm $wd/BT_as1

echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/BT_clone1

echo "</table>" >> $wd/Sanity.html

rm $wd/BT_clone1

echo  "</td>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < BT_ds1

echo "</table>" >> $wd/Sanity.html

rm BT_ds1






echo  "</td>"  >> $wd/Sanity.html




echo  "<td>"  >> $wd/Sanity.html
echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < BT_st1

echo "</table>" >> $wd/Sanity.html

rm BT_st1






echo  "</td>"  >> $wd/Sanity.html




echo  "</tr>"  >> $wd/Sanity.html
echo "</table>" >> $wd/Sanity.html

#####################################################################

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html
echo  "<tr>"  >> $wd/Sanity.html


echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html

done < BT_check_tux

echo "</table>" >> $wd/Sanity.html

rm BT_check_tux

echo  "</td>"  >> $wd/Sanity.html






echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < BT_tux1


rm BT_tux1

echo "</table>" >> $wd/Sanity.html

echo  "</td>"  >> $wd/Sanity.html

echo  "<td>"  >> $wd/Sanity.html

echo "<table border="0" style=\"align:center\">" >> $wd/Sanity.html

while read r
do

echo "<tr style=\"color:red\">" >> $wd/Sanity.html
echo "<td>"$r "</td>"   >> $wd/Sanity.html
   echo  "</tr>"  >> $wd/Sanity.html
echo "</br>"  >> $wd/Sanity.html
done < $wd/BT_service1


#rm BT_service1

echo "</table>" >> $wd/Sanity.html

echo  "</td>"  >> $wd/Sanity.html



echo  "</tr>"  >> $wd/Sanity.html
echo "</table>" >> $wd/Sanity.html

##########################################################


############################################################################################################################################################################



echo  "</tr>"  >> $wd/Sanity.html
echo "</table>" >> $wd/Sanity.html


echo "</body>" >> $wd/Sanity.html
echo "</HTML>" >> $wd/Sanity.html

echo hourly_FS_report.sh Finished Running `date`




rm $wd/server*
#scp $wd/Sanity.html monitoring@10.5.252.239:/tmp/

sleep 2;

sed 1,6d $wd/Sanity.html > $wd/Sanity_ss.html
sed '5i<META http-equiv="refresh" content="10">' $wd/Sanity_ss.html > $wd/Sanity_ss1.html

sed 8,12d $wd/Sanity_ss1.html > $wd/Sanity_ss2.html

sed '8i \<STYLE type=TEXT\/CSS\>\<\!--BODY { font-family: Tahoma\\; font-size:20pt} TABLE { background-color: #F3B2AA  } SPAN { font-family: Tahoma\; font-size:15pt}   TD  { font-family: Tahoma\; font-size:20pt\; padding: 2}   TH { background-color:#cccc99\;           color:#336699\;           font-family: Tahoma\;           font- weight:bold\; padding: 2\;           font-size: 15pt\; }   TR { background-color:#f9f9ef\;}BR {font-size: 2pt}--\>\<\/STYLE\>' $wd/Sanity_ss2.html > $wd/Sanity_ss3.html


scp -r $wd/Sanity_ss3.html agd_user@10.5.118.163:/home/agd_user/lampstack-5.6.31-0/apache2/htdocs/wgt/Sanity.html
scp -r $wd/Sanity_ss.html agd_user@10.5.118.163:/home/agd_user/Python-3.7.4/MY_django/env/bin/middleware/ovportal/templates/Sanity.html

/usr/lib/sendmail -t -f nipanjan.gupta@airtel.com GiTechIndiaAirtelMiddleware@amdocs.com  < $wd/Sanity.html




#ssh -q monitoring@10.5.252.239 'bash -s' <$wd/mail.sh
