#!/bin/bash

#$ -S /bin/bash
#$ -o /ifshome/mhapenney/logs -j y

#$ -q compute.q
#------------------------------------------------------------------

# CONFIG - petproc.config
CONFIG=${1}

source utils.sh

utils_setup_config ${CONFIG}

#------------------------------------------------------------------
for subj in ${SUBJECT[@]}; do
utils_setup_config ${CONFIG}
for ROI in ${regionsofinterest[@]};do
utils_setup_config ${CONFIG}


#Test
echo ${LABEL}
#------------------------------------------------------------------
# Qsub convention
#------------------------------------------------------------------

#STAGE 8 - PET ROI Analysis

#------------------------------------------------------------------

#ROI ANALYSES
	if [ ! -d ${ROIDIR} ]
	then
	mkdir -p ${ROIDIR}
	fi
	
	# pet space
	if [ ! -d ${PETSPACE} ]
	then
	mkdir -p ${PETSPACE}
	fi

	# t1 space
	if [ ! -d ${T1SPACE} ]
	then
	mkdir -p ${T1SPACE}
	fi
	
	# fs_space
	if [ ! -d ${FSSPACE} ]
	then
	mkdir -p ${FSSPACE}
	fi

#------------------------------------------------------------------
#EXTRACT ROI FROM APARC+ASEG
#------------------------------------------------------------------
echo "Running ${REGIONEXTRACT}"
#${REGIONEXTRACT} ${MPRAGE}/${subj}_aparc+aseg.nii.gz ${LABEL} ${FSSPACE}/${subj}_aparc+aseg_ROI_${ROI}.nii.gz
${REGIONEXTRACT} ${T1}/${subj}_aparc+aseg_to_native.nii.gz ${LABEL} ${T1SPACE}/${subj}_aparc+aseg_inT1space_ROI_${ROI}.nii.gz

${FSLMATHS} ${T1SPACE}/${subj}_aparc+aseg_inT1space_ROI_${ROI}.nii.gz -bin ${T1SPACE}/${subj}_aparc+aseg_inT1space_ROI_${ROI}_bin.nii.gz

#------------------------------------------------------------------
# STEP (1) - BINARIZE EXTRACTED ROI
#------------------------------------------------------------------
#echo "STAGE 5: STEP 1 --> ${subj} ROI ${ROI} THRESHOLDED"
#cmd="${FSLMATHS} ${FSSPACE}/${subj}_aparc+aseg_ROI_${ROI}.nii.gz -bin ${FSSPACE}/${subj}_aparc+aseg_ROI_${ROI}_bin.nii.gz"

#eval ${cmd}
#touch ${NOTE}
#echo -e "STAGE 5: STEP 1 --> ${subj} ROI ${ROI} THRESHOLDED  \r\n" >> ${NOTE}
#echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#------------------------------------------------------------------
#STEP (2) - FS ROIS TRANSFORM TO NATIVE T1 (APPLY FS2T1 MATRIX)
#------------------------------------------------------------------
#echo "STAGE 5: STEP 2 --> ${subj} FS ROIs TRANSFORMED TO T1 NATIVE SPACE"
#cmd="${FSLFLIRT}
#	-in ${FSSPACE}/${subj}_aparc+aseg_ROI_${ROI}_bin.nii.gz \
#	-ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
#	-applyxfm \
#	-init ${T1}/${subj}_orig_to_native.xfm \
#	-out ${T1SPACE}/${subj}_aparc+aseg_inT1space_ROI_${ROI}.nii.gz"

#cmd2="${FSLFLIRT}
#	-in ${FSSPACE}/${subj}_aparc+aseg_ROI_${ROI}_bin.nii.gz \
#	-ref ${MPRAGE}/${subj}_orientROBUST_brain.nii.gz \
#	-applyxfm \
#	-init ${T1}/${subj}_orig_to_native.xfm \
#	-out ${T1SPACE}/${subj}_aparc+aseg_inT1space_ROI_${ROI}.nii.gz"

#if [[ -f "$N4" ]]; then
# eval ${cmd}
# touch ${NOTE}
# echo -e "STAGE 5: STEP 2 --> ${subj} FS ROIs TRANSFORMED TO T1 NATIVE SPACE \r\n" >> ${NOTE}
# echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}
#else
# eval ${cmd2}
# touch ${NOTE}
# echo -e "STAGE 5: STEP 2 --> ${subj} FS ROIs TRANSFORMED TO T1 NATIVE SPACE \r\n" >> ${NOTE}
# echo -e "COMMAND -> ${cmd2}\r\n" >> ${NOTE}
#fi


#------------------------------------------------------------------
#STEP (3) - TRANSFORM NATIVE T1 ROIS to PET SPACE (APPLY T12PET MATRIX)
#------------------------------------------------------------------
echo "STAGE 8: STEP 3 --> ${subj} FS ROIs TRANSFORMED FROM T1 NATIVE SPACE TO PET PET"
cmd="${FSLFLIRT}
	-in ${T1SPACE}/${subj}_aparc+aseg_inT1space_ROI_${ROI}_bin.nii.gz
	-ref ${PET_OUT}/${subj}_cereMNI_ref_adj_TAUpet.nii.gz \
	-applyxfm \
	-init ${PET_OUT}/${subj}_mritoTAUPET.xfm \
	-out ${PETSPACE}/${subj}_aparc+aseg_inTAUPETspace_ROI_${ROI}.nii.gz
    -cost mutualinfo
    -datatype float"


eval ${cmd}
touch ${NOTE}
echo -e "STAGE 8: STEP 3 --> ${subj} FS ROIs TRANSFORMED FROM T1 NATIVE SPACE TO PET PET \r\n" >> ${NOTE}
echo -e "COMMAND -> $cmd\r\n" >> ${NOTE}

#------------------------------------------------------------------
#STEP (4) - THRESHOLD & BINARIZE EXTRACTED PET ROI
#------------------------------------------------------------------
echo "STAGE 8: STEP 4 --> ${subj} PET ROI ${ROI} BINARIZE"
cmd="${FSLMATHS} ${PETSPACE}/${subj}_aparc+aseg_inTAUPETspace_ROI_${ROI}.nii.gz -thr .5 -bin ${PETSPACE}/${subj}_aparc+aseg_inTAUPETspace_ROI_${ROI}_bin.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 8: STEP 4 --> ${subj} PET ROI ${ROI} BINARIZE  \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


#------------------------------------------------------------------
#STEP (5) - MULTIPLY ROI MASK BY PET
#------------------------------------------------------------------
echo "STAGE 8: STEP 5 -->  ${subj} ROI ${ROI} REGION MASK MULTIPLIED TO PET BET"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_BET.nii.gz -mul ${PETSPACE}/${subj}_aparc+aseg_inTAUPETspace_ROI_${ROI}_bin.nii.gz ${ROIDIR}/${subj}_TAUPET_ROI_${ROI}.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 8: STEP 5 -->  ${subj} ROI ${ROI} REGION MASK MULTIPLIED TO PET  \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

cd ${project_conf}
done

chmod -R 775 ${PET_OUT}

chmod -R 775 ${ROIDIR}

chmod -R 775 ${PETSPACE}

chmod -R 775 ${FSSPACE}

chmod -R 775 ${T1SPACE}

cd ${project_conf}
done
