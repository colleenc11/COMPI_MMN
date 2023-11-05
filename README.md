# Investigating the effects of volatility on the mismatch negativity in healthy controls: A computational modeling approach and its relevance to psychosocial functioning

This repository contains Matlab code for reproducing the results in:

Charlton, C. E., & Hauke, D. J., et al. (2023). _Investigating the effects of volatility on the mismatch negativity in healthy controls: A computational modeling approach and its relevance to psychosocial functioning._ (Under Review)

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
3. Analysis options can be configured in ```compi_mmn_options```.
