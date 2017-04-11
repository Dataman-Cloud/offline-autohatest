#!/bin/bash
base_dir=$(cd `dirname $0` && pwd)
cd $base_dir
set -e
#export LC_CTYPE=C

. ./config.cfg
. $SRY_DIR/config.cfg

replace_var(){
    files=$@
    echo $files | xargs sed -i 's#--SRY_SERVER--#'$SRY_SERVER'#g'
    echo $files | xargs sed -i 's#--SRY_ADMINNAME--#'$SRY_ADMINNAME'#g'
    echo $files | xargs sed -i 's#--SRY_ADMINPASSWD--#'$SRY_ADMINPASSWD'#g'
    echo $files | xargs sed -i 's#--SSH_USER--#'$SSH_USER'#g'
    echo $files | xargs sed -i 's#--SSH_PASSWD--#'$SSH_PASSWD'#g'
    echo $files | xargs sed -i 's#--DEAFAULT_SLAVE_IP--#'$DEAFAULT_SLAVE_IP'#g'
    echo $files | xargs sed -i 's#--AUTOTESTBORG_IMAGE--#'$AUTOTESTBORG_IMAGE'#g'
}

build_conf(){
    rm -rf conf_d_tmp
    cp -rf conf_d.temp conf_d_tmp

    files=`grep -rl '' conf_d_tmp/*`
    replace_var $files

    rm -rf conf.d
    mv conf_d_tmp conf.d
}

build_cfg_file(){
	file="$1"
	if [ -f $file ];then
        	rm -f $file
	fi
	cp $file.temp $file
        
	replace_var $file

}

main(){
	build_cfg_file autotest_config.txt
}
main
