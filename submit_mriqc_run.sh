#!/bin/bash -l

array=$1

if [ -z "$array" ]; then
      echo ""
      echo "No job array specified! Please enter jobs to run as argument:"
      echo ""
      echo "    EXAMPLE 1:  submit_ALL.sh 0-99"
      echo "    EXAMPLE 2:  submit_ALL.sh 1-3,6,9"
      echo ""
else
      echo ""
      echo "Submitting the following jobs for MRIQC 23.1.0 session processing now: $array"
      echo ""

      mriqc_abcd=$(sbatch --parsable -a $array resources_mriqc.sh)

      echo "mriqc_v23_1_0 JOB ID: $mriqc_mcdon"

      echo ""
      echo "Use 'squeue -al --me' to monitor jobs."
      echo ""
fi
