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

#------------------------------------------------------------------
# Step (5) Multiply PET BET by reference region mask.  Isolate PET reference region ROI
#------------------------------------------------------------------
echo "STAGE 9: STEP 1 --> ${subj} MULTIPLY PET SKULLSTRIP BY BINARIZED REFERENCE MASK"
cmd="${FSLMATHS} ${PET_OUT}/${subj}_TAUPET_BET.nii.gz -mul ${PET_OUT}/${subj}_cereMNI_TAUPET_final.nii.gz ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 9: STEP 1 --> ${subj} MULTIPLY PET SKULLSTRIP BY BINARIZED REFERENCE MASK IN PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

#------------------------------------------------------------------
# Step (6) Calculate mean PET value in cerebellum white matter region of TAUPET scans
#-----------------------------------------------------------------
echo "STAGE 9: STEP 2 -->  CALCULATE MEAN REFERENCE REGION SIGNAL FOR SUBJECT ${subj} == ${MEAN_REF}"
MEAN_REF=$(${FSLSTATS} ${PET_OUT}/${subj}_cereMNI_ref_TAUpet.nii.gz -M)
echo -e "STAGE 9: STEP 2 --> ${subj} MEAN REFEENCE REGION SIGNAL \r\n" >> ${NOTE}
echo -e "COMMAND -> MEAN_REF=$(${FSLSTATS} ${PET_OUT}/${subj}_ref_TAUpet.nii.gz -M) = ${MEAN_REF} \r\n" >> ${NOTE}

#------------------------------------------------------------------
# Step (7) Adjust ROI PET signal by mean reference region signal
#------------------------------------------------------------------
echo "STAGE 9: STEP 3 --> ADJUST ROI PET SIGNAL BY MEAN REFERENCE REGION SIGNAL"
cmd="${FSLMATHS} ${ROIDIR}/${subj}_TAUPET_ROI_${ROI}.nii.gz -div ${MEAN_REF} ${ROIDIR}/${subj}_cereMNI_ref_adj_TAUpet_ROI_${ROI}.nii.gz"

eval ${cmd}
touch ${NOTE}
echo -e "STAGE 9: STEP 3 --> ${subj} ADJUST VOXELWISE PET SIGNAL BY MEAN REFERENCE MASK \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


cd ${PET_OUT}
chmod -R 775 ${PET_OUT}
cd ${project_conf}

done
done
