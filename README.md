# Spatial structure of urban noise

Can urban traffic dynamics be inferred from the spatial structure of
noise levels? This project analyzes georeferenced noise measurements
in Geneva (Switzerland) and Gandhinagar (India), comparing daytime and
nighttime patterns.

## Interactive maps

- [Gandhinagar — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_dia.html)
- [Gandhinagar — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_noche.html)
- [Geneva — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_dia.html)
- [Geneva — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_noche.html)

Built with leaflet in R. They open in any browser — no installation needed.
Layer controls and popups are in Spanish.

## Data

Mobile noise measurements including sound level, speed, heading and GPS
accuracy. The data has a nested structure: samples belong to tracks, and
tracks belong to urban areas. Records were filtered by spatio-temporal
quality criteria and accuracy thresholds, and timestamps were corrected
to local time.

## Approach

**Spatial dependence.** Moran's I and LISA to test for global
autocorrelation and identify local clusters. Both indicated spatial
structure and relationships that vary across space, which means a
global OLS model is not appropriate.

**Local regression.** Geographically Weighted Regression with two
specifications of movement direction: a directional model (0–360°) and
an axial model where 0° and 180° are treated as equivalent. The axial
version follows from the physics — relative speed and direction of
movement affect measured noise regardless of which way the source is
travelling.

**Weekday vs weekend.** A local weekend effect (β_weekend) was estimated
at each location, with its z-value and the number of observations in
each group, to test whether noise levels at a given point differ
between weekdays and weekends.

## Findings

- **The weekend effect is strong locally and invisible globally.**
  Across Gandhinagar, the median weekend-vs-weekday difference is about
  −0.6 dB — essentially zero. But 70% of locations show a distinguishable
  effect (|z| ≥ 2), split almost evenly between quieter weekends
  (median −4.6 dB) and louder ones (median +8.9 dB). A global model
  averages these away; GWR recovers them.

- [Qué tipo de zonas quedan de cada lado.]

- [Qué cambia entre día y noche, y entre Gandhinagar y Ginebra.]

## Contents

- `*.html` — standalone interactive maps

## Authors

Analysis and maps in this repository: Cristian Antonio.
Part of a two-person final project for the Spatial Statistics course
at Universidad de Buenos Aires (2025), together with Ezequiel Grenat.
