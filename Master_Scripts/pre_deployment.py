#!/usr/bin/python

import sys
import os
import paramiko

hostname = str(sys.argv[1])
username = str(sys.argv[2])
password = str(sys.argv[3])
port = 22

def run_command(cmd):
    '''connects to other server and excutes command'''
    output = None
    error = None
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(hostname, port=port, username=username, password=password)
        # Send command
        stdin, stdout, stderr = client.exec_command(cmd)
        # Read terminal output and error
    except Exception as excep:
        print "We have an Exception %s" % excep
    finally:
        client.close()
        return (output, error)

def wait_for_reboot():
    wait_flag = True
    while wait_flag:
        counter = 0
        ping_response = os.system(' ping -c 2 ' + hostname)
        if ping_response:
            wait_flag = False
            print "The Server : ", hostname, "is Down!"
        else:
            counter += 1
            if counter == 10:
                wait_flag = False
                print "Timeout Expired! Check Server"

def back_from_host():
    wait_flag = True
    while wait_flag:
        counter = 0
        ping_response = os.system(' ping -c 10 ' + hostname)
        if ping_response == 0:
            wait_flag = False
            print "The Server : ", hostname, "is UP!"
        else:
            counter += 1
            if counter == 1000:
                wait_flag = False
                print "Timeout Expired! Check Server"


def main():

    print "================================="
    print "Step 1 - Change to work Directory"
    print "================================="
    cmd = 'test -d /etc/Jenkins_QA && rm -rf /etc/Jenkins_QA'
    res_directory_exist = run_command(cmd)
    if res_directory_exist[1]:
        sys.exit(res_directory_exist[1])
    else:
        if res_directory_exist[0]:
            print res_directory_exist[0]
    time.sleep( 5 )

    print "=============================="
    print "Step 2 - Download bash scripts"
    print "=============================="
    cmd = 'cd /tmp/ && git clone https://github.com/AmichayPolishuk/Jenkins_QA.git'
    res_clone = run_command(cmd)
    if res_clone[1]:
        sys.exit(res_clone[1])
    else:
        print res_clone[0]
    time.sleep( 5 )

    print "=================================================="
    print "Step 3 - OFED Installation + Add Kernel Parameters"
    print "=================================================="
    cmd = 'cd /etc/Jenkins_QA && bash -x ./pre_deployment.sh'
    res_pre_deployment = run_command(cmd)
    if res_pre_deployment[1]:
        sys.exit(res_pre_deployment[1])
    else:
        print res_pre_deployment[0]
    time.sleep( 120 )

    print "====================================="
    print "Step 4 - Configure Virtual Functions "
    print "====================================="
    cmd = 'cd /etc/Jenkins_QA && bash -x ./config_vf.sh'
    res_config_vf = run_command(cmd)
    if res_config_vf[1]:
        sys.exit(res_config_vf[1])
    else:
        print res_config_vf[0]
    time.sleep( 10 )

    print "======================="
    print "Step 5 - Reboot Host  "
    print "======================="
    cmd = 'reboot'
    res_config = run_command(cmd)
    wait_for_reboot()
    back_from_host()

    print "==========================================================================="
    print "Step 6 - Verify Host - Vf's, Interface status and Kernel Paramas existance "
    print "==========================================================================="
    cmd = 'cd /etc/Jenkins_QA && bash -x ./verify_host.sh'
    res_verify_vf = run_command(cmd)
    if res_verify_vf[1]:
        sys.exit(res_verify_vf[1])
    else:
        print res_verify_vf[0]

if __name__ == "__main__":
    main()

