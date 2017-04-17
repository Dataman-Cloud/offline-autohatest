#!/bin/bash
base_dir=$(cd `dirname $0` && pwd)
cd $base_dir
. ./config.cfg

docker run --rm -i $AUTOTESTBORG_IMAGE $@ 
