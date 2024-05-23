 #!/bin/bash 

set +x 
# determine data directory, run folders, and run templates
data_dir="/tmp/mcdon" 
data_bucket="s3://mcdon-ohsu-adhd" # data that BIDS data will be pulled from
run_folder=`pwd`
output="${run_folder}/OUT" # bucket to input data onto s3, preprocessed output pushed to

mriqc_folder="${run_folder}/run_files.mriqc"
mriqc_template="${run_folder}/template.mriqc"

email=`echo $USER@umn.edu`
group=`groups|cut -d" " -f1`

# counter to create run numbers
k=0


for i in $(s3cmd ls "${data_bucket}/unprocessed/niftis/" | awk '{print $2}'); do
  # does said folder include subject folder?
  sub_text=$(echo "${i}" | awk -F"/" '{print $(NF-1)}' | awk -F"-" '{print $1}')
  if [ "sub" = "${sub_text}" ]; then
    subj_id=$(echo "${i}" | awk -F"/" '{print $(NF-1)}' | awk -F"-" '{print $2}')
    for j in $(s3cmd ls "${data_bucket}/unprocessed/niftis/${sub_text}-${subj_id}/" | awk '{print $2}'); do
      ses_text=$(echo "${j}" | awk -F"/" '{print $(NF-1)}' | awk -F"-" '{print $1}')
      if [ "ses" = "${ses_text}" ]; then
        ses_id=$(echo "${j}" | awk -F"/" '{print $(NF-1)}' | awk -F"-" '{print $2}')
        
        sed -e "s|SUBJECTID|${subj_id}|g" -e "s|SESID|${ses_id}|g" -e "s|DATADIR|${data_dir}|g" -e "s|BUCKET|${data_bucket}|g" -e "s|RUNDIR|${run_folder}|g" -e "s|OUTPUT|${output}|g" ${mriqc_template} > ${mriqc_folder}/run${k}
        k=$((k+1))
      fi
    done
  fi
done


# cat ${run_folder}/sub_list/subjs_${ses}.csv | while read line ; do 
# 	subj_id=`echo $line | awk -F'-' '{print $2}'`

# 	sed -e "s|SUBJECTID|${subj_id}|g" -e "s|SESID|${ses}|g" -e "s|LOGNUM|${k}|g" -e "s|MRIQCVERSION|${mriqc_vr}|g" -e "s|DATADIR|${data_dir}|g" -e "s|INPUT|${data_input}|g" -e "s|BUCKET|${data_bucket}|g" -e "s|RUNDIR|${run_folder}|g" ${mriqc_template} > ${mriqc_folder}/run${k}
# 	k=$((k+1))
# done

chmod 775 -R ${mriqc_folder}

sed -e "s|GROUP|${group}|g" -e "s|EMAIL|${email}|g" -i ${run_folder}/resources_mriqc.sh 

