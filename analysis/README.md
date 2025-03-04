
# Visualize proteomic results
In 
```
./analysis
```
run "Protein_plotting.py" file
add necessary parameters

```
   # path of files
    path = "./data/"
    # output of proteomics results

    protein_data_file = "./data/protein_data_only_validated_proteins.txt"
    # list of significant proteins each row contains a protein example: MDC1
    significant_protein_list_file = "./data/sig_proteins.csv"
    # This should be an output from gene scape xlsx format
    # protein_data = './data/output_reportgenerator_trans_20230413.csv'
    protein_information_file = 'DVP2_interesting_GenScrape_output.xlsx'
    doc_filename_dvp2 = 'dvp2_1-2-3_replicates_gene'

    # palette example
    # dots = [(0, 255, 0), (0, 255, 100), (0, 255, 0), (0, 255, 50)]
    # single color example
    dots = [(0, 255, 0)]
    # line color
    line_c = (0, 0, 0)
    # this will remove unnecessary from the visualization
    remove_these_phases_from_plots = []
```