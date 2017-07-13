Tools for digesting and visualizing 16S community composition data.

Unless noted otherwise, these are R commands to be used with mothur output. 

metastats_FDR_correction.R is a script that takes mothur metastats output and the taxonomy file and calculates a fdr corrected pvalue and also appends the taxonomy for each OTU.
This requires a specific directory organization to work:

```
metastats_output/
   mothur.taxonomy
   metastats_files/
      file1.metastats
      file2.metastats
      ...
```

or if you desire it accepts one more level of directories
```
metastats_output/
   mothur.taxonomy
   metastats_files/
      project1/
         file1.metastats
         file2.metastats   
         ...
      project2/
         file1.metastats
         file2.metastats
         ...
      project3/
         file1.metastats
         file2.metastats
         ...
```

The output will repeat the same structure but with altered file names. This could be incorporated into commandline executable Rscript but I haven't done that yet...
