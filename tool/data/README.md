# Fraunhofer Truck Parking Dataset

This directory documents the external Fraunhofer dataset used to seed the
TruckPark Share parking database.

## Source

European Truck Parking Locations
KAMO Update (v04)

Authors:
- Steffen Link
- Patrick Plötz
- Daniel Speth
- Till Gnann

Affiliation:
Fraunhofer Institute for Systems and Innovation Research

Dataset DOI:
10.5281/zenodo.14643147

Source:
https://zenodo.org/records/14643147

## Dataset version

Version: v04
Publication date: 2025-01-24
Expected parking locations: 13,323

## Expected files

- `truckParkingLocationsEurope_N13323_v04.csv`
- `codebook_v04.csv`

The raw CSV files are intentionally not stored in the TruckPark Share
Git repository. They are external source data and are downloaded from the
official Zenodo record when required.

The v04 Zenodo record does not currently display a specific license in its
public Rights/License field. Therefore TruckPark Share does not redistribute
the raw v04 CSV files through GitHub.

## Dataset integrity

### truckParkingLocationsEurope_N13323_v04.csv

MD5:

`f5b04dcfcabd7ea61d47e62b429543b8`

### codebook_v04.csv

MD5:

`91c050ca4975378549d7dd5e591dab08`

## Local validation

Run from the repository root:

`dart run tool/scripts/validate_fraunhofer_dataset.dart`

The dataset is used as an initial seed for the TruckPark Share parking
database. Community-created and community-updated parking information is
expected to complement and improve the imported source data over time.
