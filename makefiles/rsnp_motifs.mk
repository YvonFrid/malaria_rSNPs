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
PREFIX=snps_of_interest
SOI_IDS=${SOI_DIR}/${PREFIX}.txt
RESULT_DIR=results/SOI_motifs
SOI_OUT=${RESULT_DIR}/${PREFIX}


## Variation-scan 
MATRIX=${RSAT}/public_html/motif_databases/JASPAR/Jaspar_2018/nonredundant/JASPAR2018_CORE_vertebrates_non-redundant_pfms_transfac.tf
#MATRIX=${RSAT}/public_html/data/motif_databases/JASPAR/Jaspar_2018/nonredundant$/JASPAR2018_CORE_vertebrates_non-redundant_pfms_transfac.tf
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
	1> ${SOI_OUT}_varBed_stdout.txt \
	2> ${SOI_OUT}_varBed_stderr.txt

#	${SPECIES_SUFFIX_OPT} ${OPT}


varinfo:
	@echo
	@echo "Running var-info on snps of interest (SOI)"
	@echo "	SOI_DIR		${SOI_DIR}"
	@echo "	RESULT_DIR	${RESULT_DIR}"
	@mkdir -p ${RESULT_DIR}
	@echo "	SOI_IDS		${SOI_IDS}"
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
	-i ${SOI_OUT}.varBed \
	-mml 30 -format varBed \
	-o ${SOI_OUT}.varSeq \
	1> ${SOI_OUT}_varSeq_stdout.txt \
	2> ${SOI_OUT}_varSeq_stderr.txt

retrieve_varseq:
	@echo ""
	@echo "Retrieving variation sequences from variation info file"
	@echo "Input file	${SOI_OUT}.varBed"
	@echo "${RETRIEVE_VAR_CMD}"
	@${RETRIEVE_VAR_CMD}
	@echo "	${SOI_OUT}.varSeq"

###############################################################
## ## Scan selected variations with the matrix of interest

PVAL=0.001
PVAL_RATIO=10
#BG_MODEL=${RSAT}/public_html/demo_files/all_human_ENCODE_DNAse_mk1_bg.ol
BG_MODEL=${RSAT}/public_html/data/genomes/${SPECIES}_${ASSEMBLY}/oligo-frequencies/2nt_upstream-noorf_${SPECIES}_${ASSEMBLY}-noov-1str.freq.gz
VARSCAN_RES=${SOI_OUT}_varscan_pval${PVAL}_pvalratio${PVAL_RATIO}

VARSCAN_CMD=variation-scan -v ${V} \
	-i ${SOI_OUT}.varSeq \
	-m ${MATRIX} -m_format transfac \
	-bg ${BG_MODEL} \
	-lth score 1 -lth w_diff 1 \
	-uth pval ${PVAL} \
	-lth pval_ratio ${PVAL_RATIO} \
	-o ${VARSCAN_RES}.tsv \
	1> ${VARSCAN_RES}_tsv_stdout.txt \
	2> ${VARSCAN_RES}_tsv_stderr.txt

#variation-scan -v 1 -m $RSAT/public_html/tmp/apache/2018/06/18/variation-scan_2018-06-18.183854_KDlwmAvariation-scan_sequence_custom_motif_manualinput.tf -m_format transfac -i $RSAT/public_html/tmp/apache/2018/06/18/variation-scan_2018-06-18.183854_KDlwmAvariation-scan_sequence_input -bg $RSAT/public_html/tmp/apache/2018/06/18/variation-scan_2018-06-18.183854_KDlwmA_bgfile.txt -lth score 1 -lth w_diff 1 -lth pval_ratio 10 -uth pval 1e-3 


variation_scan:
	@echo
	@echo "Scanning variant sequences for rSNPs"
	@echo "	Input file	${SOI_OUT}.varSeq"
	@echo "	Output file	${VARSCAN_RES}.tsv"
	@echo "${VARSCAN_CMD}"
	@${VARSCAN_CMD}
	@echo "Output file"
	@echo "	${VARSCAN_RES}.tsv"                                                                          
