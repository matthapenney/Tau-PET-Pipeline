#!/bin/bash


#$ -q compute.q

# Run TAU Pet Processing

# -----------------------------------------------------
if [ "$SGE_TASK_ID" == "" ]
then

 CONFIG=${1}
 SGE_TASK_ID=1

fi

# CONFIG - petproc.config
source utils.sh

utils_setup_config ${CONFIG}

echo ${subj}
# -----------------------------------------------------
# STEPS
./step0_dicom_nifti_convert.sh ${CONFIG};
./step1_dynamic_image.sh ${CONFIG};
./step2_averagescans.sh ${CONFIG};
./step3_fs_to_native.sh ${CONFIG};
./step4_aparc_refregion_extract.sh ${CONFIG};
./step5_mni_to_native.sh ${CONFIG};
./step6_ref_suit.sh ${CONFIG};
./step7_initial_bet.sh ${CONFIG};
./step8_pet_skullstrip.sh ${CONFIG};
./step9_thrmul.sh ${CONFIG};
./step10_reftopet.sh ${CONFIG};
./step11_pet_roi_analysis.sh ${CONFIG};
./step12_refadjroi.sh ${CONFIG};
./step13_pet_roi_values.sh ${CONFIG};


# Weighted values
#./weighted1_roi.sh
#./weighted2a_nonref.sh
#./weighted2_ref.sh
#./weighted3_values.sh
