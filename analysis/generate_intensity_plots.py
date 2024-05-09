
import pandas as pd
import matplotlib.pyplot as plt
import os
import re
import seaborn
import visualization
import validation_experiment
"""
set the feature name to extract from the headers of the csv
"""
path = "e:/DVP2/CODE from hydra/koosk/output/BIAS-DVP2-RNA-val20230926/"
file = "validation-exp-230926.csv"

features_to_extract = ['CYTO INTENSITY-MEAN Alexa 647', 'CYTO INTENSITY-MEDIAN Alexa 647'
    , 'CYTO INTENSITY-INTEGRATED Alexa 647']

if __name__ == '__main__':
    df = pd.read_csv(f"{path}{file}")
    print("all done")
    slides = df.groupby(['series'])
    groupkeyslist = list(slides.groups.keys())

    for feature_name in features_to_extract:
        slides_results = []
        slide_averages = []
        for i in range(len(groupkeyslist)):
            print(groupkeyslist[i])
            current_group = slides.get_group(groupkeyslist[i])
            phase_groupped = current_group.groupby(['phase'])
            phaseskeyslist = list(phase_groupped.groups.keys())
            # this sorts the cells by classes [1,1,1,1,2,2,2,2,3,3,3,.....41,41]
            sorted_keylist = sorted(phaseskeyslist, key=lambda x: float(re.findall("\d+", x)[0]))
            averages = []
            slide_results_df = pd.DataFrame()
            df_list = []
            for phase in range(len(sorted_keylist)):
                current_phase = phase_groupped.get_group(sorted_keylist[phase])
                # collecting the average values of each phases

                averages.append(current_phase.loc[:, feature_name].mean())

                # creating a new dataframe containing only the phase and feature in interest
                df_list.append(current_phase.loc[:, [feature_name, "phase"]])
                # pd.concat(df_list, ignore_index=True)
                # current_features = pd.DataFrame([current_phase.loc[:, feature_name]])
            slide_averages.append([averages])
            slides_results.append(pd.concat(df_list, ignore_index=True))

        if not os.path.exists(f"{feature_name}/"):
            os.makedirs(f"{feature_name}/")

        normalized_colors = [(r / 255, g / 255, b / 255) for r, g, b in visualization.colorsforplot]

        for c, slide in enumerate(slides_results):
            # removing cutting strings from phases
            slide = slide.replace('-cutting', '', regex=True)
            seaborn.set(style='whitegrid')
            # mine
            # swarmplot = seaborn.swarmplot(data=slide, x=slide['phase'], y=slide[feature_name],
            #                               palette=seaborn.color_palette(normalized_colors),
            #                               alpha=.7,size=6)
            #
            # swarmplot = seaborn.stripplot(data=slide, x=slide['phase'], y=slide[feature_name],
            #                                palette=seaborn.color_palette(normalized_colors),
            #                                jitter=0.3, marker="o", alpha=0.7)
            # Nikitas
            swarmplot = seaborn.boxplot(data=slide, x=slide['phase'], y=slide[feature_name],
                                        palette=seaborn.color_palette(normalized_colors),
                                        width=.2, showfliers=False)

            swarmplot = seaborn.stripplot(data=slide, x=slide['phase'], y=slide[feature_name],
                                          palette=seaborn.color_palette(normalized_colors),
                                          jitter=0.3, marker="o", alpha=0.7)
            # swarmplot = seaborn.violinplot(data=slide, x=slide['phase'], y=slide[feature_name],
            #                    palette=seaborn.color_palette(normalized_colors),
            #                    inner=None, color="lightgray", linewidth=0)
            #
            # # Add a swarm plot on top of the violin plot
            # swarmplot =seaborn.swarmplot(data=slide, x=slide['phase'], y=slide[feature_name],
            #                 palette=seaborn.color_palette(normalized_colors),
            #                   color="blue", size=3)

            seaborn.scatterplot(slide_averages[c], palette=['black'], zorder=100,
                                legend=None)
            swarmplot.set_xticklabels(swarmplot.get_xticklabels(), rotation=90)
            fig = swarmplot.get_figure()
            plt.tight_layout()

            # Regular expression pattern with a capturing group for the well key
            pattern = re.compile(r'([A-H][1-8])')

            # Search for the pattern in the string
            match = re.search(pattern, groupkeyslist[c])
            filename_str= f'{groupkeyslist[c]}_' \
                          f'{validation_experiment.well_plates_antibodies_genes_dict[match[0]]["Gene_Name"]}' \
                          f'_{feature_name}.png'
            plt.title(f'{validation_experiment.well_plates_antibodies_genes_dict[match[0]]["Gene_Name"]}, ' \
                      f'{validation_experiment.well_plates_antibodies_genes_dict[match[0]]["Antibody_ID"]}, ' \
                      f'well: {match[0]}')
            fig.set_tight_layout(True)
            fig.savefig(f"{feature_name}/{filename_str}")

            plt.close()
            # MATPLOT LIB ORIGINAL
            # plt.plot(slide)
            # plt.title(groupkeyslist[c])
            # plt.savefig(f"{feature_name}/{groupkeyslist[c]}_{feature_name}.png")
            # plt.close()
