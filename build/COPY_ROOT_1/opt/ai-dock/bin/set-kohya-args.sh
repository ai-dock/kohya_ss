#!/bin/bash

echo "$@" > /etc/kohya_ss_args.conf
supervisorctl restart kohya_ss