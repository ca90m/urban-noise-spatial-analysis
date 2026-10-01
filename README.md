# Spatial structure of urban noise

**English** | [Español](README.es.md)

Can urban traffic dynamics be inferred from the spatial structure of
noise levels? This project analyzes crowdsourced noise measurements in
Geneva (Switzerland) and Gandhinagar (India), across day/night and
weekday/weekend.

## Interactive maps

- [Gandhinagar — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_dia.html)
- [Gandhinagar — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_noche.html)
- [Geneva — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_dia.html)
- [Geneva — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_noche.html)

The maps show the main models, which include the area's baseline level.
Variants without that predictor were used for sensitivity analysis; their
results are summarized below.

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

**Local regression.** Geographically Weighted Regression (GWR) was fitted with
two representations of heading: directional (0–360°), which distinguishes
opposite directions of travel, and axial (0° ≡ 180°), which treats them as
equivalent. The comparison aimed to assess whether noise levels were mainly
associated with the axis of movement or whether distinguishing the direction
of travel added information. Area-level variables were also included to
represent local context.

Street geometry and sound reflections between façades motivated examining
patterns associated with the axis of travel. Differences in exposure to sound
sources and variation in sound emission across directions could also produce
differences between opposite directions of travel. The possible role of the
Doppler effect was also considered, linked to relative motion between source
and receiver and the change in the received frequency.

The recorded heading describes the movement of the person taking the
measurements and does not directly identify the direction from which sound
arrives. The comparison therefore helps assess which representation of heading
is more useful, although differences in model fit alone cannot identify the
physical mechanisms behind the observed patterns.

**Model specification.** For each measurement $i$ at location $u_i$, the
noise level $L_i$ (dB) is modelled as:

```math
\begin{aligned}
L_i ={}& \beta_0(u_i) + \beta_{\text{speed}}(u_i)\,v_i
       + \beta_{\cos}(u_i)\,\tilde c_i + \beta_{\sin}(u_i)\,\tilde s_i
       + v_i\big[\gamma_{\cos}(u_i)\,\tilde c_i + \gamma_{\sin}(u_i)\,\tilde s_i\big] \\
      &+ \beta_{\text{hs}}(u_i)\,h^s_i + \beta_{\text{hc}}(u_i)\,h^c_i
       + \beta_{\text{base}}(u_i)\,b_i + \beta_{\text{count}}(u_i)\,m_i
       + \beta_{\text{weekend}}(u_i)\,w_i + \varepsilon_i
\end{aligned}
```

All coefficients vary with location: GWR estimates them at each point,
weighting nearby observations more. $v_i$ is standardized speed. $\tilde c_i$
and $\tilde s_i$ are the cosine and sine of heading $\theta_i$, centred on
their mean: $\cos\theta_i$ and $\sin\theta_i$ in the directional model,
$\cos 2\theta_i$ and $\sin 2\theta_i$ in the axial one. The latter take the
same value at $\theta$ and $\theta + 180^\circ$, so opposite directions are not
told apart. The bracketed term lets the heading effect change with speed.

The remaining terms are controls. $h^c_i$ and $h^s_i$ encode hour as the
cosine and sine of $2\pi \cdot \text{hour}_i / 24$, so 23:00 and 00:00 stay
close. $b_i$ is the area's usual level at that hour and on that type of day
(Monday–Friday, Saturday or Sunday), from the NoiseCapture hourly profile (the
median, LA50, of each hour), standardized. If that hour is missing, the area's
overall median is used. $m_i$ is the log of
one plus the
area's measurement count, standardized. $w_i$ is a centred weekend indicator.

Two of these controls enter residualized (i.e. orthogonalized). The hour sine
is replaced by its residual from a linear regression on the cosine, and $b_i$
by its residual from a regression on the hour sine and cosine. This is only a
reparametrization: the fit, the residuals and $\beta_{\text{base}}$ are the same
as without it. What changes is how effects are split across coefficients: the
hour terms carry the full daily cycle, including the part associated with the
area's usual level, and the intercept shifts its reference point.

How to read each coefficient:

| Coefficient | What it measures |
|---|---|
| $\beta_0$ | Local baseline: expected level at mean speed, with the other variables at their reference values. Shown on the maps shifted to zero speed. |
| $\beta_{\text{speed}}$ | dB change per standard deviation of speed, averaged over headings. Shown on the maps in dB per m/s. |
| $\beta_{\cos}$, $\beta_{\sin}$ | Heading effect at mean speed. In the directional model, $\beta_{\cos}$ contrasts travelling north with travelling south, and $\beta_{\sin}$ east with west. In the axial model, $\beta_{\cos}$ contrasts the north–south axis with the east–west axis, and $\beta_{\sin}$ the northeast–southwest axis with the northwest–southeast one. In every case the gap between the two is twice the coefficient, and a positive value means the first is louder. On their own they depend on how the axes are oriented, so they are summarized as $\beta_{\text{align}}$. |
| $\gamma_{\cos}$, $\gamma_{\sin}$ | How much the heading effect changes per standard deviation of speed. Read the other way, whether the speed effect depends on heading. |
| $\beta_{\text{hc}}$, $\beta_{\text{hs}}$ | Jointly describe hourly variation in level within each period (day 07–19, night 19–07) through cosine and sine terms, including the part associated with the area's usual level. |
| $\beta_{\text{base}}$ | Association with the area's usual level, in dB per standard deviation of that level. Used to assign the stationary-base label. |
| $\beta_{\text{count}}$ | dB per standard deviation of the log measurement count. Mainly a control for sampling intensity, with no direct physical reading. |
| $\beta_{\text{weekend}}$ | Local weekend-minus-weekday difference in level, in dB, beyond what the area's usual level for each type of day already reflects. |
| $\beta_{\text{align}}$ | Amplitude of the heading effect, in dB. See below. |

Both variants share the same terms and differ only in heading encoding.
Bandwidth is adaptive and was selected by AICc together with the kernel
(Gaussian or bisquare). The variant with the higher mean local R² was kept,
with AICc as tie-breaker.

For the weekend effect, a variant without the area's baseline level was also
fitted, on the same observations, with the same heading encoding and the same
spatial weights (kernel and bandwidth) as the main model. That
control is built from the measurements themselves and distinguishes by type of
day, so it can absorb part of the weekend–weekday contrast. Comparing both
versions shows how much that result depends on the control.

**Alignment coefficient.** The heading effect is summarized as one value per
location:

```math
\beta_{\text{align}}(u) = \sqrt{\beta_{\cos}(u)^2 + \beta_{\sin}(u)^2}
```

At mean speed, the heading term is a wave of amplitude $\beta_{\text{align}}$,
with a period of 360° in the directional model and 180° in the axial one.
Depending on heading, the level rises or falls by up to that many dB, so the
loudest and quietest headings differ by twice that. It is never negative.

**Handling device calibration.** Tracks are not a useful grouping for
context, since samples from one track can be far apart in space and
time. But calibration gain is a device property, and residual magnitude changed
with it. This was tested by modelling $\log r_i^2$ against gain: a GAM in
Gandhinagar, an ANOVA in Geneva, where gain takes few distinct values.
Measured around zero, this magnitude reflects both spread and bias. In daytime
Gandhinagar the effect was significant (p < 2e-16), with typical residual
magnitude at the 95th gain percentile about 1.18 times that at the 5th. In
daytime Geneva it was also significant (p = 9.3e-08), but reversed (0.72).

This was handled in two steps. First, a robust LOESS $\hat b(g)$ of residual
on gain gives a bias estimate that is subtracted and re-centred:

```math
r^{\text{db}}_i = r_i - \hat b(g_i) - \operatorname{median}\big(r - \hat b(g)\big)
```

Second, since variance still differs by gain level, anomaly thresholds were
computed per gain bin $k$ (≤ −20, −20 to −15, −15 to −12, > −12 dB) from the
local residual distribution:

```math
U_k = \max\big\{\,5\ \text{dB},\ \mathrm{P}_{95}\big(|r^{\text{db}}| \text{ within bin } k\big)\big\}
```

Bins with under 100 points use the global 95th percentile. A point is flagged
only if it exceeds its bin threshold and also belongs to a LISA high-high
cluster of $\lvert r^{\text{db}} \rvert$ (4 nearest neighbours, α = 0.05, residual and
neighbour average both above 5 dB). Isolated errors are left out; areas where
the model fails consistently are kept.

## Operational labels

Each location is assigned a regime based on which of its local
coefficients dominates. Coefficients are compared against their own
distribution within each city and period, so labels are relative: they show
which effect stands out locally, not values comparable across cities.

| Label | Interpretation |
|---|---|
| Speed-dominant | Noise tracks travel speed; direction matters little. |
| Urban canyon / directional | Orientation dominates: the same speed sounds different depending on the axis of travel. Consistent with enclosed streets. |
| Stationary base | High local baseline with weak speed and orientation effects. The level depends more on the place than on how the measurer moves. |
| Uniform noise | Speed and orientation tied or relatively weak, with the predicted level within 3 dB of the intercept and the intercept near the case median. |
| Transitional / mixed | No clear dominance of speed or orientation under the assignment rules: their normalized magnitudes are comparable or both are relatively low. |
| Anomalous / review | Residual exceeds the calibration-adjusted threshold for its gain bin and sits in a cluster of high residuals. Flagged for inspection rather than interpreted. |

### Assignment rules

Speed and alignment coefficients are normalized by their 75th percentile
within each case:

```math
s_i = \frac{|\beta_{\text{speed},i}|}{\mathrm{P}_{75}\big(|\beta_{\text{speed}}|\big)},
\qquad
a_i = \frac{\beta_{\text{align},i}}{\mathrm{P}_{75}\big(\beta_{\text{align}}\big)}
```

An effect is strong if $\max(s_i, a_i) \ge 0.8$, and the two are tied if
$s_i / a_i$ lies between $1/1.2$ and $1.2$. Labels are assigned in this order,
and each point gets the first one it meets:

1. **Anomalous / review**: meets the anomaly criterion under device
   calibration.
2. **Speed-dominant**: a strong effect and $s_i / a_i > 1.2$.
3. **Urban canyon / directional**: a strong effect and $s_i / a_i < 1/1.2$.
4. **Stationary base**: the intercept exceeds its 75th percentile, or $\beta_{\text{base}}$
   exceeds the median of $\lvert \beta_{\text{base}} \rvert$ plus its MAD; and neither speed nor
   alignment exceeds its 75th percentile.
5. **Transitional / mixed**: everything else, i.e. ties or both effects weak.

Finally, a non-anomalous point with a tie or weak effects becomes **uniform
noise** if its predicted level is within 3 dB of its intercept and the
intercept is near the median (within 0.33 IQR).

## Findings

**The anomaly criterion cuts flagged points by an order of magnitude.**
Depending on the case, a fixed 5 dB cutoff flags 21% to 26% of points.
Requiring a spatial cluster of high residuals (LISA high-high) brings that to
3–6%, and the per-gain-bin threshold to 1.0–2.2%. The final rate per gain bin
ranges from 0% to 3%; an even rate is partly expected by construction, since
each threshold is a within-bin percentile. In Geneva at night, 13 of the 18
anomalies come from devices with a −22.5 dB gain. As an additional diagnostic,
the Spearman correlation between each track's median gain and its share of
anomalous points was computed. It was weak in Gandhinagar (−0.07 by day,
+0.19 at night; p ≥ 0.07) and negative in Geneva (−0.25 by day, −0.30 at
night; p ≈ 0.04 and 0.05): there, lower-gain tracks tend to have more
anomalies. With four tests, none of these correlations survives a
multiple-comparison correction. The maps keep the separate layers so the difference can be
inspected directly.

**The directional term behaves very differently in each city.** The
median alignment coefficient is 4.8 dB by day and 7.0 dB at night in
Gandhinagar, against 0.6 dB in Geneva in both periods. At each case's mean
speed, that means typical gaps of 10 to 14 dB between loudest and quietest
heading in Gandhinagar, and about 1 dB in Geneva. The axial model won
selection only in Geneva at night, where it also left the cleanest residuals
of the four cases (Moran's I on residuals 0.01, against 0.05 to 0.27
elsewhere). Both specifications use the same number of predictors and
interaction terms, differing in how movement direction is represented.

**Weekend effects differed between cities and were larger at night.** Since
$\beta_{\text{weekend}}$ is adjusted for the area's profile by type of day, it does not
represent the total weekend–weekday difference.

| | locations | median $\beta_{\text{weekend}}$ | dominant pattern |
|---|---|---|---|
| Gandhinagar, day | 1145 | −1.5 dB | mixed: 45% quieter, 36% louder |
| Gandhinagar, night | 732 | −4.3 dB | 58% quieter, 15% louder |
| Geneva, day | 214 | +0.1 dB | no location with $\lvert z \rvert \ge 2$ |
| Geneva, night | 325 | +1.4 dB | 18% louder, no significant decreases |

**How $\beta_{\text{weekend}}$ is estimated and filtered.** It is the coefficient on the weekend indicator: the local
weekend-minus-weekday difference, in dB, adjusted for the other model terms.
It is reported only where it can be estimated reasonably: among the $k$ nearest
neighbours (10% of points, bounded to 30–150), 10–90% of measurements are from
weekends, local R² is at least 0.5, and the effect is within ±12 dB. An effect
counts as distinguishable when the coefficient is at least twice its standard
error in absolute value.

In daytime Gandhinagar the median is −1.5 dB, yet 81% of locations show a
distinguishable effect: 45% quieter and 36% louder, along different
corridors. The local estimates show opposite weekend patterns within the city,
which the median does not capture.

**Sensitivity to the area's baseline level.** The table compares the main
model with a variant without that predictor, keeping the same observations,
heading encoding and spatial weights. Only locations meeting the reporting
criteria in both versions are summarized. Removing the predictor changes local
R² and the coefficients, so it can also change which locations meet those
criteria, including the ±12 dB limit. These results describe the common subset,
not all estimates or the whole city. This is why the medians with the baseline
differ from those in the previous table.

| | common locations | median with baseline | median without baseline | same sign |
|---|---|---|---|---|
| Gandhinagar, day | 902 | −1.5 dB | −0.3 dB | 96% |
| Gandhinagar, night | 579 | −4.4 dB | −5.7 dB | 96% |
| Geneva, day | 141 | −0.5 dB | +2.7 dB | 66% |
| Geneva, night | 133 | +1.5 dB | +3.7 dB | 99% |

In Gandhinagar and in Geneva at night, the coefficient kept its sign in
roughly 96% or more of the common locations. Within that subset, Gandhinagar
retained predominantly negative nighttime coefficients and a daytime mix of
signs, while Geneva retained predominantly positive nighttime coefficients.
Magnitudes changed when the profile was removed, especially in Geneva. At
night, the median went from +1.5 to +3.7 dB; among the 133 common locations,
20% reached $\lvert z \rvert \ge 2$ without the baseline, against none with it. In daytime
Geneva, the sign agreed in 66% of common locations and the median went from
−0.5 to +2.7 dB.

Removing the baseline also worsened in-sample fit: mean local R² dropped by
0.05 in Gandhinagar and by 0.24 to 0.30 in Geneva, and residual spatial
autocorrelation increased in all four cases. Since the profile is built from
the same measurements, this does not show that the model with the baseline
predicts new observations better, and the comparison cannot separate how much
of its contribution is local context and how much is reuse of the response.

**Model fit varied across the assigned labels, with no ordering common to both
cities.** In Gandhinagar, urban-canyon locations had the lowest mean
|residual| (2.5 dB by day, 2.7 dB at night) and, at night, also the highest
local R² (0.90). In daytime Geneva, urban canyon had the highest local R²
(0.87) and stationary base the lowest mean |residual| (2.8 dB); at night, uniform
noise and stationary base fit best (1.3 and 1.8 dB; R² 0.93 and 0.92).
Speed-dominant locations had the highest mean |residual| among the regular
regimes in three of the four cases (3.9 to 4.2 dB). The anomalous class
isolates mean absolute residuals of 15.5 to 18.0 dB in at most 2.2% of points. Mean
local R² ranges from 0.72 to 0.87.

## Interpretation

In Gandhinagar, where measurements were taken from vehicles, noise is strongly
tied to movement: depending on heading, the level changes by about 10 to 14 dB
at mean speed. This pattern is consistent with traffic corridors with marked
directions of travel, although it could also reflect the vehicle's own noise
or street geometry. Negative nighttime coefficients remained predominant when
the area's baseline level was removed, among locations retained in both
versions.

In Geneva, where measurements were taken on foot, heading matters little and
each area's usual level explains much of the variation. Weekend nights tend to
be louder, but the size of that effect depends on how local context is
controlled for.

Overall, the models show a stronger association with heading in Gandhinagar
and greater sensitivity of fit to the area profile in Geneva. Comparing fits
with and without that profile distinguished sign patterns that persisted from
magnitudes that depended on the control. Differences in measurement mode and
the profile's origin prevent attributing these results solely to the cities.
The findings describe exploratory associations, not causal effects.

## Limitations

- Median speeds differ sharply between cities (≈39 km/h in Gandhinagar
  by day, ≈5 km/h in Geneva), so measurements were collected in
  different modes: vehicle-borne versus pedestrian. Baseline levels are
  not directly comparable (median intercept 75.0 vs 54.2 dB by day),
  only spatial and temporal structure is.

- Calibration also differs structurally. In Geneva, gain takes only a few
  values (four by day, five at night), with most tracks at −22.5 or 0 dB. In
  Gandhinagar it is widely dispersed: −35 to +25 dB by day and up to +64 dB at
  night.

- The weekend subset is not representative in speed. Locations with
  enough weekday/weekend mix to estimate $\beta$ have a median speed of
  17.8 km/h at night in Gandhinagar, against 38 km/h for the full set.

- In Gandhinagar, tracks with one or two observations, which the local model
  cannot fit well, have much larger residuals (median |residual| 6.2 to
  15.1 dB, against about 2.5 dB elsewhere), although they hold under 1% of
  points. In Geneva the difference is small. Filtering short tracks is an open
  improvement.

- The area's usual level and measurement count come from aggregates that
  NoiseCapture computes from the same crowdsourced measurements, so they may
  include the observations being modelled. They are not an independent
  reference, and this dependence can favour in-sample fit; residualizing the
  area level does not remove it. Results are therefore read as exploratory
  associations, not as causal effects or out-of-sample predictive
  validation.

- GWR local estimates are spatially correlated, so $\lvert z \rvert \ge 2$ flags
  locations worth attention rather than independent significance tests.

## Contents

- `README.md`: project overview in English
- `README.es.md`: project overview in Spanish
- `*.html`: standalone interactive maps

## Authors

Analysis and maps in this repository: Cristian Antonio.
Part of a two-person final project for the Spatial Statistics course at
Universidad de Buenos Aires (2025), together with Ezequiel Grenat.

## Data licence

Noise data from the NoiseCapture project (Noise-Planet, UMRAE and
Lab-STICC), used under the Open Database License (ODbL).
