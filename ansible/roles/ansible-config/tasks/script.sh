#!/bin/bash

# This doesnt work! do it manually
set -u

T_OUT_DIR=$PWD/../../..
T_OUT=$($T_OUT_DIR/terraform-output)

printf $T_OUT_DIR
printf $T_OUT

MASTER_HOSTS=$T_OUT grep -A1 master_ip | awk 'NR>1 {print $1}' | xargs echo
WORKER_HOSTS=$T_OUT grep -A1 worker_ip | awk 'NR>1 {print $1}' | xargs echo
EDGE_HOSTS=$T_OUT grep -A1 edge_ip | awk 'NR>1 {print $1}' | xargs echo

printf $MASTER_HOSTS
printf $WORKER_HOSTS
printf $EDGE_HOSTS
