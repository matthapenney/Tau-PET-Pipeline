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
# Reference Region Erode by 1 voxel

./weighted1_roi.sh ${CONFIG};
./weighted2_ref.sh ${CONFIG};
./weighted2a_nonref.sh ${CONFIG};
./weighted3_values.sh ${CONFIG};
