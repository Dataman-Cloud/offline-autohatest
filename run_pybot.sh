#!/bin/bash
. ./config.cfg
docker run -it $AUTOTESTBORG_IMAGE $@
