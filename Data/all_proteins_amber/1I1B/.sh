#!/bin/bash

export AMBERHOME=/home/arul/.conda/envs/AmberTools23/amber.sh

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <protein_path>"
    exit 1
fi

protein_path="$1"

# Loop over equilibration steps
for step in {1..2}; do
    input_file="eq${step}.in"
    output_prefix="eq${step}"

    # Determine the restart file for the current equilibration step
    if [ "$step" -eq 1 ]; then
        restart_file="${protein_path}/heat.rst7"
    else
        restart_file="${output_prefix}.rst7"
    fi

    # Run equilibration step
    nohup pmemd -O -i "$input_file" -p "${protein_path}/1I1B.hmass.parm7" -c "$restart_file" -ref "$restart_file" -o "${output_prefix}.out" -x "${output_prefix}.crd" -inf "${output_prefix}.info" -r "${output_prefix}.rst7" &

    # Wait for the equilibration step to finish before moving to the next one
    wait

    echo "Equilibration step ${step} completed."
done

echo "All equilibration steps completed successfully."
