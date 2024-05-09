
import sys
BIAS_PATH = f"d:/program files/bias_latest_latest_latest/bias/"
sys.path.append(f"{BIAS_PATH}/plugins/execute/python/")
import os
import numpy
from os import listdir
from os.path import isfile, join, isdir


from skimage.io import imsave
import pandas as pd
from more_itertools import locate
import re
from tqdm import tqdm
from BIAS.Data import image2d, mask2d, io, items, features
from BIAS.Data.biasdata import BIASId


def get_rgb_image(dict_entry, work_dir):
    """
    Extracts the RGB image from a single entry in a BIAS image dictionary.

    Parameters
    ----------
    dict_entry : dictionary
        RGB dictionary created from a BIAS input list.

    work_dir : string
        Path to BIAS working directory. Required for image IO operations.

    Returns
    -------
    image : numpy.ndarray (height, width, 3)
        RGB image.
    """

    red = io.read(work_dir=work_dir, id=dict_entry['Red'])
    green = io.read(work_dir=work_dir, id=dict_entry['Green'])
    blue = io.read(work_dir=work_dir, id=dict_entry['Blue'])
    image = np.zeros((red.size[0], red.size[1], 3), dtype=int)
    image[:, :, 0] = red.pixels
    image[:, :, 1] = green.pixels
    image[:, :, 2] = blue.pixels
    return image
# myWorkingDir="/home/biomag/HDD2_10TB/DVP2/BIAS-DVP2-40stgs"
# myOutputDir="/home/biomag/HDD3_18TB/koosk/hydra_bias_script_output/test_BIAS-DVP2-40stgs"
# myWorkingDir="/home/biomag/HDD3_18TB/BIAS-DVP2-40stgs-R5"
# myOutputDir="/home/biomag/Work/koosk/output/test_BIAS-DVP2-40stgs-R5"
# myWorkingDir="/home/biomag/HDD2_10TB/DVP2/BIAS-DVP2-40stgs-R4"
# myOutputDir="/home/biomag/HDD3_18TB/koosk/hydra_bias_script_output/BIAS-DVP2-40stgs-R4"
# myWorkingDir= "/media/biomag/Migos_SSD/BIAS-DVP2-RNA/"

# myWorkingDir= "/home/biomag/HDD3_18TB/BIAS-DVP2-valid/"
myWorkingDir = "e:/DVP2/Validation/"
myWorkingDir = "e:/DVP2/Proteomics/"
# myOutputDir="/home/biomag/Work/koosk/output/BIAS-DVP2-RNA-val20230926/"
myOutputDir = "e:/DVP2/"

exportBBSize = 299


exportRadius = int(exportBBSize / 2)


workDataPath = join(myWorkingDir, "data")
seriesList = [f for f in listdir(workDataPath) if isdir(join(workDataPath, f))]
#seriesDataPathList = [f for f in listdir(workDataPath) if isdir(join(workDataPath, f))]
####### check 1
print(seriesList)


header = ['series', 'tile_name', 'phase', 'object_label']
df_inited = False
df = []
error = 0
#vegigiteralunk a a working folderben levo osszes eseten
seriesCtr = 0
os.makedirs(myOutputDir, exist_ok=True)
onlyone = [seriesList[0]]
for series in seriesList:
    seriesCtr = seriesCtr + 1
    #if seriesCtr <2:
    #    continue
    #if seriesCtr > 3:
    #	break

    print("Analyzing ", series)


    #lekerjuk az elerheto fileokat
    seriesPath = join(workDataPath, series)
    seriesDataPathList = [f for f in listdir(seriesPath) if isdir(join(seriesPath, f))]
    allData = list()
    for seriesDataPath in seriesDataPathList:
        currentDataPath = join(seriesPath, seriesDataPath)
        fileList = [f for f in listdir(currentDataPath) if isfile(join(currentDataPath, f))]
        for f in fileList:
            if f.endswith(".items.tar"):
                name = f.replace(".items.tar", "")
                allData.append(BIASId(series, seriesDataPath, name, "items"))
            elif f.endswith(".features.tar"):
                name = f.replace(".features.tar", "")
                allData.append(BIASId(series, seriesDataPath, name, "features"))

    ####### check 2
    # print(allData)

    # megszurjuk ezeket  item listekre (Ede valoszinuleg ezekben tarolta a vagast) es csak azokra amik nem a default konyvtarban vannak ("Items") mert feltetelezem a pipeline a default neveket hasznalta es akkor az osszes szegmentalt sejt abban van
    # interestingData = [x for x in allData if x.type == "items" and x[1] != "Items" and ("cut" in x[1].lower() or re.search("^\d+$", x[1]) is not None) and "test" not in x[1].lower()]

    interestingData = [x for x in allData if x.type == "items" and x.path != "Items" and (
                "cut" in x.path.lower() or re.search("^\d+$", x.path) is not None) and "test" not in x.path.lower()]


    interestingFields = [x.name for x in interestingData]
    #VALIDATION DATA
    # allFeatures = [x for x in allData if x.type == "features" and (x.path == "Features all" or x.path == "Feature Extraction all")]

    #PROTEOMIC DATA
    allFeatures = [x for x in allData if x.type == "features" and "Features" in x.path and x.path != "Features-all" and x.path != "Features-Predictions"]


    featFields = [x.name for x in allFeatures]
    # print(featFields)
    # print(f"interesting data:  {interestingData}")
    numData = len(interestingData)
    if len(allFeatures) < 1:
        continue

    if not df_inited:
        feat = io.read(work_dir=myWorkingDir, id=allFeatures[0])
        header.extend(feat.features)
        df = pd.DataFrame(columns = header)
        df_inited = True

    for dataId in tqdm(interestingData):
        currDir = os.path.join(myOutputDir, series, dataId.path)
        os.makedirs(currDir, exist_ok=True)

        items = io.read(work_dir=myWorkingDir, id=dataId)
        labels = items.labels
        cellCount = len(labels)
        if cellCount < 1:
            continue
        #csak az elso komponenst nezzuk, valoszinuleg az a nucleus, a tobbi nem erdekes jelenleg
        components = items.components

        if len(components) < 1:
            continue


        # print(f"dataid ketto s{dataId.name}")
        featIndices = list(locate(featFields, lambda x: x == dataId.name))
        if len(featIndices) < 1:
            print(f"Could not find features for field: {dataId.name}")
            continue
        featId = allFeatures[featIndices[0]]
        feat = io.read(work_dir=myWorkingDir, id=featId)
        # print(labels.type)
        try:
            # print(feat.labels.index(labels[0]))
            f = feat.matrix[feat.labels.index(labels[0])]
        except:
            error = error + 1
            continue
        row = [series, dataId.name, dataId.path, labels[0]]
        row.extend(f)
        try:
            df.loc[len(df.index)] = row
        except:
            print(f"Could not save feature for featId: {featId}, with label: {labels[0]}")
            print(f"row was: {row}")
            print(f"Features are: {feat.features}")
            print(f"while header is: {header}")

        #elso komponens mask
        maskId = components[0]
        mask = io.read(work_dir=myWorkingDir, id=maskId);
        imageId = mask.dependency
        #image = bias.GetRGBImage2D(imageId)

        #all single channel greyscale images for the field
        imageRegex = re.sub("_c[0-9]+_", "_c[0-9]+_", imageId.name)

        imagePath = join(seriesPath, imageId.path)
        imageFileList = [f for f in listdir(imagePath) if isfile(join(imagePath, f))]
        for f in imageFileList:
            if f.endswith(".image2d.tar") and re.search(imageRegex, f):
                imageId = BIASId(series, imageId.path, os.path.splitext(os.path.splitext(f)[0])[0], "image2d")
                ####### check 3
                # print(maskId, imageId)
                image = io.read(work_dir=myWorkingDir, id=imageId).pixels
                shape = image.shape
                expandedShape = (shape[0] + exportBBSize, shape[1] + exportBBSize)
                paddedImage = numpy.zeros(expandedShape, dtype=numpy.uint16)
                paddedImage[exportRadius:exportRadius+shape[0], exportRadius:exportRadius+shape[1]] = image[:,:]

                locations = items.locations
                for c in range(cellCount):
                    x1 = locations[c,0,0]
                    y1 = locations[c,0,1]
                    x2 = locations[c,0,2]
                    y2 = locations[c,0,3]
                    centerX = int((x1 + x2) / 2) + exportRadius
                    centerY = int((y1 + y2) / 2) + exportRadius

                    croppedImage = paddedImage[centerY - exportRadius : centerY + exportRadius + 1, centerX - exportRadius : centerX + exportRadius + 1]
                    fileName = imageId.name + "_" + str(labels[c]) + ".png"
                    imsave(os.path.join(currDir, fileName), croppedImage, check_contrast=False)

df.to_csv(os.path.join(myOutputDir, "features.csv"), sep=',', index=False)
print(os.path.join(myOutputDir, "features.csv"))
print(f"number of skipped labels {error}")
