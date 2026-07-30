import xml.etree.ElementTree as ET
import glob, os, re
import pandas as pd

NS = {"txc": "http://www.transxchange.org.uk/"}


def parse_runtime(rt):
    """PT1M0S -> seconds"""
    if not rt:
        return 0
    h = re.search(r'(\d+)H', rt)
    m = re.search(r'(\d+)M', rt)
    s = re.search(r'(\d+)S', rt)
    total = 0
    if h: total += int(h.group(1)) * 3600
    if m: total += int(m.group(1)) * 60
    if s: total += int(s.group(1))
    return total


def parse_transxchange_file(filepath):
    tree = ET.parse(filepath)
    root = tree.getroot()

    # Stop names
    stop_names = {}
    for sp in root.findall('.//txc:StopPoints/txc:AnnotatedStopPointRef', NS):
        ref = sp.find('txc:StopPointRef', NS)
        name = sp.find('txc:CommonName', NS)
        if ref is not None:
            stop_names[ref.text] = name.text if name is not None else None

    # Operators (NOC lookup)
    operators = {}
    for op in root.findall('.//txc:Operators/txc:Operator', NS):
        noc = op.find('txc:NationalOperatorCode', NS)
        operators[op.get('id')] = noc.text if noc is not None else None

    # Service / Line info (there can be multiple <Service> blocks, each with its own JourneyPatterns)
    service_lines = {}      # line id -> line_name
    journey_patterns = {}   # jp id -> dict(route_ref, direction, jps_ref)
    service_code = None

    for service in root.findall('.//txc:Services/txc:Service', NS):
        sc = service.find('txc:ServiceCode', NS)
        service_code = sc.text if sc is not None else service_code

        for line in service.findall('.//txc:Lines/txc:Line', NS):
            ln = line.find('txc:LineName', NS)
            service_lines[line.get('id')] = ln.text if ln is not None else None

        for jp in service.findall('.//txc:JourneyPattern', NS):
            route_ref = jp.find('txc:RouteRef', NS)
            direction = jp.find('txc:Direction', NS)
            jps_refs = jp.find('txc:JourneyPatternSectionRefs', NS)
            journey_patterns[jp.get('id')] = {
                'route_ref': route_ref.text if route_ref is not None else None,
                'direction': direction.text if direction is not None else None,
                'jps_ref': jps_refs.text if jps_refs is not None else None,
            }

    # JourneyPatternSections -> ordered list of (from_stop, to_stop, runtime_sec, jptl_id)
    jps_dict = {}
    for jps in root.findall('.//txc:JourneyPatternSections/txc:JourneyPatternSection', NS):
        links = []
        for link in jps.findall('txc:JourneyPatternTimingLink', NS):
            frm = link.find('txc:From', NS)
            to = link.find('txc:To', NS)
            rt = link.find('txc:RunTime', NS)
            from_stop = frm.find('txc:StopPointRef', NS).text if frm is not None else None
            to_stop = to.find('txc:StopPointRef', NS).text if to is not None else None
            links.append({
                'jptl_id': link.get('id'),
                'from_stop': from_stop,
                'to_stop': to_stop,
                'runtime_sec': parse_runtime(rt.text if rt is not None else None),
            })
        jps_dict[jps.get('id')] = links

    # VehicleJourneys -> one row per stop, per journey
    rows = []
    for vj in root.findall('.//txc:VehicleJourneys/txc:VehicleJourney', NS):
        vj_code = vj.find('txc:VehicleJourneyCode', NS)
        dep_time = vj.find('txc:DepartureTime', NS)
        jp_ref = vj.find('txc:JourneyPatternRef', NS)
        line_ref_el = vj.find('txc:LineRef', NS)
        op_ref = vj.find('txc:OperatorRef', NS)

        jp_info = journey_patterns.get(jp_ref.text if jp_ref is not None else None, {})
        links = jps_dict.get(jp_info.get('jps_ref'), [])

        # Per-vehicle-journey runtime overrides (VehicleJourneyTimingLink), keyed by JPTL ref
        vjtl_overrides = {}
        for vjtl in vj.findall('txc:VehicleJourneyTimingLink', NS):
            jptl_ref = vjtl.find('txc:JourneyPatternTimingLinkRef', NS)
            rt = vjtl.find('txc:RunTime', NS)
            if jptl_ref is not None and rt is not None:
                vjtl_overrides[jptl_ref.text] = parse_runtime(rt.text)

        line_ref_text = line_ref_el.text if line_ref_el is not None else None
        line_name = service_lines.get(line_ref_text)
        noc = operators.get(op_ref.text if op_ref is not None else None)

        if dep_time is not None and dep_time.text:
            h, m, s = map(int, dep_time.text.split(':'))
            cum = h * 3600 + m * 60 + s
        else:
            cum = None

        if not links:
            continue

        # First stop (sequence 0)
        rows.append(dict(
            service_code=service_code, line_ref=line_name, operator_noc=noc,
            vehicle_journey_code=vj_code.text if vj_code is not None else None,
            direction=jp_info.get('direction'), route_ref=jp_info.get('route_ref'),
            stop_sequence=0, stop_point_ref=links[0]['from_stop'],
            stop_name=stop_names.get(links[0]['from_stop']),
            scheduled_time_sec=cum, source_file=os.path.basename(filepath)
        ))

        seq = 0
        for link in links:
            runtime = vjtl_overrides.get(link['jptl_id'], link['runtime_sec'])
            cum = cum + runtime if cum is not None else None
            seq += 1
            rows.append(dict(
                service_code=service_code, line_ref=line_name, operator_noc=noc,
                vehicle_journey_code=vj_code.text if vj_code is not None else None,
                direction=jp_info.get('direction'), route_ref=jp_info.get('route_ref'),
                stop_sequence=seq, stop_point_ref=link['to_stop'],
                stop_name=stop_names.get(link['to_stop']),
                scheduled_time_sec=cum, source_file=os.path.basename(filepath)
            ))

    return rows


def build_timetable_df(folder_or_file):
    all_rows = []
    if os.path.isdir(folder_or_file):
        files = glob.glob(os.path.join(folder_or_file, "*.xml"))
    else:
        files = [folder_or_file]

    for f in files:
        try:
            rows = parse_transxchange_file(f)
            all_rows.extend(rows)
            print(f"Parsed {os.path.basename(f)}: {len(rows)} rows")
        except Exception as e:
            print(f"FAILED on {os.path.basename(f)}: {e}")

    df = pd.DataFrame(all_rows)
    return df


def compute_scheduled_headway(df):
    """For each route (line_ref + direction), compute the average gap between
    consecutive scheduled departure times -> scheduled_headway_sec."""
    departures = (
        df[df['stop_sequence'] == 0]
        .dropna(subset=['scheduled_time_sec'])
        .sort_values(['line_ref', 'direction', 'scheduled_time_sec'])
    )
    records = []
    for (line_ref, direction), grp in departures.groupby(['line_ref', 'direction']):
        times = grp['scheduled_time_sec'].values
        if len(times) > 1:
            gaps = [times[i+1] - times[i] for i in range(len(times)-1) if times[i+1] > times[i]]
            avg_headway = sum(gaps) / len(gaps) if gaps else None
        else:
            avg_headway = None
        records.append({'line_ref': line_ref, 'direction': direction,
                         'route_name': f"Route {line_ref}", 'scheduled_headway_sec': avg_headway,
                         'n_departures': len(times)})
    headway_df = pd.DataFrame(records)
    # Collapse to one row per line_ref (average across directions), fill missing with a sane default
    route_headway = (
        headway_df.groupby('line_ref', as_index=False)
        .agg(route_name=('route_name', 'first'),
             scheduled_headway_sec=('scheduled_headway_sec', 'mean'),
             n_departures=('n_departures', 'sum'))
    )
    route_headway['scheduled_headway_sec'] = route_headway['scheduled_headway_sec'].fillna(900)
    return route_headway


if __name__ == "__main__":
    import sys
    input_path = sys.argv[1] if len(sys.argv) > 1 else "."
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "data"
    os.makedirs(output_dir, exist_ok=True)

    df = build_timetable_df(input_path)
    print(f"\nTotal rows parsed: {len(df)}")

    if len(df) == 0:
        print("No rows parsed — check the input path/file.")
        sys.exit(1)

    timetable_path = os.path.join(output_dir, "timetable_clean.csv")
    df.to_csv(timetable_path, index=False)
    print(f"Saved {timetable_path}")

    route_headway = compute_scheduled_headway(df)
    headway_path = os.path.join(output_dir, "routes_scheduled_headway.csv")
    route_headway.to_csv(headway_path, index=False)
    print(f"Saved {headway_path}")
    print(f"\nRoutes found: {len(route_headway)}")
    print(route_headway.head(20))
