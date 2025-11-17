# model-partition-IQTREE

A simple example to parse results from the IQTREE model selection stage from each gene alignment in order to generate a partition file with the best substitution model, ideal for using along concatenated analyses.

### Obtaining a Partition File with the Best Substitution Models

This example provides a self-contained script to demonstrate the workflow. It uses mock `iqtree` and `AMAS` executables, so you don't need to have them installed to run it.

**To run the example, simply execute the following command:**

```bash
bash run_model_partition.sh
```

The script will create an `output` directory containing the final partition file, `partitionmodels`, as well as other intermediate files.

### The Workflow

The `run_model_partition.sh` script performs the following steps:

1.  **Runs ModelFinder:** It simulates running IQ-TREE's ModelFinder on each FASTA file in the `FASTA` directory to determine the best-fit substitution model for each gene.
2.  **Concatenates Alignments:** It simulates using AMAS to concatenate the individual gene alignments into a single file.
3.  **Extracts Models:** It extracts the best-fit model from each of the ModelFinder output files.
4.  **Creates Partition File:** It combines the model information with the partition data from AMAS to create a final partition file that can be used with IQ-TREE for a partitioned analysis.
5.  **Final Command:** It prints the final IQ-TREE command that would be used to run the analysis with the generated partition file.

This example is based on the methods described in:

"S. Kalyaanamoorthy, B.Q. Minh, T.K.F. Wong, A. von Haeseler, and L.S. Jermiin (2017) ModelFinder: fast model selection for accurate phylogenetic estimates. Nat. Methods, 14:587–589. DOI: 10.1038/nmeth.4285"
