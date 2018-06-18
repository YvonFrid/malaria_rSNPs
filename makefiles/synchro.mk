################################################################
## List of targets

################################################################
## Variables
V=1
MAKE=make -s -f ${MAKEFILE}
DATE=`date +%Y-%M-%d_%H:%M:%S`
DAY=`date +%Y%m%d`
TIME=`date +%Y%m%d_%H%M%S`
MAKEFILE=makefiles/synchro.mk

usage:
	@echo "usage: make [-OPT='options'] target"
	@echo "implemented targets"
	@perl -ne 'if (/^([a-z]\S+):/){ print "\t$$1\n";  }' ${MAKEFILE}

LOGIN=yvon
SERVER_DIR=malaria_rsnp
SERVER=rsat-tagc.univ-mrs.fr
DIR=makefiles
from_server_one_dir:
	rsync -ruptvl -R ${OPT} ${LOGIN}@${SERVER}:${SERVER_DIR}/${DIR} .

