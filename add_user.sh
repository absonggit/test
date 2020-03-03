#!/bin/bash
useradd awx_superuser
echo "123456" | passwd awx_superuser --stdin
echo "awx_superuser   ALL=(ALL)       NOPASSWD:ALL" >> /etc/sudoers
