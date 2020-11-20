# model-partition-IQTREE
A simple example to parse IQTREE model selection in each gene alignment to generate a partition file with the best substitution model for use in concatenated analyses.


### Obtaining a Partition File with the Best Substitution Models

Place all the fasta files in the folder "FASTA". I concatenated the alignments with [AMAS](https://github.com/marekborowiec/AMAS) passing the options '-t' and '-p' is useful to control the name of the output.

```
./AMAS/amas/AMAS.py concat -i ./FASTA/*fas -f fasta -d dna -t concatenated.fas -p partition.part
```

For this routine I used all the files obtained after several runs of IQ-TREE  [IQ-TREE](http://www.iqtree.org/). IQTREE uses ModelFinder to select the best substitution models. Modify this script according to either version of IQTREE (iqtree or iqtree2)

"S. Kalyaanamoorthy, B.Q. Minh, T.K.F. Wong, A. von Haeseler, and L.S. Jermiin (2017) ModelFinder: fast model selection for accurate phylogenetic estimates. Nat. Methods, 14:587–589. DOI: 10.1038/nmeth.4285"
 
```bash
for i in FASTA/*.fas ; do ./iqtree -s $i ; done 
```

Search for the line where the best model is mentioned...

```bash
grep 'Best-fit model' ./FASTA/*.iqtree > MODEL
```

```bash
# extract the desired columns or text
awk '{print $1 $NF}' MODEL  > MODEL2   
# replace multiple strings inplace
sed -i 's~./FASTA/~~g; s~.fas~~g; s~.iqtree:Best-fit~ ~g; s~$~,~g' MODEL2
# switch order of columns or text
awk '{print $2" "$1}' MODEL2 > MODEL3
# exract only 2 columns from the partition file generated with AMAS
# At this stage we can compare both 'MODEL3' and 'partition.part' columns to confirm the order of the loci listed in both files
awk '{print $2" "$NF}' partition.part > LENGTH
# This will paste both files to obtain the "partitionmodels" file
paste MODEL3 LENGTH > partitionmodels
```

Finally I run IQTREE with this line

```
./iqtree -s concatenated.fas -p partitionmodels
```
