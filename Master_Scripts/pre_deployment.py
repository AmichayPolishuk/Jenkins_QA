#!/usr/bin/python

import sys, os, paramiko, subprocess, time

hostname = "10.209.24.123"
username = "root"
password = "3tango"
port = 22
wait_flag=True

def run_command(cmd):
  '''connects to other server and excutes command'''
  try:
      client = paramiko.SSHClient()
      client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
      client.connect(hostname, port=port, username=username, password=password)
      #Send command
      stdin, stdout, stderr = client.exec_command(cmd)
      #Read terminal output and error
      output=stdout.read()
      error=stderr.read()
  finally:
      client.close() 
      return ( output, error) 

def main():

  cmd = 'test -d /tmp/Jenkins_QA && rm -rf /tmp/Jenkins_QA'
  res_directory_exist = run_command(cmd)
  if res_directory_exist[1]:
      sys.exit(res_directory_exist[1])
  else:
      print if res_directory_exist[0]:

  cmd = 'cd /tmp/ && git clone https://github.com/AmichayPolishuk/Jenkins_QA.git'
  res_clone= run_command(cmd)
  if res_clone[1]:
      sys.exit(res_clone[1])
  else:
      print res_clone[0]

  cmd = 'cd /tmp/Jenkins_QA && bash -x ./pre_deployment.sh'
  res_pre_deployment = run_command(cmd)
  if res_pre_deployment[1]:
      sys.exit(res_pre_deployment[1])
  else:
      print res_pre_deployment[0]
  
  cmd = 'cd /tmp/Jenkins_QA && bash -x ./config_vf.sh'
  res_config_vf = run_command(cmd)
  if res_config_vf[1]:
      sys.exit(res_config_vf[1])
  else:
      print res_config_vf[0]

  cmd = 'reboot'
  res_config = run_command(cmd)

  wait_flag=True
  while wait_flag:
      counter =0
      ping_response = os.system(' ping -c 1 '+hostname)
      if ping_respone:
          wait_flag=False
          print "The Server : ", hostname, "is up!"
      else:
          counter +=1
          if counter == 10000;
              wait_flag = False
              print "Timeout Expired! Check Server"


  cmd = 'cd /tmp/Jenkins_QA && bash -x ./verify_vf.sh'
  res_verify_vf = run_command(cmd)
  if res_verify_vf[1]:
      sys.exit(res_verify_vf[1])
  else:
      print res_verify_vf[0]          

if __name__ == "__main__":
    main()
