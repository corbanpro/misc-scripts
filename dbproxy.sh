#!/bin/bash

cloud-sql-proxy --auto-iam-authn -p 54221 chatfunnels:us-central1:production-v2-replica &
cloud-sql-proxy --auto-iam-authn -p 54222 chatfunnels:us-central1:data-miner &
cloud-sql-proxy --auto-iam-authn -p 54223 chatfunnels:us-central1:beta &
wait
