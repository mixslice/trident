import string
import os
import re

dir_path = os.path.dirname(os.path.realpath(__file__))
tf_filename = "/terraform-output"
host_file_dir = "/hosts"
host_file_template_dir = "/hosts.template"
ansible_vars_dir = "/group_vars/all/terraform_vars.yml"
ansible_vars_tempalte_dir = "/group_vars/all/terraform_vars.yml.template"
pre_dirs = 0

all_identifiers = [
  "master_ip",
  "master_private_ip",
  "edge_ip",
  "edge_private_ip",
  "worker_ip",
  "worker_private_ip"
]

ip_regex = r'(?:[\d]{1,3})\.(?:[\d]{1,3})\.(?:[\d]{1,3})\.(?:[\d]{1,3})'

replace_regex = r"\{{([A-Za-z0-9_]+)\}}"

my_list_of_tuples = []

def readFile(fileName,mode):
    f = None
    while (f == None):
        try:
            f = open(fileName,mode)
            print ('Open file successful')
            return f
        except:
            print 'Open file "',fileName,'" failed.'
            return None

def id_lookup(line):
  for identifiers in all_identifiers:
    if identifiers in line:
      print("Found %s"%identifiers)
      return identifiers
  return None

def build_dict_ip_address_rtn_lines_extra(lines_to_read, id):
  ips = []
  for line in lines_to_read:
    ip = re.findall(ip_regex, line)
    if len(ip) < 1 :
      # Didn't find any in thie line, we done
      break
    elif len(ip) > 1:
      raise "Too many ip addresses in one line"
    else:
      # found 1
      ips.append(ip[0])
  my_list_of_tuples.append((id, ips))
  return len(ips)

def write_to_hosts():
  template = readFile(dir_path+"/.."*pre_dirs+host_file_template_dir, 'r')
  f = readFile(dir_path+"/.."*pre_dirs+host_file_dir, 'w')
  for line in template.readlines():
    m = re.search(replace_regex, line)
    if( m == None):
      # Didn find it
      f.write(line)
    else:
      # found it, get the id to replace
      id = m.group(1)
      to_write = ""
      whole_line = ""
      for tup in my_list_of_tuples :
        if tup[0] == id:
          to_write = '\n'.join(tup[1])
          whole_line = line.replace(m.group(0), to_write)
          f.write(whole_line)
  template.close()
  f.close()
  return

def write_to_ansible_vars():
  template = readFile(dir_path+"/.."*pre_dirs+ansible_vars_tempalte_dir, 'r')
  f = readFile(dir_path+"/.."*pre_dirs+ansible_vars_dir, 'w')
  for line in template.readlines():
    m = re.search(replace_regex, line)
    if( m == None):
      # Didn find it
      f.write(line)
    else:
      # found it, get the id to replace
      id = m.group(1)
      to_write = ""
      whole_line = ""
      for tup in my_list_of_tuples :
        if tup[0] == id:
          to_write = ','.join(tup[1])
          whole_line = line.replace(m.group(0), to_write)
          f.write(whole_line)
  template.close()
  f.close()
  return

def read_tf_output(fileName):
  f = readFile(fileName,'r')
  var_lines = f.readlines()
  var_length = len(var_lines)
  i = 0
  while i < var_length:
    line = var_lines[i].rstrip()
    id = id_lookup(line)
    found = (id != None )
    if ( found ):
      i += build_dict_ip_address_rtn_lines_extra(var_lines[i+1:], id)
    i += 1
  f.close()
  # Now we have all ips in my_list_of_tuples
  write_to_hosts()
  write_to_ansible_vars()
  return


read_tf_output(dir_path+"/.."*pre_dirs+tf_filename)
