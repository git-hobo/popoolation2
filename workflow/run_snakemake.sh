#! /bin/bash
#SBATCH --partition=compute
#SBATCH --nodes=1 --ntasks-per-node=64
#SBATCH --mem=0
#SBATCH --time=10:00:00
#SBATCH --mail-type=FAIL
#SBATCH --mail-user="fabian.schweitzer@biologie.uni-freiburg.de"
#SBATCH --output=../logs/popoolation2_complete.log
#SBATCH --job-name="popoolation2_complete"

source ${HOME}/.bashrc
source ${HOME}/miniconda3/etc/profile.d/conda.sh
conda activate snakemake

[ -d "${MIS}/workflow/samples"] || mkdir -p "${MIS}/workflow/samples"
[ -d "${MIS}/workflow/ref"] || mkdir -p "${MIS}/workflow/ref"
if [ ! -f "${MIS}/workflow/ref/GCF_001465965.1_Pdom_r1.2_genomic.fna" ]; then
    cp "${MIS}/GCF_001465965.1_Pdom_r1.2_genomic.fna" "${MIS}/workflow/ref/GCF_001465965.1_Pdom_r1.2_genomic.fna"
fi
if [ ! -f "${MIS}/workflow/samples/AAA9495_1.fq.gz" ]; then
    cp "${MIS}/AAA9495_?.fq.gz" "${MIS}/workflow/samples/"
fi
if [ ! -f "${MIS}/workflow/samples/AAB7105_1.fq.gz" ]; then
    cp "${MIS}/AAA9495_?.fq.gz" "${MIS}/workflow/samples/"
fi

cd ${MIS}/workflow
snakemake \
    --configfile config.yaml \
    --cores 64 \
    --use-apptainer \
    --rerun-incomplete \
    --printshellcmds
