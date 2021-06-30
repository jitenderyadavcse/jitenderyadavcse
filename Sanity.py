[wladmin@10.14.3.21  DIRs-1 SCRIPTS]$ cat Sanity.py
import os
from subprocess import Popen, PIPE, STDOUT
os.chdir("/home/wladmin/SCRIPTS")



try:
        if os.path.exists("/home/wladmin/SCRIPTS/output_server_status"):
                os.remove("/home/wladmin/SCRIPTS/output_server_status")
                os.remove("/home/wladmin/SCRIPTS/output_application_status")
                os.remove("/home/wladmin/SCRIPTS/output_datasource")
except OSError,e:
        print("file not found")


#os.system("sh /WebLogic/domain_home/DirsDomain/bin/setDomainEnv.sh")
os.system("java weblogic.WLST main.py")



if os.path.exists("/home/wladmin/SCRIPTS/output_server_status"):
        fd1=open("/home/wladmin/SCRIPTS/output_server_status",'r')
        fd2=open("/home/wladmin/SCRIPTS/output_server_status1",'w')


fd=open("/home/wladmin/SCRIPTS/server_exception_list",'r')
s_name=fd.readlines()

s_status=fd1.readlines()


for i in s_name:
        for j in s_status:
                if i.strip('\n') in j:
                        s_status.remove(j)

for j in s_status:
        fd2.write(j)

if os.path.exists("/home/wladmin/SCRIPTS/output_server_status1"):
        os.rename('/home/wladmin/SCRIPTS/output_server_status1','/home/wladmin/SCRIPTS/output_server_status')



os.chdir("/home/wladmin/SCRIPTS")

f1=open("output_application_status1","w")

f3=open("output_application_status","r")
al=f3.readlines()


#al.remove('CRMSC_HEARTBEAT : STATE_NEW on Cluster-CRMSC-OTHERS\n')
#al.remove('CRMSC_HEARTBEAT : STATE_NEW on Cluster-CRMSC-PDF\n')


for j in al:
        f1.write(j)

if os.path.exists("output_application_status1"):
        os.rename("output_application_status1","output_application_status")

