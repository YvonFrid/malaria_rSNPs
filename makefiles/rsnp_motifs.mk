################################################################
## Starting from a lis of SNPs of interest (SOI), identify potential
## effect on transcription factor binding sites.

################################################################
## Some utilities

## Load site-specific options for the cluster + other parameters
include ${RSAT}/RSAT_config.mk
include ${RSAT}/makefiles/util.mk

################################################################
## Variables
V=1
MAKEFILE=makefile
MAKE=make -s -f ${MAKEFILE}
DATE=`date +%Y-%M-%d_%H:%M:%S`
DAY=`date +%Y%m%d`
TIME=`date +%Y%m%d_%H%M%S`
SSH_OPT = -e ssh 
RSYNC_OPT= -ruptvlz  ${SSH_OPT} 
RSYNC = rsync  ${RSYNC_OPT}
WGET=wget --passive-ftp -np -rNL

################################################################
## Parameters

## Input and output files directory
SOI_DIR=results/SOIs
PREFIX=snps_of_interest_top10
SOI_IDS=${SOI_DIR}/${PREFIX}.txt
RESULT_DIR=results/SOI_motifs
SOI_OUT=${RESULT_DIR}/${PREFIX}


## Variation-scan 

MATRIX=${RSAT}/public_html/data/motif_databases/JASPAR/Jaspar_2018/nonredundant$/JASPAR2018_CORE_vertebrates_non-redundant_pfms_transfac.tf
PVAL=0.1
PVAL_RATIO=2
BG_MODEL=${RSAT}/public_html/demo_files/all_human_ENCODE_DNAse_mk1_bg.ol
VAR_SCAN_RES=${RES_DIR}/${PREFIX}_rsat_var_scan_pval${PVAL}_pvalratio${PVAL_RATIO}



SPECIES=Homo_sapiens
ASSEMBLY=GRCh38
param:
	@echo "Parameters"
	@echo "	SPECIES         ${SPECIES}"
	@echo "	ASSEMBLY        ${ASSEMBLY}"
	@echo "	SOI_DIR      	${SOI_DIR}"
	@echo "	SOI_IDS         ${SOI_IDS}"
	@echo "	PREFIX      	${PREFIX}"
	@echo "	RESULT_DIR      ${RESULT_DIR}"
	@echo "	SOI_OUT      	${SOI_OUT}"

################################################################ 
## Variation info

VAR_INFO_CMD=variation-info -v ${V}\
	-species ${SPECIES} \
	-assembly ${ASSEMBLY} \
	-i ${SOI_IDS} \
	-format id \
	-o ${SOI_OUT}.varBed ${OPT} \
	1> ${SOI_OUT}_stdout.txt \
	2> ${SOI_OUT}_error_log.txt

#	${SPECIES_SUFFIX_OPT} ${OPT}


varinfo:
	@echo
	@echo "Running var-info on snps of interest (SOI)"
	@mkdir -p ${SOI_DIR}
	@echo "	SOI_DIR	${SOI_DIR}"
	@echo "	SOI_IDS	${SOI_IDS}"
	@echo ""
	@echo "Getting variation information from variant IDs"
	@echo "SOI_IDS	${SOI_IDS}"
	@echo "${VAR_INFO_CMD}"
	${VAR_INFO_CMD}

################################################################
## Retrieve the sequences surrounding a set of input variations

RETRIEVE_VAR_CMD=retrieve-variation-seq  \
	-v ${V} \
	-species ${SPECIES} \
	-assembly ${ASSEMBLY} \

RETRIEVE_VAR_CMD_VARBED=${RETRIEVE_VAR_CMD} \
	-i ${RESULT_DIR}/${SOI_OUT}.varBed \
	-mml 30 -format varBed \
	-o ${RESULT_DIR}/${SOI_OUT}.varSeq

retrieve_varseq:
	@echo ""
	@echo "Retrieving variation sequences from variation info file"
	@echo "Input file	${RESULT_DIR}/${SOI_OUT}.varBed"
	@echo "${RETRIEVE_VAR_CMD}"
	@${RETRIEVE_VAR_CMD}
	@echo "	${RESULT_DIR}/${SOI_OUT}.varSeq"

###############################################################
## ## Scan selected variations with the matrix of interest

PVAL=0.001
PVAL_RATIO=10
BG_MODEL=public_html/demo_files/all_human_ENCODE_DNAse_mk1_bg.ol
VARSCAN_RES=${RESULT_DIR}/${SOI_OUT}_varscan_pval${PVAL}_pvalratio${PVAL_RATIO}


VARSCAN_CMD=variation-scan -v ${V} \
	-i ${RESULT_DIR}/${SOI_OUT}.varSeq \
	-m ${MATRIX} -bg ${BG_MODEL} \
	-uth pval ${PVAL} \
	-lth pval_ratio ${PVAL_RATIO} \
	-o ${VARSCAN_RES}.tab

variation_scan:
	@echo "${VARSCAN_CMD}"
	@${VARSCAN_CMD}
	@echo "Output file"
	@echo "	${VARSCAN_RES}.tab"                                                                          
