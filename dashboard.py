"""
dashboard.py
------------
Streamlit dashboard for "A Predictive Analytics System for Detecting Bus Bunching Events".

Run with:
    streamlit run dashboard.py

Reads from:
    bus_bunching.db                 (SQLite -- routes, bunching_events tables)
    data/sklearn_model_results.csv  (sklearn baseline model comparison)
    data/mllib_model_results.csv    (PySpark MLlib model comparison, optional)
    data/route_clusters.csv         (K-Means clustering output, optional)

This satisfies the brief's optional "System Development" dashboard requirement --
a simple, real, working visualisation layer on top of your actual processed data.
"""

import os
import sqlite3

import pandas as pd
import streamlit as st
import plotly.express as px

DB_PATH = "bus_bunching.db"

st.set_page_config(
    page_title="Bus Bunching Detection Dashboard",
    page_icon="🚌",
    layout="wide",
)

# --------------------------------------------------------------------------------------
# Data loading (parameterised queries -- same security practice as the notebooks)
# --------------------------------------------------------------------------------------
@st.cache_data
def load_routes():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql_query("SELECT * FROM routes", conn)
    conn.close()
    return df


@st.cache_data
def load_events():
    conn = sqlite3.connect(DB_PATH)
    df = pd.read_sql_query("SELECT * FROM bunching_events", conn)
    conn.close()
    return df


@st.cache_data
def load_csv_if_exists(path):
    if os.path.exists(path):
        return pd.read_csv(path)
    return None


if not os.path.exists(DB_PATH):
    st.error(
        f"'{DB_PATH}' not found in this folder. Run Notebook 03 first (it creates the "
        f"database), then place this dashboard.py in the same folder and re-run."
    )
    st.stop()

routes_df = load_routes()
events_df = load_events()
sklearn_results = load_csv_if_exists("data/sklearn_model_results.csv")
mllib_results = load_csv_if_exists("data/mllib_model_results.csv")
route_clusters = load_csv_if_exists("data/route_clusters.csv")

# --------------------------------------------------------------------------------------
# Header + top-level KPIs
# --------------------------------------------------------------------------------------
st.title("🚌 Bus Bunching Detection Dashboard")
st.caption(
    "Stagecoach Cumbria & North Lancashire network — real BODS timetable and live "
    "AVL location data, no synthetic data used."
)

col1, col2, col3, col4 = st.columns(4)
overall_bunching_rate = events_df["is_bunching"].mean() * 100 if len(events_df) else 0
col1.metric("Total Routes", f"{len(routes_df):,}")
col2.metric("Bunching Events Analysed", f"{len(events_df):,}")
col3.metric("Overall Bunching Rate", f"{overall_bunching_rate:.1f}%")
col4.metric(
    "Avg. Scheduled Headway",
    f"{routes_df['scheduled_headway_sec'].mean()/60:.1f} min" if len(routes_df) else "N/A",
)

st.divider()

# --------------------------------------------------------------------------------------
# Sidebar filters
# --------------------------------------------------------------------------------------
st.sidebar.header("Filters")
all_routes = sorted(events_df["line_ref"].astype(str).unique().tolist()) if len(events_df) else []
selected_routes = st.sidebar.multiselect(
    "Filter by route (leave empty for all)", options=all_routes, default=[]
)
min_events = st.sidebar.slider("Minimum events per route to display", 1, 20, 3)

filtered_events = events_df.copy()
if selected_routes:
    filtered_events = filtered_events[filtered_events["line_ref"].astype(str).isin(selected_routes)]

# --------------------------------------------------------------------------------------
# Route-level bunching rate
# --------------------------------------------------------------------------------------
st.subheader("Bunching Rate by Route")

route_summary = (
    filtered_events.groupby("line_ref")
    .agg(n_events=("is_bunching", "size"), bunching_rate=("is_bunching", "mean"))
    .reset_index()
)
route_summary["bunching_rate_pct"] = (route_summary["bunching_rate"] * 100).round(1)
route_summary = route_summary[route_summary["n_events"] >= min_events].sort_values(
    "bunching_rate_pct", ascending=False
)

if len(route_summary) > 0:
    top_n = st.slider("Show top N routes", 5, min(30, len(route_summary)), min(15, len(route_summary)))
    fig = px.bar(
        route_summary.head(top_n),
        x="line_ref",
        y="bunching_rate_pct",
        hover_data=["n_events"],
        labels={"line_ref": "Route", "bunching_rate_pct": "Bunching Rate (%)"},
        color="bunching_rate_pct",
        color_continuous_scale="Reds",
    )
    fig.update_layout(xaxis_type="category")
    st.plotly_chart(fig, use_container_width=True)
else:
    st.info("No routes meet the minimum-events threshold with the current filters.")

# --------------------------------------------------------------------------------------
# Observed vs Scheduled headway
# --------------------------------------------------------------------------------------
st.subheader("Observed vs. Scheduled Headway")
if len(filtered_events) > 0:
    fig2 = px.scatter(
        filtered_events,
        x="scheduled_headway_sec",
        y="observed_headway_sec",
        color=filtered_events["is_bunching"].map({0: "Not bunching", 1: "Bunching"}),
        labels={
            "scheduled_headway_sec": "Scheduled Headway (sec)",
            "observed_headway_sec": "Observed Headway (sec)",
            "color": "Event type",
        },
        opacity=0.7,
    )
    max_val = max(filtered_events["scheduled_headway_sec"].max(), filtered_events["observed_headway_sec"].max())
    fig2.add_shape(type="line", x0=0, y0=0, x1=max_val, y1=max_val, line=dict(dash="dash", color="gray"))
    st.plotly_chart(fig2, use_container_width=True)
    st.caption("Points below the diagonal line arrived closer together than scheduled.")
else:
    st.info("No events match the current filters.")

# --------------------------------------------------------------------------------------
# Model comparison
# --------------------------------------------------------------------------------------
st.subheader("Predictive Model Comparison")
tab1, tab2 = st.tabs(["scikit-learn baseline", "PySpark MLlib (cross-validated)"])

with tab1:
    if sklearn_results is not None:
        st.dataframe(sklearn_results.style.format(precision=3), use_container_width=True)
        fig3 = px.bar(sklearn_results, x="model", y="f1", title="F1-score by model")
        st.plotly_chart(fig3, use_container_width=True)
    else:
        st.info("Run Notebook 04 to generate `data/sklearn_model_results.csv`.")

with tab2:
    if mllib_results is not None:
        st.dataframe(mllib_results.style.format(precision=3), use_container_width=True)
        fig4 = px.bar(mllib_results, x="model", y="f1", title="F1-score by model (cross-validated)")
        st.plotly_chart(fig4, use_container_width=True)
    else:
        st.info("Run Notebook 07 to generate `data/mllib_model_results.csv`.")

# --------------------------------------------------------------------------------------
# Route clustering (optional supplementary analysis)
# --------------------------------------------------------------------------------------
if route_clusters is not None:
    st.subheader("Route Clusters (K-Means — bunching tendency grouping)")
    fig5 = px.scatter(
        route_clusters,
        x="line_ref",
        y="bunching_rate",
        color=route_clusters["cluster"].astype(str),
        labels={"line_ref": "Route", "bunching_rate": "Bunching Rate", "color": "Cluster"},
    )
    fig5.update_layout(xaxis_type="category")
    st.plotly_chart(fig5, use_container_width=True)
    st.caption(
        "Routes are grouped by bunching tendency (see Notebook 07, Section 8) -- useful for "
        "prioritising which routes a transport authority should investigate first."
    )

st.divider()
st.caption(
    "Data: Bus Open Data Service (BODS) — Stagecoach Cumbria & North Lancashire timetable "
    "and live AVL feed. No synthetic data used. Built for ST5011CEM Big Data Programming Project."
)
