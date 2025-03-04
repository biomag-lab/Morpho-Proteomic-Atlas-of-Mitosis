---
#Regression Plane (MATLAB)

MATLAB 2022b or later is required


Navigate to code folder in MATLAB.

## Download Training Data
Download the training data for the regression plane from the following link:  
[https://doi.org/10.5281/zenodo.13896968](https://doi.org/10.5281/zenodo.13896968)


## Data representation

In the article, the data is represented on a circle centered at (5000, 5000). The annotated cells are on a ~4500 Radius circle. Interphase cells are located at 270° ± 15°. The remaining 330° is divided into 40 equal sections, each spanning 8.25°. The phases follow a clockwise (CW) order: Prophase → Prometaphase → Metaphase → Anaphase → Telophase.

See the figure below:

<img src="./Images_documentation/TRAIN_data_Visualization.png" width="600" height="600">

However, in the labels file, Interphase is positioned at 0°–30°, and the remaining phases are arranged in a counterclockwise (CCW) direction from 30° to 360°.



## Dataset Preparation

1. **Normalize Intensities**  
   Run the script `classification/normalizeIntensities.m`.  
   - **Input**: Images file.  
   - **Output**: ImgNorm files.  

   ```matlab
   % Normalize intensities
   normalizeIntensities('data/Images', 'output/ImgNorm');
   ```

2. **Apply Intensity Normalization**  
   Run the script `applyIntensityNormalization.m`.  
   - **Inputs**:  
     - `data/Images` folder.  
     - ImgNorm files.  
   - **Outputs**:  
     - `data/ImagesNormalized` folder containing images in 8-bit JPG format.  

   ```matlab
   % Apply intensity normalization
   applyIntensityNormalization('data/Images', 'output/ImgNorm', 'data/ImagesNormalized');
   ```

3. **Split into Training and Validation Sets**  
   Run the script `trainingSetSplitter_v3.m` for each data folder.  
   - **Input**: `data/ImagesNormalized`.  
   - **Outputs**:  
     - Target folder structure:  

       ```
       Target/
       ├── Train/
       │   ├── Images/
       │   │   └── *.jpg
       │   ├── Labels/
       │       └── *.tif
       ├── Val/
           ├── Images/
           │   └── *.jpg
           ├── Labels/
               └── *.tif
       ```

   - Additionally results in the `dataset_nameDensity` file.  

   ```matlab
   % Split dataset into train and validation sets
   trainingSetSplitter_v3('data/ImagesNormalized', 'output/Target');
   ```

4. **Generate Density File**  
   Run the script `density.m`.  
   - **Input**: Target folder.  
   - **Output**: `total_density.mat` file.  

   ```matlab
   % Generate density file
   density('output/Target', 'output/total_density.mat');
   ```

5. **Create Augmentations**  
   Run the script `createAugmentationsForFilesBalanced_v2_2.m`.  
   - **Inputs**:  
     - `total_density.mat` file.  
     - Target folder with Train and Val subfolders.  
   - **Outputs**: Augmented data in the respective folders.  

   ```matlab
   % Create augmentations
   createAugmentationsForFilesBalanced_v2_2('output/total_density.mat', 'output/Target');
   ```

6. **Convert to Classification Format**  
   Run the script `classification/createAnnotatedClasses.m` to prepare the data for classification.

   ```matlab
   % Convert to classification format
   convertToClassificationFormat('output/Target');
   ```

####  Run training
 Train  inceptionv3 model for regression prediction

  Run `trainv38.m`
  
Train auxiliary Resnet50 73251Xes
model for discrete classification  

  Run `classificiation/trainclassificiation.m`
  


---
### Results of the ensemble model

Run `ensembleModelTest.m`

The original model were trained with descripted hyperparameters in the article
#### MATLAB modell on test set <u>RMSE ~670</u>
<img src="./Images_documentation/matlab_test_ensemble.png" width="470" height="350">

