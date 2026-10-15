#!/usr/bin/env python3
"""Flatten the DataSF supervisor-district GeoJSON into two CSVs.

Input : data-raw/sf-supervisor-districts.geojson
        (DataSF "Current Supervisor Districts", https://data.sf.gov/, dataset f2zs-jevy)
Output: data-raw/district-polygons.csv  one row per vertex
        data-raw/district-meta.csv      one row per district

Run from the package root:  python3 data-raw/01-geojson-to-csv.py
The .rda files consumed by the package are then built by 02-build-rda.R.
"""
import csv
import json
import os

# Parts lying west of this meridian are the offshore Farallon Islands
# jurisdiction (legally District 4). Keeping them in the default plot window
# would shrink the city itself to a sliver, so they are flagged and hidden
# unless explicitly requested.
OFFSHORE_LON = -122.6

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
src = os.path.join(root, "data-raw", "sf-supervisor-districts.geojson")

with open(src) as fh:
    gj = json.load(fh)

vertex_rows = []
meta_rows = []

for feat in gj["features"]:
    props = feat["properties"]
    geom = feat["geometry"]
    district = int(float(props["sup_dist"]))
    supervisor = props.get("sup_name") or ""

    if geom["type"] == "Polygon":
        polys = [geom["coordinates"]]
    elif geom["type"] == "MultiPolygon":
        polys = geom["coordinates"]
    else:
        raise ValueError("unexpected geometry type: " + geom["type"])

    for pi, poly in enumerate(polys, start=1):
        for ri, ring in enumerate(poly, start=1):
            # ring 1 is the outer boundary; any further rings are holes
            hole = 1 if ri > 1 else 0
            part = "%d.%d.%d" % (district, pi, ri)
            offshore = 1 if max(c[0] for c in ring) < OFFSHORE_LON else 0
            for lon, lat in ring:
                vertex_rows.append((round(lon, 6), round(lat, 6), part,
                                    district, hole, offshore))

    meta_rows.append((district, supervisor))

vpath = os.path.join(root, "data-raw", "district-polygons.csv")
with open(vpath, "w", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["long", "lat", "part", "district", "hole", "offshore"])
    w.writerows(vertex_rows)

mpath = os.path.join(root, "data-raw", "district-meta.csv")
with open(mpath, "w", newline="") as fh:
    w = csv.writer(fh)
    w.writerow(["district", "supervisor"])
    w.writerows(sorted(meta_rows))

print("districts: %d" % len(meta_rows))
print("vertices : %d" % len(vertex_rows))
print("parts    : %d" % len({r[2] for r in vertex_rows}))
print("offshore : %d" % len({r[2] for r in vertex_rows if r[5]}))
