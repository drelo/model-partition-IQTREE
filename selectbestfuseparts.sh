#!/bin/bash

for i in FASTA/*.fas ; do iqtree -s $i; done 
./AMAS/amas/AMAS.py concat -i ./FASTA/*fas -f fasta -d dna -t concatenated.fas -p partition.part
grep 'Best-fit model' ./FASTA/*.iqtree > MODEL
awk '{print $1 $NF}' MODEL  > MODEL2   
sed -i 's~./FASTA/~~g; s~.fas~~g; s~.iqtree:Best-fit~ ~g; s~$~,~g' MODEL2
awk '{print $2" "$1}' MODEL2 > MODEL3
awk '{print $2" "$NF}' partition.part > LENGTH
paste MODEL3 LENGTH > partitionmodels
iqtree -s concatenated.fas -p partitionmodels
