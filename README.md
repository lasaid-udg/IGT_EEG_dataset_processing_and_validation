# MATLAB Scripts for EEG Signal Preprocessing

This repository contains the MATLAB functions used for standard Electroencephalography (EEG) signal preprocessing in the associated research article. The pipeline performs **re-referencing**, **filtering**, and **signal segmentation (epoching)** to prepare raw EEG data for subsequent analysis.

## Dataset Reference

The raw data intended for use with this preprocessing pipeline is publicly available. Please cite the dataset as follows:

Chávez-Sánchez, Manuel; Torres-Ramos, Sulema ; Roman-Godinez, Israel; Salido-Ruiz, Ricardo A. (2025), “An electroencephalographic and behavioral dataset from the Iowa Gambling Task application on non-clinical participants”, Mendeley Data, V1, doi: 10.17632/2pw2m39yct.1.

## Prerequisites

The scripts are written in MATLAB and require the base MATLAB environment. The primary input and output formats are MATLAB `table` and `structure` arrays. The assumed **sampling frequency ($\text{fs}$) is $256 \text{ Hz}$**.

## Pipeline Overview

The main entry point for the preprocessing workflow is the `preprocessing.m` function, which sequentially calls the other scripts:

1.  **Re-referencing**: `rereference_eeg.m`
2.  **Filtering**: `filter_eeg.m`
3.  **Segmentation/Epoching**: `segmentation_eeg.m`

---

## Detailed Function Descriptions

### 1. `preprocessing.m`

The core script that orchestrates the entire preprocessing workflow.

**Function Signature:**
```matlab
function processed_eeg = preprocessing(raw_eeg, timestamps)
