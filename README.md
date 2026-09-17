# Spatial structure of urban noise

Can urban traffic dynamics be inferred from the spatial structure of
noise levels? This project analyzes crowdsourced noise measurements in
Geneva (Switzerland) and Gandhinagar (India), across day/night and
weekday/weekend.

## Interactive maps

- [Gandhinagar — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_dia.html)
- [Gandhinagar — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_noche.html)
- [Geneva — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_dia.html)
- [Geneva — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_noche.html)

Built with leaflet in R. They open in any browser, no installation needed.
Layer controls and popups are in Spanish.

## Data

Mobile noise measurements with sound level, speed, heading, GPS accuracy
and a device calibration gain. The data is hierarchical: samples belong
to tracks, and tracks to urban areas. Records were filtered by
spatio-temporal quality criteria and accuracy thresholds, and timestamps
corrected to local time.

## Approach

**Spatial dependence.** Moran's I and LISA showed both global
autocorrelation and relationships that vary across space, ruling out a
global OLS model.

**Local regression.** Geographically Weighted Regression with two
specifications of movement direction: directional (0–360°) and axial
(0° ≡ 180°). The axial form follows from the physics: relative speed and
direction affect measured noise regardless of which way the source
travels. Area-level variables were added to capture local context.

**Handling device calibration.** Tracks are not a useful grouping for
context, since samples from one track can be far apart in space and
time. But calibration gain is a device property, and residuals turned
out to be heteroscedastic against it (GAM on var(gain): p < 2e-16,
SD95/05 ≈ 1.29). This was handled in two steps: a robust LOESS of
residual on gain gives a bias estimate that is subtracted and
re-centred, and then, because variance still differs by gain level,
anomaly thresholds were computed per gain bin as
U(bin) = max{5 dB, P95(debiased residual | bin)}. A point is flagged as
anomalous when it exceeds its own bin's threshold, so the criterion
adapts to local variance instead of applying one cutoff everywhere.

**Operational labels.** Each location was classified from its local
coefficients into speed-dominant, urban-canyon/directional, stationary
base, uniform noise, transitional, or anomalous.

## Findings

**The directional term behaves very differently in each city.** The
median alignment coefficient is +4.6 (day) and +6.8 (night) in
Gandhinagar, against +1.1 in Geneva in both periods. Orientation carries
four to six times more weight there. This is consistent with the axial
model winning selection only in Geneva at night, where it also left the
cleanest residuals of the four cases (Moran's I on residuals 0.08,
against 0.19–0.24 elsewhere): where the directional effect is small,
folding the angle loses little and gains parsimony.

**Opposite weekend signatures, widening at night.**

| | locations | median β_weekend | dominant pattern |
|---|---|---|---|
| Gandhinagar, day | 1104 | −0.6 dB | mixed: 35% quieter, 35% louder |
| Gandhinagar, night | 573 | −5.8 dB | 79% quieter |
| Geneva, day | 214 | +1.7 dB | 67% louder, no significant decreases |
| Geneva, night | 325 | +6.0 dB | 75% louder, no significant decreases |

In daytime Gandhinagar the median effect is essentially zero, yet 70% of
locations show a distinguishable one, split evenly between quieter and
louder weekends along different corridors. A global model would report
no weekend effect there; GWR recovers two opposing ones that cancel out.

**The labelling separates model performance cleanly.** Urban-canyon
locations fit best (median |residual| 1.7–1.8 dB, local R² up to 0.95 at
night), speed-dominant worst among regular regimes (R² 0.68), and the
anomalous class isolates median residuals of 14.7–15.6 dB in under 2% of
points. Model-wide R² ranges from 0.74 to 0.81.

## Limitations

- Median speeds differ sharply between cities (≈39 km/h in Gandhinagar
  by day, ≈5 km/h in Geneva), so measurements were collected in
  different modes — vehicle-borne versus pedestrian. Baseline levels are
  not directly comparable (median intercept 74.9 vs 53.0 dB by day);
  only spatial and temporal structure is.

- Calibration also differs structurally: gain is near-constant in Geneva
  (−14.4 dB across almost all tracks) and widely dispersed in
  Gandhinagar (−35 to +25 dB).

- The weekend subset is not representative in speed. Locations with
  enough weekday/weekend mix to estimate β have a median speed of
  16.6 km/h at night in Gandhinagar, against 38 km/h for the full set.

- Large residuals concentrate in tracks with one or two observations,
  which the local model cannot fit well. Filtering short tracks is an
  open improvement.

- GWR local estimates are spatially correlated, so |z| ≥ 2 flags
  locations worth attention rather than independent significance tests.

## Contents

- `*.html` — standalone interactive maps

## Authors

Analysis and maps in this repository: Cristian Antonio.
Part of a two-person final project for the Spatial Statistics course at
Universidad de Buenos Aires (2025), together with Ezequiel Grenat.
