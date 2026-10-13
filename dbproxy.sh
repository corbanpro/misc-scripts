#!/bin/bash

cloud-sql-proxy --auto-iam-authn -p 54321 chatfunnels:us-central1:production-v2-replica &
cloud-sql-proxy --auto-iam-authn -p 54322 chatfunnels:us-central1:data-miner &
cloud-sql-proxy --auto-iam-authn -p 54323 chatfunnels:us-central1:beta &
wait
