#!/bin/bash
#$ -cwd
#$ -pe threaded 4

set -eu -o pipefail

if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename $0) [sample name] [file name]"
    exit 1
fi

source $(pwd)/run_info

SM=$1
FNAME=$2

printf -- "---\n[$(date)] Start bam2fastq: $FNAME\n---\n"

FSIZE=$(stat -c%s $SM/downloads/$FNAME)

if [[ $(($FSIZE/1024**3)) -lt 128 ]]; then
    TMP_N=128
elif [[ $(($FSIZE/1024**3)) -lt 1000 ]]; then
    TMP_N=$(($FSIZE/1024**3+1))
else
    echo "The bam file is bigger than 1TB."
    exit 1
fi
    
$SAMTOOLS collate -uOn $TMP_N $SM/downloads/$FNAME $SM/tmp.collate \
    |$SAMTOOLS fastq -F 0x900 -1 $SM/fastq/$SM.R1.fastq.gz -2 $SM/fastq/$SM.R2.fastq.gz -
#rm $SM/downloads/$FNAME

printf -- "---\n[$(date)] Finish bam2fastq: $FNAME\n"
