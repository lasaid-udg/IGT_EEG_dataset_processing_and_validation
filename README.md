# EEG Preprocessing and Analysis Pipeline: Iowa Gambling Task (IGT)

This repository contains a MATLAB-based workflow for the preprocessing and analysis of EEG data recorded during the Iowa Gambling Task (IGT). The pipeline covers the entire flow: from raw data loading and digital filtering to epoch segmentation and grand average visualization (ERP & PSD).

## Project Structure

For the code to function correctly, maintain the following folder hierarchy. The functions `filter_eeg`, `main_preprocessing`, `rereference_eeg`, and `segmentation_eeg` **must** be inside the `preprocessing/` folder as shown:

```text
project-root/
│
├── main.m                 # Entry point: Orchestrates subjects and data flow
├── main_figures.m         # Coordinator for figure generation
├── figures/               # Folder: Plotting and analysis functions
│   ├── figure_7.m         # Behavioral results (Total credits)
│   ├── figure_8.m         # Spectral Analysis (Noise floor vs Cortical)
│   └── figure_9.m         # ERP Visualization (P300, N400, FRN)
├── preprocessing/         # Folder: Core signal processing functions
│   ├── filter_eeg.m       # Bandpass and Notch filters
│   ├── main_preprocessing.m # Preprocessing sequence manager
│   ├── rereference_eeg.m  # Auricular re-referencing (A1, A2)
│   └── segmentation_eeg.m # Epoching (Task-related & Baseline)
└── data/                  # Dataset directory (Subject folders s-01 to s-59)
```

## 2. Workflow Description

The pipeline follows a linear and modular execution flow, designed to transform raw EEG recordings into clean, segmented data ready for statistical analysis.

### Step 1: Data Integration (`main.m`)
The process begins by iterating through each subject's folder. The system dynamically generates paths for:
* **Signal Data**: `EEG.csv` containing raw potential values.
* **Behavioral Data**: `IGT.csv` containing the "EEG sample" column, which acts as the trigger for synchronization.

### Step 2: Signal Standardization (`rereference_eeg.m`)
Before filtering, the raw signal undergoes a re-referencing process:
* **Auricular Reference**: It calculates the average of electrodes **A1** and **A2**.
* **Subtraction**: This average is subtracted from all other channels to remove common noise.
* **Channel Mapping**: Original reference channels are removed, and a `Pz` channel is initialized as a placeholder for consistent topography.

### Step 3: Digital Refinement (`filter_eeg.m`)
To ensure signal integrity, the re-referenced data passes through two sequential filters:
* **Bandpass Filter**: A 3rd-order Butterworth filter restricts the frequency response between **0.5 Hz and 70 Hz**, eliminating DC offset and high-frequency muscle artifacts.
* **Notch Filter**: A specific stop-band filter at **60 Hz** is applied to remove electrical power line interference.
* **Zero-Phase Distortion**: The use of `filtfilt` ensures that no phase shift is introduced during filtering.

### Step 4: Temporal Segmentation (`segmentation_eeg.m`)
The continuous filtered signal is divided into discrete epochs (windows):
* **Baseline Windows**: 20 windows are automatically extracted from the first 175 seconds of the recording (resting state).
* **Task Windows**: Using the timestamps from `IGT.csv`, the code extracts 4-second segments centered on each decision (2s pre-stimulus and 2s post-stimulus).
* **Storage**: All windows are organized into a nested structure (`w001`, `w002`, etc.) within the main subject variable.

### Step 5: Analysis & Figure Generation (`main_figures.m`)
The final stage aggregates the segmented data across all 59 subjects to perform:
* **Grand Averaging**: Combining epochs to reveal Event-Related Potentials (ERPs).
* **Spectral Analysis**: Applying Fast Fourier Transform (FFT) to compare the cortical power against the system's noise floor.
The following table describes the most significant variables used throughout the processing and analysis workflow:

## Key Variables 
| Variable | Description |
| :--- | :--- |
| `fs` | **Sampling Frequency**: Set to 256 Hz, used for all time-to-sample conversions and filter designs. |
| `raw_eeg` | **Raw Signal Data**: A MATLAB table containing the initial potential values and electrode names (e.g., Fp1, Fp2, A1, A2). |
| `timestamps` | **Event Indices**: A vector of sample indices extracted from `IGT.csv` that marks the exact moment of each player's decision. |
| `reref_sig` | **Re-referenced Signal**: The EEG data after subtracting the average of the auricular electrodes (A1 and A2). |
| `segmentated_eeg` | **Master Data Structure**: A nested structure where each field (e.g., `.s_01`, `.s_02`) contains the 4-second epochs (`w001`, `w002`...) for each subject. |
| `eoi` | **Electrodes of Interest**: An array containing the indices for electrodes **Cz, Fz, and Pz**, used specifically for ERP analysis. |
| `gral_scores` | **Behavioral Matrix**: A 200x59 matrix storing the credit balance across all trials for every subject. |
| `x_fft` / `psd` | **Spectral Data**: Variables representing the result of the Fast Fourier Transform, used to calculate the signal's power density. |

## Script Details

The repository is organized into three main functional areas: execution control, signal preprocessing, and data visualization.

### 1. Execution & Coordination
* **`main.m`**: The entry point of the pipeline. It iterates through the 59 subjects, manages the folder paths, and coordinates the loading of `EEG.csv` and `IGT.csv`. It stores all processed results in a master structure.
* **`main_figures.m`**: A dedicated coordinator for the analysis phase. It sequentially calls the plotting functions for behavioral and electrophysiological results.

### 2. Preprocessing Functions (Folder: `/preprocessing`)
* **`main_preprocessing.m`**: Acts as a manager for individual subject data, ensuring that re-referencing, filtering, and segmentation occur in the correct order.
* **`rereference_eeg.m`**: Standardizes the signal by calculating the average of the auricular electrodes (**A1** and **A2**) and subtracting it from all channels. It also prepares the `Pz` channel.
* **`filter_eeg.m`**: Implements a **3rd-order Butterworth filter**. It applies a bandpass (0.5–70 Hz) and a notch (60 Hz) filter using `filtfilt` to ensure zero-phase distortion, preserving the timing of EEG components.
* **`segmentation_eeg.m`**: Performs the epoching process. It extracts 20 baseline segments from the resting period and 4-second task-related windows (2s pre-decision to 2s post-decision) based on behavioral timestamps.

### 3. Analysis & Visualization (Folder: `/figures`)
* **`figure_7.m`**: Focuses on behavioral analysis. It calculates the cumulative credit balance for all subjects across the 200 trials of the IGT.
* **`figure_8.m`**: Conducts frequency-domain analysis. It compares the **Power Spectral Density (PSD)** of the cortical band (relevant signal) against the noise floor (high-frequency interference) using boxplots.
* **`figure_9.m`**: Generates the **Event-Related Potential (ERP)** plots for Cz, Fz, and Pz. It automatically calculates the median response and highlights specific components: **P300**, **N400**, and **FRN** using shaded visual envelopes.

## How to Run

Follow these steps to execute the pipeline and reproduce the analysis:

### 1. Prerequisites
Ensure you have **MATLAB (R2021a or later)** installed with the following toolboxes:
* **Signal Processing Toolbox**: Required for filtering and FFT analysis.
* **Statistics and Machine Learning Toolbox**: Required for the `boxplot` visualizations.

### 2. Dataset Preparation
The code expects a specific folder structure to iterate through the subjects. Your data directory should look like this:
* A root folder named `data/`.
* Subfolders for each subject named `s-01`, `s-02`, ..., `s-59`.
* Inside each subject folder, the files `EEG.csv` and `IGT.csv` must be present.

### 3. Repository Setup
1. Download or clone this repository.
2. Ensure the folders `preprocessing/` and `figures/` are in the same directory as `main.m`.
3. Open MATLAB and set the repository folder as your **Current Folder**.

### 4. Configuration and Execution
1. Open the file `main.m`.
2. Locate the `path` variable and update it with the absolute path to your `data` folder:
   ```matlab
   % Example:
   path = "C:\Users\YourUser\Documents\Project\data\";
   ```
3. Run the pipeline by calling the main function in the Command Window:
   ```matlab
    main(path)
   ```
4. Expected Outputs
* Console Logs: MATLAB will display the progress (e.g., Current process: s-01).
* Figures:
   * Figure 7: Behavioral credit balance average.
   * Figure 8: Power Spectral Density (PSD) comparison.
   * Figure 9: ERP analysis for Cz, Fz, and Pz.

* Saved Files: A high-resolution image figure9_3.png (300 DPI) will be automatically exported to the root directory.
