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
Layer controls and popups can be switched between Spanish and English.


## Data

Mobile noise measurements with sound level, speed, heading, GPS accuracy
and a device calibration gain, from the NoiseCapture crowdsourced
dataset ([Noise-Planet](https://noise-planet.org/), UMRAE and Lab-STICC,
distributed under [ODbL](https://opendatacommons.org/licenses/odbl/)).
Measurements come from an Android app, which explains the wide spread in
device calibration gain. The data is hierarchical: samples belong to
tracks, and tracks to urban areas. Records were filtered by
spatio-temporal quality criteria and accuracy thresholds, and timestamps
corrected to local time.

## Approach

**Spatial dependence.** Moran's I and LISA showed global spatial
autocorrelation and local clusters in noise levels. GWR was used to
explore how the associations with speed and movement direction varied
across the study areas.

**Local regression.** Geographically Weighted Regression with two
specifications of movement direction: directional (0–360°) and axial
(0° ≡ 180°). The axial specification treats opposite headings as
equivalent. It was included to examine whether noise patterns were
better represented by the axis of movement than by its direction.
Area-level variables were added to capture local context.

**Handling device calibration.** Tracks are not a useful grouping for
context, since samples from one track can be far apart in space and
time. But calibration gain is a device property, and residuals turned
out to be heteroscedastic against it (GAM on var(gain): p < 2e-16,
SD95/05 ≈ 1.29). This was handled in two steps. First, a robust LOESS of
residual on gain gives a bias estimate that is subtracted and re-centred.
Second, since variance still differs by gain level, anomaly thresholds
were computed per gain bin from the local residual distribution, so the
criterion adapts to local variance rather than applying one cutoff
everywhere.

## Operational labels

Each location is assigned a regime based on which of its local
coefficients dominates.

| Label | Interpretation |
|---|---|
| Speed-dominant | Noise tracks vehicle speed; direction matters little. |
| Urban canyon / directional | Orientation dominates: the same speed sounds different depending on the axis of travel. Typical of enclosed streets. |
| Stationary base | High local baseline with weak speed and orientation effects. Noise comes from the surroundings rather than from passing traffic. |
| Uniform noise | All effects weak and the level close to the local baseline. |
| Transitional / mixed | Speed and orientation effects are comparable, with neither dominating. |
| Anomalous / review | Residual exceeds the calibration-adjusted threshold for its gain bin. Flagged for inspection rather than interpreted. |

## Findings

**Calibration-aware thresholds change the anomaly count by an order of
magnitude.** A fixed 5 dB cutoff flags 24% of points as anomalous; the
calibration-aware criterion brings that to 2%. The rate stays flat
across calibration levels (1–2% in every gain bin) rather than
concentrating on noisier devices. After the correction, track-level gain
shows almost no correlation with median residual (−0.20 to +0.14 across
the four cases). The maps keep both layers so the difference can be
inspected directly.

**The directional term behaves very differently in each city.** The
median alignment coefficient is +4.6 by day and +6.8 at night in
Gandhinagar, against +1.1 in Geneva in both periods. Orientation carries
four to six times more weight there. The axial model won selection only
in Geneva at night, where it also left the cleanest residuals of the
four cases (Moran's I on residuals 0.08, against 0.19 to 0.24
elsewhere). Both specifications use the same number of predictors and
interaction terms, differing in how movement direction is represented.

**Weekend effects differed between cities and were larger at night.**

| | locations | median β_weekend | dominant pattern |
|---|---|---|---|
| Gandhinagar, day | 1104 | −0.6 dB | mixed: 35% quieter, 35% louder |
| Gandhinagar, night | 573 | −5.8 dB | 79% quieter |
| Geneva, day | 214 | +1.7 dB | 67% louder, no significant decreases |
| Geneva, night | 325 | +6.0 dB | 75% louder, no significant decreases |

In daytime Gandhinagar the median effect is essentially zero, yet 70% of
locations show a distinguishable one, split evenly between quieter and
louder weekends along different corridors. The local estimates show
opposite weekend patterns within the city, which are not captured by the
near-zero median effect.

**Model fit varied across the assigned labels.** Urban-canyon locations
fit best (median |residual| 1.7 to 1.8 dB, local R² up to 0.95 at night)
and speed-dominant worst among the regular regimes (R² 0.68). The
anomalous class isolates median residuals of 14.7 to 15.6 dB in under 2%
of points. Model-wide R² ranges from 0.74 to 0.81.

## Limitations

- Median speeds differ sharply between cities (≈39 km/h in Gandhinagar
  by day, ≈5 km/h in Geneva), so measurements were collected in
  different modes: vehicle-borne versus pedestrian. Baseline levels are
  not directly comparable (median intercept 74.9 vs 53.0 dB by day),
  only spatial and temporal structure is.

- Calibration also differs structurally. Gain is near-constant in Geneva
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

## Data licence

Noise data from the NoiseCapture project (Noise-Planet, UMRAE and
Lab-STICC), used under the Open Database License (ODbL).
