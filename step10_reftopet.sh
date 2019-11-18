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
for rr in ${reference[@]};do
utils_setup_config ${CONFIG}

#------------------------------------------------------------------
# STEP (1) - REGISTER REFERENCE REGION (MRI SPACE) TO PET SPACE
#----------------------------------------------------------------

echo "Registering ${subj} MNI cerebellum from MRI space to PET space"
cmd="${FSLFLIRT} \
      -in ${PET_OUT}/${subj}_cereMNI_native_final.nii.gz \
      -ref ${PET_OUT}/${subj}_TAUPET_BET.nii.gz
      -applyxfm -init ${PET_OUT}/${subj}_mritoTAUPET.xfm
      -out ${PET_OUT}/${subj}_cereMNI_TAUPET_final.nii.gz \
      -interp nearestneighbour \
      -datatype float"
eval ${cmd}
echo "Registering ${subj} MNI cerebellum from MRI space to PET space ## DONE ##"


cd ${PET_OUT}
chmod -R 775 ${PET_OUT}
cd ${project_conf}

done
done
