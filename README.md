# MATLAB Scripts for EEG and IGT Data Processing

This repository contains the core MATLAB scripts used for the **preprocessing** and **analysis** of the Electroencephalography (EEG) and Iowa Gambling Task (IGT) behavioral data described in our related publication. These scripts are provided to ensure the reproducibility of the reported results, specifically those related to EEG signal quality and IGT behavioral outcomes.

The processing pipeline is designed to transform raw EEG data into segmented, artifact-reduced epochs and subsequently analyze the Power Spectral Density (PSD) within a Band of Interest (BOI) and the Noise Floor (NF).

## Data Reference

The scripts in this repository operate on a publicly available dataset. Before execution, ensure the dataset is downloaded and its directory path is correctly configured in the `make_preprocess.m` and `figure_v2.m` scripts.

* **Dataset Citation:**
    Chávez-Sánchez, Manuel; Torres-Ramos, Sulema ; Roman-Godinez, Israel; Salido-Ruiz, Ricardo A. (2025), “An electroencephalographic and behavioral dataset from the Iowa Gambling Task application on non-clinical participants”, Mendeley Data, V1, doi: 10.17632/2pw2m39yct.1

---

## Script Descriptions and Functionality

The repository contains six MATLAB scripts that implement the sequential steps of data processing:

### 1. `main.m`

This is the **main execution script** for the entire preprocessing pipeline. It iterates through a specified number of subjects (configured for $n=59$) to load the raw EEG (`EEG.csv`) and IGT behavioral data (`IGT.csv`) for each subject. For every subject, it calls the **`preprocessing`** function. The function contains helper functions, `load_eeg` and `load_igt`, for reading the data files.

### 2. `preprocessing.m`

This function is the **orchestrator of the core preprocessing steps**. It performs standard EEG preprocessing, including re-referencing, filtering, and signal segmentation. The steps are executed sequentially:

* Calls `rereference_eeg` (via the function `rereference_eeg.m`) to perform re-referencing to the auricles.
* Calls **`filter_eeg`** to apply bandpass and notch filtering to the re-referenced signal.

### 3. `rereference_eeg.m` (Function: `EEG_ref`)

This function handles the **re-referencing of the raw EEG data** to the mean of electrodes $\text{A1}$ and $\text{A2}$ (linked-auricles reference).

* It calculates the average signal of the $\text{A1}$ and $\text{A2}$ electrodes.
* It removes the original reference channels $\text{A1}$ and $\text{A2}$.
* It creates a placeholder channel **'Pz'** initialized with zeros.
* It subtracts the calculated reference mean from all remaining channels.

### 4. `filter_eeg.m` (Function: `filter_eeg`)

This function cleans the EEG signal by applying a **third-order Butterworth filter** with zero-phase digital filtering (`filtfilt`). It applies two filters sequentially:

* **Bandpass Filter:** $\mathbf{0.5 - 70\ \text{Hz}}$ (to retain the typical EEG frequency range).
* **Notch Filter:** $\mathbf{59.5 - 60.5\ \text{Hz}}$ (to remove 60 Hz power line noise).
* The function uses a sampling frequency ($f_s$) of **256 Hz**.

### 5. `segmentation_eeg.m` (Function: `segmentation_eeg`)

This function segments the continuous, filtered EEG signal into epochs or windows.

* **Window Generation:** It creates fixed-length epochs around the task-related timestamps.
* **Baseline Windows:** It also generates **20** equally spaced baseline state timestamps between 5 and 175 seconds of the record.
* **Window Length:** Each window has a total duration of **4 seconds** ($4 \times 256$ samples): 2 seconds before and 2 seconds after the central timestamp.

### 6. `figure_v2.m` (Function: `main_script`)

This script serves as the **main entry point for analysis and figure generation**.

#### **`figure7` (IGT Behavioral Results)**

* It calculates the **grand average total credits balance** across 59 subjects over the 200 IGT decisions.
* It plots the grand average and highlights a polygonal region (decisions 20–100, credits 1500–2500) for visual emphasis.

#### **`figure8` (EEG Power Spectral Density)**

* This function calculates the **Noise Floor (NF)** and the **PSD in the Band of Interest (BOI)** for segmented EEG data across all subjects.
* **Noise Floor (NF):** Calculated in the $\mathbf{70-128\ \text{Hz}}$ band using the nested function `noise_floor`. This calculation involves a specific filter (`filter_for_nf`) that includes notch filters for $\mathbf{60\ \text{Hz}}$ and $\mathbf{120\ \text{Hz}}$ noise.
* **Band of Interest (BOI):** Calculated in the $\mathbf{0.5-16\ \text{Hz}}$ band using the nested function `psd_in_boi`.
* **PSD Calculation:** The nested function `get_psd` calculates the integrated $\text{PSD}$ over a specified frequency band using the trapezoidal rule (`trapz`) on the $\text{FFT}$ result from `getfft`.
* The final mean $\text{NF}$ and $\text{BOI}$ values across all epochs are intended to be displayed in a boxplot.
