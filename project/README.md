# Bus Bunching Prediction

Big Data Programming coursework project. Predicts and analyses **bus bunching** (when two or more buses on the same route end up running close together instead of evenly spaced) using real-world data from the UK **Bus Open Data Service (BODS)**, processed with **PySpark**.

## Overview

Bus bunching degrades service reliability for passengers and is a well-known problem in public transport operations. This project builds an end-to-end pipeline that:

1. Parses real published bus timetables (TransXChange XML) into structured schedule data.
2. Polls real-time vehicle location data (SIRI-VM) from BODS.
3. Joins schedule and live-location data to detect and label bunching events.
4. Engineers features (time of day, previous headway, route) from real data only.
5. Trains and evaluates classification models to predict bunching.
6. Adds an unsupervised clustering pass as a supplementary analysis.

All primary results in this project are computed on **real BODS data** — no synthetic data is used by default.

## Data Source

- **Feed:** First Bus_15211 (operator ref `FESX`, First Essex)
- **Format:** SIRI-VM real-time vehicle location + TransXChange timetables
- **Coverage:** Essex-area routes (Southend, Basildon, Chelmsford, Colchester), including routes 25, 100, 300, 51, 52, 87, 371, 375, X30
- **Portal:** [Bus Open Data Service](https://www.bus-data.dft.gov.uk/)

## Real Data Results

| Metric | Value |
|---|---|
| Timetable rows parsed | 476,087 |
| Distinct routes (timetable) | 106 |
| Raw location polls collected | 27,439 |
| Distinct location observations (deduplicated) | 762 |
| Routes with both schedule + live data | 72 |
| Real bunching rate | 26.1% |
| Model F1 score | ≈ 0.80–0.82 |
| Model ROC-AUC | ≈ 0.86–0.90 |


## Models

Three classification models were used for the primary bunching-prediction task, plus one unsupervised technique as a supplementary analysis:

| Model | Purpose |
|---|---|
| Logistic Regression | Interpretable baseline — shows how much time-of-day and previous headway increase bunching odds |
| Random Forest | Captures non-linear feature interactions (e.g. peak-hour effects varying by route) |
| Gradient Boosted Trees | Best-performing model on this structured/tabular data (ROC-AUC ≈ 0.88) |
| K-Means Clustering | Supplementary EDA — groups routes/time windows by bunching tendency |

Features used are leakage-free real leading indicators only (e.g. hour of day, previous headway) — no information from the outcome itself is used to predict it.


## Setup

### Environment (Windows)

PySpark is incompatible with Python 3.12/3.13 on Windows, so this project uses a dedicated conda environment:

```bash
conda create -n sparkenv python=3.11
conda activate sparkenv
pip install -r requirements.txt
```

Use the **"Python 3.11 (Spark)"** Jupyter kernel when running the notebooks.

Each PySpark notebook sets the following at the top, required for Windows compatibility:

```python
import os, sys
os.environ['PYSPARK_PYTHON'] = sys.executable
os.environ['HADOOP_HOME'] = r'C:\Hadoop'
```

### Data

1. Copy `config.py.example` to `config.py` and add your BODS API key.
2. Run `parse_timetable.py` to generate the real timetable CSV.
3. Run `poll_locations.py` to collect real live-location data (leave running as long as possible before analysis — more polling time = more robust results).

## Running the Notebooks

```bash
jupyter notebook
```

Open and run `01_data_loading.ipynb` through `07_modelling_results.ipynb` sequentially. Each notebook has already been pre-executed with real data so outputs are visible without re-running, but re-running with a longer polling window will strengthen the results.

## Author

Pratikshya  Kunwar
240593
