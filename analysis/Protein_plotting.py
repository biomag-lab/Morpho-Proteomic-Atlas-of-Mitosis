import pandas
import pandas as pd
import matplotlib.pyplot as plt
import os
import re
import seaborn

try:
    import visualization
except ImportError:
    pass
import seaborn
import numpy as np
import csv
from tqdm import tqdm
import warnings
import textwrap

warnings.filterwarnings("ignore")


def remove_duplicates(input_list) -> list:
    """

    :param input_list:
    :return:
    """
    unique_items = []
    seen = set()
    for item in input_list:
        if item not in seen:
            unique_items.append(item)
            seen.add(item)
    return unique_items


def read_csv_rows(input_csv_file):
    """

    :param input_csv_file: full path and file
    :return:  list with csv rows
    """
    with open(input_csv_file) as file_obj:
        # Create reader object by passing the file
        # object to reader method
        reader_obj = csv.reader(file_obj)
        rows = []
        # Iterate over each row in the csv
        # file using reader object
        for row in reader_obj:
            rows.append(row[0])
        return rows


def format_xml_file():
    pass


def check_protein_file_integrity_for_missing_replicates():
    pass


def remove_phases_from_replicates(a_dataframe: pd.DataFrame,inputlist: list) -> pd.DataFrame:
    """

    :param a_dataframe:
    :param inputlist: list of strings that will be removed
    :return:
    """

    for item in inputlist:
        a_dataframe = a_dataframe[a_dataframe['Phases'] != item]
    return a_dataframe


def run_doc_plot_generation(path, file, protein_list_file, protein_data, doc_filename,
                            phases_to_rm_list=[],
                            colors=[(0, 0, 255)], line_color=(0, 0, 0)) -> None:
    """

    :param path: every input file expeted in the same folder
    :param file:  output of proteomics results
    :param protein_list_file:  list of significant proteins each row contains a protein ex: MDC1
    :param protein_data: genescape output file
    :param doc_filename:
    :param phases_to_rm_list:
    :param line_color:
    :param colors:
    :return: None
    """
    # Create an HTML file and write each column and an image to it
    normalized_colors = [(r / 255, g / 255, b / 255) for r, g, b in colors]
    normalized_line_color = tuple(component / 255 for component in line_color)

    if not os.path.exists(f"{path}/{doc_filename}/"):
        os.makedirs(f"{path}/{doc_filename}")
    genes_to_search = read_csv_rows(f"{path}/{protein_list_file}")
    genes_to_search = remove_duplicates(genes_to_search)
    gene_information = pd.read_excel(f"{path}/{protein_data}", header=None)
    # format xlsx
    # transpose  set header to the second row and remove Field ID rows
    gene_information = gene_information.T
    gene_information.columns = gene_information.iloc[1]
    gene_information = gene_information[2:]
    # Remove the first column
    gene_information = gene_information.iloc[:, 1:]
    df = pd.read_csv(f"{path}{file}", sep="\t")

    column_groups = {}
    columns_without_numbers = [col for col in df.columns if not any(char.isdigit() for char in col)]

    # Step 1: Group columns based on suffix
    for col in df.columns:
        parts = col.split('_')
        if len(parts) > 1:
            suffix = parts[-1]
            column_groups.setdefault(suffix, []).append(col)

    # Step 2: Create a set of all prefixes
    all_prefixes = set(parts[0] for col in df.columns if len(parts := col.split('_')) > 1)

    # Step 3: Check and fill missing prefixes for each suffix
    for suffix_to_check in column_groups:
        current_columns = column_groups[suffix_to_check]
        current_prefixes = set(parts[0] for parts in [col.split('_') for col in current_columns])
        missing_prefixes = all_prefixes - current_prefixes

        # Sort missing prefixes based on both prefix and numeric part
        sorted_missing_prefixes = sorted(missing_prefixes, key=lambda x: (
            x.split('_')[0], int(x.split('_')[-1]) if x.split('_')[-1].isdigit() else float('inf')))
        for missing_prefix in sorted_missing_prefixes:
            existing_positions_suffixes = [(df.columns.get_loc(col), col.split('_')[-1]) for col in df.columns if
                                           col.startswith(missing_prefix)]
            # Find the correct position for the missing suffix
            insert_position = None
            for position, suffix in existing_positions_suffixes:
                if suffix > suffix_to_check:
                    insert_position = position
                    break
            # If the missing suffix is greater than all existing suffixes, insert at the end
            if insert_position is None:
                insert_position = max(existing_positions_suffixes, key=lambda x: x[0])[0] + 1
            new_column_name = f"{missing_prefix}_{suffix_to_check}"
            df.insert(insert_position, new_column_name, 'N/A')

    column_groups = {}
    columns_without_numbers = [col for col in df.columns if not any(char.isdigit() for char in col)]

    # Step 1: Group columns based on suffix
    for col in df.columns:
        parts = col.split('_')
        if len(parts) > 1:
            suffix = parts[-1]
            column_groups.setdefault(suffix, []).append(col)

    # Step 4: Convert the dictionary values to lists
    column_lists = list(column_groups.values())

    with open(f"{path}/{doc_filename}/{doc_filename}_docs.html", 'w') as html_file:
        # Write HTML header light style
        html_file.write('<html>\n<head></head>\n<body>\n')
        # Write HTML header with a simple light style
        # html_file.write('<html>\n<head>\n<title>Data Presentation</title>\n<style>\n')
        html_file.write('<html>\n<head>\n<title></title>\n<style>\n')
        html_file.write(
            'body {font-family: Arial, sans-serif; background-color: #F9F9F9; color: #333333; margin: 20px;}\n')
        html_file.write('h1, h2 {color: #333333;}\nhr {border: 1px solid #CCCCCC;}\nimg {margin-left: 20px;}\n')
        html_file.write('</style>\n</head>\n<body>\n')

        # Write HTML header with dark style
        #
        # html_file.write(
        #     '<html>\n<head>\n<style>\nbody {font-family: Arial, sans-serif; background-color: #1E1E1E; color: '
        #     '#FFFFFF;}\n')
        # html_file.write(
        #     'h1, h2 {color: #BB86FC;}\nhr {border: 1px solid #BB86FC;}\nimg {margin-left: '
        #     '20px;}\n</style>\n</head>\n<body>\n')

        for gene_to_search in tqdm(genes_to_search):
            try:
                select_interesting_protein_row = df[df['Genes'] == gene_to_search]

                # Further processing or analysis with select_interesting_protein_row
            except KeyError:
                print(f"The gene '{gene_to_search}' is not present in the DataFrame")
                select_interesting_protein_row = pandas.DataFrame()

            if select_interesting_protein_row.empty:
                continue
            html_file.write(f'<h1>{gene_to_search}</h1>\n<hr>\n')
            for idx in range(len(select_interesting_protein_row)):
                replicates = []
                hit = select_interesting_protein_row.iloc[[idx]]
                for replicate in range(len(column_groups)):
                    combined_list = column_lists[replicate] + columns_without_numbers
                    selected_hit = hit[combined_list]

                    selected_hit.columns = column_lists[0] + columns_without_numbers
                    replicate_at_gene = selected_hit[column_lists[0]]
                    replicates.append(replicate_at_gene)
                if select_interesting_protein_row.empty:
                    continue

                # prefixes = replicates.columns.str.extract(r'([a-zA-Z]+)_', expand=False)

                protein_group = hit.iloc[0]['Protein.Group']
                # get the information searchinng for symbol
                b = gene_information[gene_information['Approved symbol:'] == gene_to_search]

                # Convert strings to numeric values
                replicates = pd.concat(replicates)
                replicates = replicates.apply(pd.to_numeric, errors='coerce')
                replicates.columns = replicates.columns.str.split('_').str[0]
                replicates = replicates.melt(var_name='Phases', value_name='Intensities')

                if phases_to_rm_list is not []:
                    replicates = remove_phases_from_replicates(replicates, phases_to_rm_list)

                mean_replicates = replicates.groupby('Phases').mean()
                # replicates['Phases'] = replicates['Phases'].str.split('_').str[0]
                # Remove the suffix from the 'varriable' column
                plt.figure()
                seaborn.set(style='whitegrid')

                swarmplot = seaborn.stripplot(data=replicates, x="Phases", y='Intensities',
                                              palette=seaborn.color_palette(normalized_colors),
                                              jitter=0.1, marker="o", alpha=0.7)
                swarmplot = seaborn.lineplot(mean_replicates, color=normalized_line_color, zorder=100,
                                             legend=None)

                if not os.path.exists(
                        f"{path}/{doc_filename}/{os.path.splitext(protein_list_file)[0]}/{gene_to_search}/"):
                    os.makedirs(f"{path}/{doc_filename}/{os.path.splitext(protein_list_file)[0]}/{gene_to_search}/")
                # Set y-axis to log base 2 scale using FuncScale
                swarmplot.set_xticklabels(swarmplot.get_xticklabels(), rotation=90)
                fig = swarmplot.get_figure()
                plt.title(f"Gene: {gene_to_search} Protein group: {protein_group}")
                fig.set_tight_layout(True)
                fig.savefig(
                    f"{path}/{doc_filename}/{os.path.splitext(protein_list_file)[0]}/{gene_to_search}/{gene_to_search}_{protein_group}.png")
                # text goes here
                plt.close()
                # Image
                html_file.write(
                    f'<img src="{f"./{os.path.splitext(protein_list_file)[0]}/{gene_to_search}/{gene_to_search}_{protein_group}.png"}" '
                    f'alt="{gene_to_search}"'
                    f'margin-left: 20px;">\n')
                html_file.write('<br><br>\n')
            if b.shape[0] > 0:
                b = b.iloc[[0]]
            # Write each column to HTML
            for column in b.columns:
                # Add a header for each column
                html_file.write(f'<h3>{column}</h3>\n')
                # Write the column values as text
                html_file.write('<pre>\n')
                for val in b[column]:
                    # Add line breaks for long texts
                    wrapped_text = textwrap.fill(str(val), width=80)
                    html_file.write(wrapped_text + '\n')
                # html_file.write('\n'.join(str(val) for val in b[column]))
                html_file.write('\n</pre>\n')
                # Write the column data to HTML
                # html_file.write(b[column].to_frame().to_html(index=False, header=False))

            # html_file.write(f'<h1>{gene_to_search}</h1>\n<hr>\n')
            html_file.write('<br><br>\n')
        # Write HTML footer
        html_file.write('</body>\n</html>')


if __name__ == "__main__":

    """
    DVP2
    """
    # path of files
    path = "./data/"
    # output of proteomics results

    file_dvp2 = "40_mitotic_stages.pg.matrix_67per_rep_imputed_batchcorrected_3_with_geneinformation.txt"
    # list of significant proteins each row contains a protein example: MDC1
    protein_list_file_dvp2 = "sig_proteins.csv"
    # This should be an output from gene scape xlsx format
    # protein_data = 'output_reportgenerator_trans_20230413.csv'
    protein_data_dvp2 = 'DVP2_interesting_GenScrape_output.xlsx'
    doc_filename_dvp2 = 'dvp2_1-2-3_replicates_gene'

    # palette example
    # dots = [(0, 255, 0), (0, 255, 100), (0, 255, 0), (0, 255, 50)]
    # single color example
    dots = [(0, 255, 0)]
    # line color
    line_c = (0, 0, 0)
    remove_these_phases_from_plots = []
    # if you dont want to remove anythin just uncomment this
    # remove_these_phases_from_plots = []

    run_doc_plot_generation(path, file_dvp2, protein_list_file_dvp2, protein_data_dvp2, doc_filename_dvp2,
                            remove_these_phases_from_plots,
                            colors=visualization.colorsforplot, line_color=line_c)
    