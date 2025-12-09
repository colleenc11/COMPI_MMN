# Localizing Hierarchical Prediction Errors and Precisions During an Oddball Task with Volatility: Computational Insights and Relationship with Psychosocial Functioning in Healthy Individuals

This repository contains Matlab code for reproducing the results in:

Charlton, C. E., & Hauke, D. J., et al. (2025). _Localizing Hierarchical Prediction Errors and Precisions During an Oddball Task with Volatility: Computational Insights and Relationship with Psychosocial Functioning in Healthy Individuals._

## Members of the project
**Supervision:** Daniel J. Hauke, Andreea O. Diaconescu

**Contributors:** Michelle Wobmann, Christina Andreou, Renate de Bock, Stefan Borgwardt, Volker Roth

## Project description
We acquired EEG data from 43 control participants during a mismatch negativity paradigm. This data was modeled to explore the computational mechanisms that govern sensory learning and their association to psychosocial functioning.

## Submodules
This repository utilizes submodules. If you're cloning the repository, make sure to get the associated submodules as well.

The current submodules include:
 - SPM12

## Getting Started
1. Clone this repository along with its submodules using the following command:
```
git clone --recurse-submodules https://github.com/colleenc11/compi_mmn.git
```
If you've already cloned the repository without its submodules, initialize and fetch them with:
```
git submodule update --init --recursive
```
2. Open Matlab and navigate to the ```COMPI_MMN/code``` directory.
3. Initialize your environment by running ```compi_setup_paths``` script.

## Running Pipeline in Matlab
The models were implemented in Matlab (version: 2023a; https://mathworks.com) using the HGF toolbox (version: 6.0). This toolbox is part of the open-source TAPAS (Frässle et al., 2021) software collection, available [here](https://github.com/translationalneuromodeling/tapas/releases/tag/v4.0.0).

Steps to run the pipeline:

1. Open Matlab and navigate to the ```COMPI_MMN/code``` directory.
2. From within this directory, run the 'compi_master_eeg' script.
3. To configure analysis options, navigate to the ```code/configs/options``` directory and modify the ```compi_mmn_options``` file.

## Third Party Code
The repository also contains the following external, freely available Matlab tools:
-  the function ```notBoxPlot``` by Rob Campbell, available [here](https://github.com/raacampbell/notBoxPlot).
-  the ```TNUEEG toolbox``` for preprocessing, aligning with the methods presented in the study by [Weber et al., 2022](https://elifesciences.org/articles/74835).
