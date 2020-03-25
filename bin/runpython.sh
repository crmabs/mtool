#!/bin/bash

#                       hip
#       python code     |    rest of the args
hython "${MBAT}/$1.py" "$2" $@:3
