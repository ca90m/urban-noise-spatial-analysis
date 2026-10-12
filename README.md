# Spatial structure of urban noise

**English** | [Español](README.es.md)

Can urban traffic dynamics be inferred from the spatial structure of noise
levels? This project analyses crowdsourced NoiseCapture measurements from
Geneva (Switzerland) and Gandhinagar (India), by day and at night. Beyond
describing spatial patterns, it assesses how much they depend on the tracks
used for measuring, what holds once that structure is modelled, and what can
be anticipated out of sample.

![Noise measurements in Geneva](figures/portada_en.jpg)

*NoiseCapture measurements in Geneva, coloured by noise level.*

## Summary

- **The patterns on the maps depend heavily on the tracks.** Between 62% and
  77% of the variation in level lies between tracks, and local R² and residual
  autocorrelation largely reflect that structure. In Gandhinagar, GWR
  associates differences of 10 to 14 dB with heading; in models that separate
  tracks, those differences are much smaller (1 to 6 dB) and their size
  depends on how that structure is represented. In nighttime Gandhinagar, the
  within-track heading association with temporal correlation depends on how
  two pairs of records with coincident times are handled.
- **Adding a spatial surface reduces the estimated variance between tracks
  much more in Geneva than in Gandhinagar.** In Geneva it falls by 45% to 72%,
  although that reduction depends on the model and on how much tracks overlap,
  and it does not separately identify how much is due to place and how much to
  measurement conditions. In Gandhinagar, per-track offsets remain at 10 to
  12 dB and are associated with calibration gain, which is consistent with
  differences in devices or measurement conditions; there, the local GWR level
  departs from the level of the spatial surface by a median of 5 to 13 dB,
  almost all of it carry-over from those offsets.
- **Speed is associated with more noise within tracks in Gandhinagar and in
  nighttime Geneva** (0.45 to 0.7 dB per m/s), also with temporal correlation
  and, in Gandhinagar, within the vehicular speed range. In daytime Geneva,
  measured mostly on foot, the positive association given by fixed effects
  (1.5 dB per m/s with the same covariates) vanishes once temporal correlation
  is modelled (−0.02 ± 0.30), and does not appear once place is added or among
  points in the walking-compatible range either. The
  weekend is compared almost exclusively across different tracks, and its estimate
  changes a lot depending on what is taken into account.
- **Labels are sensitive to the estimated offsets, and some locations have
  very few tracks to check them against.** Without the offsets, agreement with
  the original labels is low (kappa of 0.2 to 0.5), and at night 25% to 30% of
  locations have fewer than two effective tracks. In Gandhinagar, the
  stationary base disappears where a single track dominates and holds where
  four or more contribute; in Geneva it cannot be checked, because there are
  hardly any other tracks nearby. More tracks make it possible to check a
  label, but do not guarantee that it is stable.
- **The models describe the sample but say little about new tracks.** For a
  new track, GWR's mean absolute error was 8.6 to 12.3 dB, close to that of
  the mean (9.7 to 12.0 dB). Knowing the start of the track cuts the error
  substantially, but no model clearly improves on the mean level of that
  start.
- **The cities were measured differently:** judging by speed, mostly from
  vehicles in Gandhinagar and on foot in daytime Geneva, so comparisons are limited to
  spatial and temporal structure. The results describe associations, not
  causal effects.

## Interactive maps

- [Gandhinagar: day](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_dia.html)
- [Gandhinagar: night](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_noche.html)
- [Geneva: day](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_dia.html)
- [Geneva: night](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_noche.html)

The maps are exploratory: they show the main GWR (local coefficients,
residuals, labels and weekend effects), and its coefficients mix differences
within each track and between tracks. The
[detailed analysis](detailed-analysis.md) shows how much of each effect
remains once they are separated. They were built with leaflet in R, open in
any browser and can switch between English and Spanish.

## Data

Mobile NoiseCapture measurements ([Noise-Planet](https://noise-planet.org/),
UMRAE and Lab-STICC, distributed under
[ODbL](https://opendatacommons.org/licenses/odbl/)), taken with an Android
app: sound level, speed, heading, GPS accuracy and device calibration gain.
Each measurement belongs to a track. Records were filtered by spatiotemporal
quality and accuracy, and timestamps were converted to local time.

## How it was analysed

1. **Geographically weighted regression (GWR)**, with heading in a directional
   (0–360°) and an axial (0° ≡ 180°) version, after checking spatial
   dependence with Moran's I and LISA. Its coefficients were used to assign an
   operational label to each location.
2. **Device calibration:** bias correction by gain and anomaly thresholds by
   gain level.
3. **Out-of-sample validation**, leaving out whole tracks, and calibration with
   the start of each track.
4. **Models with track structure:** hierarchical with gain-dependent variance,
   fixed effects, and a within-between (Mundlak) model with and without
   temporal correlation.
5. **Effective number of tracks** behind each local estimate.
6. **Spatial additive model with a track effect**, which separates a spatial
   surface from each track's offset, and GWR without those offsets; with
   variants using only the level surface and no temporal correlation.
7. **Measurement mode:** within-track speed slopes in the ranges consistent
   with walking and with travelling in a vehicle.
8. **Sensitivity to heading encoding** in nighttime Gandhinagar, where the
   selection criterion and AICc choose different versions.

Equations, all tables and limitations are in the
[detailed analysis](detailed-analysis.md).

## Main results

**How much the tracks weigh.**

| | Variation between tracks | Heading: maps → without offsets (median amplitude) | Speed within tracks (dB per m/s) |
|---|---|---|---|
| Gandhinagar, day | 77% | 4.9 → 1.7 dB | 0.56 (0.04) |
| Gandhinagar, night | 74% | 7.1 → 3.0 dB | 0.68 (0.06) |
| Geneva, day | 62% | 1.6 → 1.8 dB | −0.02 (0.30) |
| Geneva, night | 64% | 2.6 → 2.6 dB | 0.70 (0.13) |

The amplitude is half the difference between the loudest and the quietest
heading: 4.9 and 7.1 dB correspond to the 10 to 14 dB differences on the maps.
Speed comes from the within-between model with temporal correlation; standard
errors in parentheses. In nighttime Gandhinagar, with a 2 s separation from the
GPS for two pairs of records with coincident times, it is 0.59.

**Spatial surface and offsets.**

| | Offset standard deviation: without → with place | Reduction in its variance | Offset and gain (Spearman) | $\kappa$ of labels without offsets |
|---|---|---|---|---|
| Gandhinagar, day | 12.4 → 11.9 dB | 7% | 0.59 | 0.22 |
| Gandhinagar, night | 10.2 → 10.4 dB | none | 0.57 | 0.25 |
| Geneva, day | 9.9 → 5.2 dB | 72% | 0.01 | 0.20 |
| Geneva, night | 10.0 → 7.4 dB | 45% | 0.15 | 0.47 |

Kappa compares the original labels with those recomputed after removing each
track's estimated offset; 1 would be full agreement and 0 the agreement
expected by chance.

**Prediction.** Mean absolute error, in dB, in two different scenarios:

| | New track: GWR | New track: mean | Given its start: random intercept | Given its start: mean level of the start |
|---|---|---|---|---|
| Gandhinagar, day | 8.6 | 9.7 | 4.5 | 4.6 |
| Gandhinagar, night | 11.7 | 12.0 | 5.6 | 5.9 |
| Geneva, day | 10.9 | 11.0 | 7.4 | 7.3 |
| Geneva, night | 12.3 | 11.9 | 7.3 | 7.1 |

The first scenario predicts tracks left out of the fit. In the second, the
first 20% of the observations of each of those tracks, in time order, is used
to estimate its offset, and the error is measured on the rest. The random
intercept is a model with its own level per track and a common residual
variance. There, no model improves significantly on the
mean level of the start (paired Wilcoxon test, p ≥ 0.10), and calibrated GWR
does worse (7.9 to 11.7 dB).

## Conclusion

The spatial patterns on the maps were sensitive to the track structure and
did not translate into a consistent predictive advantage for new tracks. The
association with speed and, to a lesser extent, with heading held once that structure was
represented, but with smaller magnitudes that depend on how it is
represented, and they cannot be attributed exclusively to traffic, the device
or the way of measuring. Where a place was measured by one or two tracks, the
street cannot be separated from the track.

## Main limitations

- The cities were measured differently, so the share of their differences due
  to the city rather than the measurement mode cannot be separated.
- The estimated offsets capture everything specific to each track (device,
  how it was carried, timing, mode and, without a spatial surface, place too);
  they are not a separately identified instrumental error.
- Separating place from track relies on crossings between tracks: only 21% to
  44% of points have another track within 50 m.
- GWR local standard errors treat every point as independent, so
  $\lvert z \rvert \ge 2$ flags locations worth attention rather than
  significance tests.
- In nighttime Gandhinagar, the within-track heading effect with temporal
  correlation is not robust: with a 2 s separation from the GPS for two pairs
  of records with coincident times, it is no longer distinguishable from zero
  (p = 0.63). Models without temporal correlation do show it.
- In nighttime Gandhinagar, the labels on the map depend on how heading is
  encoded: with the directional version, which AICc prefers, they agree at 55%
  of locations. The aggregate conclusions do not change.

The full list is in the
[detailed analysis](detailed-analysis.md#limitations).

## Contents

- `README.md` and `README.es.md`: this front page, in English and Spanish.
- `detailed-analysis.md` and `analisis-detallado.md`: methodology, tables,
  interpretation, limitations and references.
- `*.html`: self-contained interactive maps.
- `figures/`: charts.

## Authors

Analysis and maps in this repository: Cristian Antonio.
Part of a final project for the Spatial Statistics course at the
University of Buenos Aires (2025), carried out with Ezequiel Grenat.

## Data licence

Noise data from the NoiseCapture project (Noise-Planet, UMRAE and Lab-STICC),
used under the Open Database License (ODbL).
