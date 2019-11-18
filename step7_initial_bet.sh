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

#------------------------------------------------------------------

# Check if directory exists and make if it does not.

if [ ! -d ${PET_OUT} ]
	then
   	mkdir -p ${PET_OUT}
fi

#------------------------------------------------------------------

# STEP 3 - PET Preprocessing and Initial Skullstrip

#------------------------------------------------------------------

# INSERT INITIAL STEP INTO TEXT FILE
echo -e "STAGE 6: --> ${subj} SKULLSTRIP MASK (SEE ${NOTE} FOR MORE INFORMATION ON PROCESSING STEPS) \r\n" >> ${NOTE}

# REORIENT TO STANDARD  - PET
echo "STAGE 6: STEP 1 --> ${subj} reorient PET"
cmd="${FSLREOR2STD} ${PET}/${subj}/${subj}_TAUPET_BL.nii.gz ${PET_OUT}/${subj}_TAUPET_reorient.nii.gz"

			eval $cmd
			touch ${NOTE}
			echo "STAGE 3: STEP 1 --> ${subj} reorient PET ## DONE ##"
			echo -e "STAGE 3: STEP 1 --> ${subj} reorient PET \r\n" >> ${NOTE}
			echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


# ROBUST FOV - PET
echo "STAGE 6: STEP 2 --> ${subj} APPLY ROBUST FOV to PET"
cmd="${FSLROBUST} -i ${PET_OUT}/${subj}_TAUPET_reorient.nii.gz -r ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz"

			eval $cmd
			touch ${NOTE}
			echo "STAGE 3: STEP 2 --> ${subj} APPLY ROBUST FOV to PET ## DONE ##"
			echo -e "STAGE 3: STEP 2 --> ${subj} APPLY ROBUST FOV to PET \r\n" >> ${NOTE}
			echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}

# PET PRELIMINARY SKULLSTRIP
echo "STAGE 6: STEP 3 --> ${subj} PET PRELIMINARY SKULLSTRIP"
cmd="${FSLBET} ${PET_OUT}/${subj}_TAUPET_reorientrobust.nii.gz ${PET_OUT}/${subj}_TAUPET_prelim_bet.nii.gz -B -f 0.5 -g -.05"

			eval $cmd 
			touch ${NOTE}
			echo "STAGE 3: STEP 3 --> ${subj} PET PRELIMINARY SKULLSTRIP ## DONE ##"
			echo -e "STAGE 3: STEP 3 --> ${subj} PET PRELIMINARY SKULLSTRIP \r\n" >> ${NOTE}
			echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


#------------------------------------------------------------------
# PET Registration to MRI T1 Space
#------------------------------------------------------------------
# Calculate linear transformation matrix

cmd="${FSLFLIRT} \
	-in ${PET_OUT}/${subj}_TAUPET_prelim_bet.nii.gz \
	-ref ${MPRAGE}/${subj}_N4_brain.nii.gz \
	-out ${PET_OUT}/${subj}_TAUPET_to_native.nii.gz \
	-omat ${PET_OUT}/${subj}_TAUPETtomri.xfm \
    -cost mutualinfo
    -dof 6"

cmd2="${FSLFLIRT} \
	-in ${PET_OUT}/${subj}_TAUPET_prelim_bet.nii.gz \
	-ref ${MPRAGE}/${subj}_orientROBUST_brain.nii.gz \
	-out ${PET_OUT}/${subj}_TAUPET_to_native.nii.gz \
	-omat ${PET_OUT}/${subj}_TAUPETtomri.xfm
    -cost mutualinfo
    -dof 6"

if [[ -f "$N4" ]]; then
 eval ${cmd}
 touch ${NOTE}
 echo -e "STAGE 6: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE ## DONE ##" 
 echo -e "STAGE 6: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}
else
 eval ${cmd2}
 touch ${NOTE}
 echo -e "STAGE 6: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE ## DONE ##" 
 echo -e "STAGE 6: STEP 4 --> ${subj} LINEAR TRANSFORM PET TO MRI SPACE \r\n" >> ${NOTE}
 echo -e "COMMAND -> ${cmd2}\r\n" >> ${NOTE}
fi

# Calculate inverse inverse transformation matrix

cmd="${FSLXFM} \
	-inverse ${PET_OUT}/${subj}_TAUPETtomri.xfm
    -omat ${PET_OUT}/${subj}_mritoTAUPET.xfm"
eval ${cmd}
touch ${NOTE}
echo -e "STAGE 6: STEP 5 --> ${subj} LINEAR TRANSFORM MRI TO PET SPACE ## DONE ##" 
echo -e "STAGE 6: STEP 5 --> ${subj} LINEAR TRANSFORM MRI TO PET SPACE \r\n" >> ${NOTE}
echo -e "COMMAND -> ${cmd}\r\n" >> ${NOTE}


# Insert command with input and output
chmod -R 775 ${PET_OUT}

cd ${project_conf}
done
