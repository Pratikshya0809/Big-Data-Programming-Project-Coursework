"""
poll_locations.py
------------------
Run this in a VS Code terminal (NOT in a notebook cell). It polls the BODS live bus
location feed repeatedly and appends every vehicle position straight into a CSV file
on disk, in real time. Leave it running for as long as you can before your deadline --
every extra minute means more real rows in your final dataset.

Stop it any time with Ctrl+C -- whatever it collected up to that point is already
saved in the CSV, nothing is lost.
"""

import requests
import time
import csv
import os
from datetime import datetime
import xml.etree.ElementTree as ET

# ---- EDIT THESE TWO LINES ----
API_KEY = "PASTE_YOUR_REGENERATED_API_KEY_HERE"
DATAFEED_ID = 1695  # Stagecoach North West & Merseyside -- change if yours is different

OUTPUT_FILE = "bus_locations_log.csv"
POLL_INTERVAL_SECONDS = 20

NS = {"siri": "http://www.siri.org.uk/siri"}


def ensure_csv_header():
    """Creates the CSV with a header row the first time this script runs.
    If the file already exists, new rows just get appended below what's there."""
    if not os.path.exists(OUTPUT_FILE):
        with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "poll_timestamp", "recorded_at_time", "line_ref",
                "vehicle_ref", "operator_ref", "latitude", "longitude", "bearing"
            ])
        print(f"Created {OUTPUT_FILE} with header row.")
    else:
        print(f"{OUTPUT_FILE} already exists — new rows will be appended to it.")


def poll_once():
    url = f"https://data.bus-data.dft.gov.uk/api/v1/datafeed/{DATAFEED_ID}/?api_key={API_KEY}"
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
    except requests.exceptions.RequestException as e:
        print(f"[{datetime.now()}] Request failed: {e}")
        return 0

    try:
        root = ET.fromstring(resp.content)
    except ET.ParseError as e:
        print(f"[{datetime.now()}] XML parse failed: {e}")
        return 0

    poll_time = datetime.now().isoformat()
    rows = []
    for activity in root.findall(".//siri:VehicleActivity", NS):
        recorded_at = activity.findtext("siri:RecordedAtTime", default="", namespaces=NS)
        journey = activity.find("siri:MonitoredVehicleJourney", NS)
        if journey is None:
            continue
        line_ref = journey.findtext("siri:LineRef", default="", namespaces=NS)
        vehicle_ref = journey.findtext("siri:VehicleRef", default="", namespaces=NS)
        operator_ref = journey.findtext("siri:OperatorRef", default="", namespaces=NS)
        bearing = journey.findtext("siri:Bearing", default="", namespaces=NS)
        location = journey.find("siri:VehicleLocation", NS)
        lat = location.findtext("siri:Latitude", default="", namespaces=NS) if location is not None else ""
        lon = location.findtext("siri:Longitude", default="", namespaces=NS) if location is not None else ""

        rows.append([poll_time, recorded_at, line_ref, vehicle_ref, operator_ref, lat, lon, bearing])

    if rows:
        # Append mode -- each poll's rows get added to the file immediately,
        # so nothing is lost even if you stop the script early.
        with open(OUTPUT_FILE, "a", newline="", encoding="utf-8") as f:
            csv.writer(f).writerows(rows)

    return len(rows)


if __name__ == "__main__":
    ensure_csv_header()
    total_rows = 0
    poll_count = 0
    print(f"Polling every {POLL_INTERVAL_SECONDS}s. Press Ctrl+C to stop.\n")

    try:
        while True:
            n = poll_once()
            total_rows += n
            poll_count += 1
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Poll #{poll_count}: "
                  f"{n} positions saved (running total: {total_rows} rows in {OUTPUT_FILE})")
            time.sleep(POLL_INTERVAL_SECONDS)
    except KeyboardInterrupt:
        print(f"\nStopped by user. Total rows collected this session: {total_rows}")
        print(f"All data is safely saved in {OUTPUT_FILE} -- nothing lost.")
