# iSleep

This repository accompanies the manuscript **“iSleep: Continuous, binocular pupil tracking in sleep and reduced consciousness”**, available on [bioRxiv](https://www.biorxiv.org/content/10.1101/2025.06.13.659058v1).

iSleep is a research platform developed at the University of Geneva for continuous binocular pupil monitoring during human sleep and reduced consciousness.

The repository contains analysis code and supporting data associated with the results presented in the manuscript. Further details on the experimental methods and findings are provided in the paper.

## Repository contents

The repository is organized into six folders corresponding to the main figures of the manuscript. Each folder contains analysis scripts and, where available, supporting data. Code and data related to Extended Data figures are included in the corresponding main figure folders. Additional larger processed datasets are available separately on Zenodo.

### Figure 1 — iSleep system and example sleep recording

- **`fig1_a_visualization.m`** — MATLAB script for visualizing binocular pupil measurements and synchronized polysomnographic signals across sleep stages, including sleep-stage annotations and arousal events.
- **`fig1_example_rec.m`** — MATLAB script for plotting pupil diameter, eye position, EEG, EOG, EMG, ECG and breathing signals from an example recording.
- **Extended_Fig1c_sleep_architecture.m** — MATLAB script for analyzing and visualizing sleep architecture in Extended Data Figure 1c.
- **Extended_Fig1d_questionnaire.m** — MATLAB script for analyzing questionnaire results presented in Extended Data Figure 1d.
- **Questionnaire .txt files** — Supporting questionnaire data (PrePostQts_finalses_post.txt, PrePostQts_ses1_post.txt, PrePostQts_ses3_post.txt) for the Extended Data analysis.
- **Supporting `.mat` files** — Data from one complete recording session, including pupil-tracking and physiological measurements, sleep-stage annotations and arousal information, used to generate the example plots. clean_signals_with_Ar is available on [Zenodo](https://doi.org/10.5281/zenodo.23299126).

### Figure 2 — Pupil dynamics and physiological activity during sleep

- **`fig2_computations.m`** — Computation of pupil–EEG and autonomic correlations, infraslow oscillations and event-related responses across sleep stages.
- **`fig2_plots.m`** — Visualization and statistical analysis of the computed results.
- **Supporting MATLAB functions** — Additional functions for signal processing, time-frequency analysis, cluster-based permutation testing and visualization.
- **`ISO.mat`** — Processed data containing correlation and spectral measurements across recording sessions and sleep stages. Available on [Zenodo](https://doi.org/10.5281/zenodo.23299126).

### Figure 3 — Pupil-based sleep-stage classification

- **`fig3_FeatureExtraction_example.m`** — Simplified MATLAB script illustrating epoch selection, binocular pupil feature extraction and preparation of data for sleep-stage classification.
- **`fig3_ML.ipynb`** — Python notebook for machine-learning classification of sleep stages, cross-validation and performance evaluation.
- **`fig3b_tsne.csv`** — t-SNE coordinates and corresponding sleep-stage labels for Figure 3b.
- **`plot_fig3b.m`** — MATLAB script for visualizing the t-SNE results in Figure 3b.
- **`fig3d_confusion_counts.csv`** — Confusion matrix data for Figure 3d.
- **`plot_fig3d.py`** — Python script for plotting the confusion matrix in Figure 3d.
- **`general_model_scores.csv`** — Classification performance scores for the generalized models.
- **`session_scores.csv`** — Session-level classification performance scores.
- **`plot_extended_data_fig3.m`** — MATLAB script for visualizing classification performance comparisons in Extended Data Figure 3.
  
The feature-extraction example illustrates selected processing steps rather than the complete feature set used in the study.

### Figure 4 — Pupil modulation and responses to light stimulation during sleep

- **`fig4_pharmacology.m`** — MATLAB script for analyzing pupil diameter and inter-eye correlations following pharmacological pupil modulation.
- **`fig4_pharm_source_data.mat`** — Processed source data for the pharmacological comparisons.
- **`fig4_ERP_plotting.m`** — MATLAB script for analyzing light-evoked EEG responses, including event-related potentials (ERPs), time-frequency power and inter-trial phase coherence (ITPC) across sleep stages.
- **fig4_example_trace.m** — MATLAB script for plotting pupil traces and stimulation triggers to reproduce the example stimulation responses presented in Figure 4.
- **Supporting .mat files** — Example pupil traces, synchronized time information and stimulation trigger indices for the drug-treated and control conditions (c1T_syn.mat, c2T_syn.mat, cnt_eye_source.mat, drug_eye_source.mat, eeg_time_syn.mat).
- **`results_erps.mat`** — Processed EEG analysis data containing event-related responses, time-frequency power and phase-coherence measurements for the tropicamide-treated and control conditions across sleep stages. Available on [Zenodo](https://doi.org/10.5281/zenodo.23299126).

### Figure 5 — Binocular eye positions during sleep

- **`fig5_eye_alignment.m`** — MATLAB script for quantifying horizontal and vertical eye alignment across wakefulness and sleep stages, including vergence distributions and the proportion of time spent in aligned, convergent and divergent eye positions.
- **`fig5c_source_data.mat`** — Processed source data for Figure 5c, including vergence distributions and eye-alignment measurements across recording sessions and sleep stages.

### Figure 6 — Pupil dynamics during general anesthesia

- **`figure6_dilation_analysis.m`** — MATLAB script for detecting intraoperative pupil dilations, analyzing associated physiological responses and comparing pupil and heart-rate response characteristics.
- **`fig6_source_data.mat`** — Processed data containing dilation-aligned pupil and physiological measurements, together with session-level and group-level response metrics.

## Note on data

The datasets have been prepared for public sharing, with certain information excluded in accordance with ethical and data-sharing requirements for human participant research. Participant and session identifiers have been removed or pseudonymized where applicable.

One complete recording session is provided as an example, alongside processed data supporting the analyses presented in the manuscript. The remaining individual recording sessions are not publicly available. Requests for access to additional data may be considered, subject to applicable ethical and data protection requirements.

Some analysis scripts require original recordings or intermediate datasets that are not included in the repository.

## Contact

For questions regarding the code, data or requests for additional information, please contact:

**Özge Yüzgeç**  
University of Geneva  
[Ozge.Yuzgec@unige.ch](mailto:Ozge.Yuzgec@unige.ch)
