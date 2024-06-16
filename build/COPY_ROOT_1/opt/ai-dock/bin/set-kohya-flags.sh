#!/bin/bash

echo "$@" > /etc/kohya_ss_flags.conf
supervisorctl restart kohya_ss