# Spatial structure of urban noise

**English** | [Español](README.es.md)

Can urban traffic dynamics be inferred from the spatial structure of
noise levels? This project analyzes crowdsourced noise measurements in
Geneva (Switzerland) and Gandhinagar (India), across day/night and
weekday/weekend.

![Noise measurements in Geneva](figures/portada_en.jpg)

*NoiseCapture measurements in Geneva, coloured by noise level.*

## Summary

- **Heading matters about three times more in Gandhinagar than in Geneva.** At
  mean speed, the level typically changes by 10 to 14 dB with heading in
  Gandhinagar, and by 3 to 5 dB in Geneva.
- **In Gandhinagar, weekend nights are quieter at most locations** (median
  −6.4 dB), and that pattern holds with and without the area baseline level.
- **NoiseCapture's hourly profile proved unreliable as a control in Geneva.**
  Most points do not share their hexagon with other tracks, and the fit
  depended heavily on how that profile was built. The main model therefore
  leaves it out.
- **The cities were measured differently,** mostly from vehicles in
  Gandhinagar and mostly on foot in daytime Geneva. Comparisons are therefore
  limited to spatial and temporal structure, and the results describe
  associations, not causal effects.

## Interactive maps

- [Gandhinagar — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_dia.html)
- [Gandhinagar — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_noche.html)
- [Geneva — daytime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_dia.html)
- [Geneva — nighttime](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_noche.html)

The maps show the main models, which do not include the area's baseline
level. The version with that predictor was used for sensitivity analysis; its
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
of travel added information.

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
       + \beta_{\text{count}}(u_i)\,m_i
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
close. The sine enters residualized: it is replaced by its residual from a
linear regression on the cosine (i.e. it is orthogonalized). This is only a
reparametrization: the fit and the residuals do not change. $m_i$ is the log of
one plus the measurement count of the NoiseCapture area containing the point,
standardized. $w_i$ is a centred weekend indicator.

How to read each coefficient:

| Coefficient | What it measures |
|---|---|
| $\beta_0$ | Local baseline: expected level at mean speed, with the other variables at their reference values. Shown on the maps shifted to zero speed. |
| $\beta_{\text{speed}}$ | dB change per standard deviation of speed, averaged over headings. Shown on the maps in dB per m/s. |
| $\beta_{\cos}$, $\beta_{\sin}$ | Heading effect at mean speed. In the directional model, $\beta_{\cos}$ contrasts travelling north with travelling south, and $\beta_{\sin}$ east with west. In the axial model, $\beta_{\cos}$ contrasts the north–south axis with the east–west axis, and $\beta_{\sin}$ the northeast–southwest axis with the northwest–southeast one. In every case the gap between the two is twice the coefficient, and a positive value means the first is louder. On their own they depend on how the axes are oriented, so they are summarized as $\beta_{\text{align}}$. |
| $\gamma_{\cos}$, $\gamma_{\sin}$ | How much the heading effect changes per standard deviation of speed. Read the other way, whether the speed effect depends on heading. |
| $\beta_{\text{hc}}$, $\beta_{\text{hs}}$ | Jointly describe hourly variation in level within each period (day 07–19, night 19–07) through cosine and sine terms. |
| $\beta_{\text{count}}$ | dB per standard deviation of the log measurement count. Mainly a control for sampling intensity, with no direct physical reading. |
| $\beta_{\text{weekend}}$ | Local weekend-minus-weekday difference in level, in dB, adjusted for speed, heading, hour and measurement count. |
| $\beta_{\text{align}}$ | Amplitude of the heading effect, in dB. See below. |

Both variants share the same terms and differ only in heading encoding.
Bandwidth is adaptive and was selected by AICc together with the kernel
(Gaussian or bisquare). The variant with the higher mean local R² was kept,
with AICc as tie-breaker.

**Area baseline level: evaluated and excluded from the main model.**
NoiseCapture publishes, for each hexagon of 15 m radius, an hourly sound-level
profile (the median, LA50, of each hour on weekdays, Saturdays and Sundays).
That profile could serve as a control for local context, but it is computed
from the same crowdsourced measurements being modelled. To assess how much the
fit depended on measurements from the point's own track, an alternative
profile was built from the raw points: for each point, the median of its
hexagon, hour and type of day, excluding every measurement from its own track.
When no other track had measurements in that combination of hour and type of
day, the overall median of the hexagon was used, also excluding the evaluated
track. Three versions of the model were compared on the same observations and
with the same weights: no baseline, the profile without the own track, and
the NoiseCapture profile. The results (see Findings) led to excluding it from
the main model. The version with the NoiseCapture profile is kept as a
sensitivity analysis, with the same observations, heading encoding and spatial
weights as the main model.

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
magnitude at the 95th gain percentile about 1.36 times that at the 5th. In
daytime Geneva it was also significant (p < 2e-16), but reversed (0.71).

This was handled in two steps. First, a robust LOESS $\hat b(g)$ of residual
on gain gives a bias estimate that is subtracted and re-centred:

```math
r^{\text{db}}_i = r_i - \hat b(g_i) - \mathrm{median}\big(r - \hat b(g)\big)
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
| Uniform noise | Speed and orientation effects tied or relatively weak, with the predicted level within 3 dB of the intercept and the intercept close to the case median. |
| Transitional / mixed | No clear dominance of speed or orientation under the rules used: their normalized magnitudes are comparable or both relatively low. |
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
2. **Speed-dominant**: a strong effect and $s_i / a_i \gt 1.2$.
3. **Urban canyon / directional**: a strong effect and $s_i / a_i \lt 1/1.2$.
4. **Stationary base**: the intercept exceeds its 75th percentile, and neither
   speed nor alignment exceeds its 75th percentile.
5. **Transitional / mixed**: everything else, i.e. ties or both effects weak.

Finally, a non-anomalous point with a tie or weak effects becomes **uniform
noise** if its predicted level is within 3 dB of its intercept and the
intercept is near the median (within 0.33 IQR).

## Findings

**The anomaly criterion cuts flagged points by an order of magnitude.**
Depending on the case, a fixed 5 dB cutoff flags 27% to 52% of points.
Requiring a spatial cluster of high residuals (LISA high-high) brings that to
4–8%, and the per-gain-bin threshold to 1.8–2.6%. The final rate per gain bin
ranges from 0% to 3%; an even rate is partly expected by construction, since
each threshold is a within-bin percentile. As an additional diagnostic, the
Spearman correlation between each track's median gain and its share of
anomalous points was computed. It was weak in three cases (−0.11 to +0.01;
p ≥ 0.38). In nighttime Gandhinagar it was +0.26 (p = 0.015): there,
higher-gain tracks tend to have more anomalies. With a Bonferroni correction for the four tests
(threshold 0.0125), that correlation is not significant. The maps keep
the separate layers so the difference can be inspected directly.

**The directional term weighs much more in Gandhinagar than in Geneva.** The
median alignment coefficient is 4.9 dB by day and 7.1 dB at night in
Gandhinagar, against 1.6 and 2.6 dB in Geneva. At each case's mean speed, that
means typical gaps of 10 to 14 dB between loudest and quietest heading in
Gandhinagar, and 3 to 5 dB in Geneva. The axial model won selection only in
Gandhinagar at night, where it also left the cleanest residuals of the four
cases (Moran's I on residuals 0.21, against 0.30 to 0.54 elsewhere). Both
specifications use the same number of predictors and interaction terms,
differing in how movement direction is represented.

![Heading effect by case](figures/alineacion_en.png)

**Weekend effects differed between cities and were larger at night.**

| | locations | median $\beta_{\text{weekend}}$ | dominant pattern |
|---|---|---|---|
| Gandhinagar, day | 906 | −0.2 dB | mixed: 38% quieter, 38% louder |
| Gandhinagar, night | 650 | −6.4 dB | 67% quieter, none louder |
| Geneva, day | 122 | +2.0 dB | 53% louder, 7% quieter |
| Geneva, night | 108 | +7.0 dB | no location with $\lvert z \rvert \ge 2$ |

Percentages of quieter and louder locations refer to estimates reaching
$\lvert z \rvert \ge 2$ among the reported locations, not just to the sign of
the coefficient.

**How $\beta_{\text{weekend}}$ is estimated and filtered.** It is the
coefficient on the weekend indicator: the local weekend-minus-weekday
difference, in dB, adjusted for the other model terms. It is reported only
where it can be estimated reasonably: among the $k$ nearest neighbours (10% of
points, bounded to 30–150), 10–90% of measurements are from weekends, local R²
is at least 0.5, and the effect is within ±12 dB. An effect counts as
distinguishable when the coefficient is at least twice its standard error in
absolute value.

In daytime Gandhinagar the median is close to zero, yet 76% of locations show
a distinguishable effect, split evenly between quieter and louder weekends
along different corridors. At night, by contrast, the decrease clearly
dominates. In nighttime Geneva the median is high, but no location reaches
$\lvert z \rvert \ge 2$: the estimated effect is large and imprecise.

**Model fit was sensitive to how the baseline level was built.** When the own
track is excluded, many points are left with no other measurement in their
hexagon:

| Situation when the own track is excluded | Geneva, day | Geneva, night | Gandhinagar, day |
|---|---|---|---|
| Other tracks in the hexagon, at the same hour and type of day | 3% | 5% | 28% |
| Other tracks in the hexagon, outside that combination of hour and type of day | 36% | 35% | 47% |
| No other track in the hexagon | 61% | 60% | 25% |

In Gandhinagar, percentages refer to points falling inside some hexagon. In the
raw points available for Geneva, most observations do not share their hexagon
with other tracks. On the points that do (957 in daytime Geneva and 2462 in
daytime Gandhinagar), the three model versions gave:

![Evaluation of the area baseline level](figures/evaluacion_nivel_base_en.png)

In daytime Geneva, on the common sample, mean local R² was 0.24 with no
baseline, 0.41 with the reference excluding the own track and 0.71 with the
NoiseCapture profile; residual Moran's I was 0.67, 0.55 and 0.20. The
difference is consistent with a substantial dependence on the measurements of
the point's own track, but it also reflects changes in the availability and
temporal resolution of the predictor: for most of these points, the
alternative reference is the overall median of the hexagon, not that of the
hour. The comparison cannot quantify these components separately. In daytime
Gandhinagar, the three versions fit almost equally well (0.61 to 0.64, with
Moran's I of 0.32 to 0.33): there the baseline adds little. The comparison was
run only for these two cases; it was not evaluated for nighttime Gandhinagar.

**The sensitivity analysis with the baseline confirms that contrast.** The
table compares the main model with the version including the baseline, on the
same observations and with the same spatial weights.

| | mean local R² (without / with) | residual Moran's I (without / with) | common locations | median $\beta_{\text{weekend}}$ (without / with) | same sign |
|---|---|---|---|---|---|
| Gandhinagar, day | 0.68 / 0.72 | 0.30 / 0.28 | 906 | −0.2 / −1.5 dB | 96% |
| Gandhinagar, night | 0.76 / 0.81 | 0.21 / 0.13 | 650 | −6.4 / −4.1 dB | 98% |
| Geneva, day | 0.54 / 0.83 | 0.54 / 0.06 | 122 | +2.0 / −0.5 dB | 73% |
| Geneva, night | 0.60 / 0.85 | 0.30 / −0.01 | 108 | +7.0 / +2.5 dB | 85% |

Mean local R² and Moran's I refer to each case's fitting sample. Weekend
medians and sign-agreement percentages are computed only on locations meeting
the reporting filters in both versions, including the ±12 dB limit. They do not
represent all estimates or the whole city.

In Gandhinagar, adding the baseline improves fit only slightly and the weekend
effect keeps its sign at almost every location; the nighttime decrease holds
in both versions. In Geneva, the baseline raises R² sharply and nearly removes
residual autocorrelation, consistent with it reusing the measurement itself.
With it, none of the compared Geneva locations shows a distinguishable weekend
effect; without it, 53% of daytime Geneva locations are louder at weekends.

![Sensitivity of the weekend effect to the baseline level](figures/sensibilidad_finde_en.png)

**Model fit varied across the assigned labels.** Stationary-base locations had
the highest mean local R² in all four cases (0.73 to 0.84) and the lowest mean
|residual| in three (2.4 to 5.4 dB). In daytime Gandhinagar, the lowest
residual belonged to urban canyon (2.4 dB). Uniform noise fit worst among the
regular regimes in all four cases (mean local R² 0.41 to 0.62). The anomalous
class isolates mean absolute residuals of 16 to 21 dB in at most 2.6% of
points. Mean local R² ranges from 0.54 to 0.76.

## Interpretation

In Gandhinagar, where most measurements were taken at vehicle speeds, noise is
strongly tied to movement: depending on heading, the level changes by about 10
to 14 dB at mean speed. This pattern is consistent with marked axes or corridors of
traffic movement, although it could also reflect the vehicle's own
noise or street geometry. The nighttime weekend decrease appears at most locations, and the
predominance of negative nighttime coefficients held when the baseline level
was added, among locations retained in both versions.

In Geneva, speeds were predominantly consistent with walking by day, while
the nighttime period showed a broader mix. There, heading matters about three
times less and the model explains a smaller share of the variation.
Weekends tend to be louder, but that result depends on how local context is
controlled for, and at night it is imprecise.

Overall, the models show a much stronger association with heading in
Gandhinagar, and more stable temporal effects there than in Geneva. Since the
two cities were measured differently, the share of that difference due to the
cities rather than the measurement mode cannot be separated, and the results
describe associations, not causal effects.

## Limitations

- Recorded speeds differ sharply between cities, indicating that
  measurements were mostly taken in different ways. In Gandhinagar, 76% to
  88% of points exceed 15 km/h (median ≈39 km/h by day), consistent with
  vehicle-borne measurement. In daytime Geneva, 91% are at 8 km/h or less
  (median ≈5 km/h), consistent with walking; at night the mix is broader (47%
  at 8 km/h or less, 30% above 15 km/h). Baseline levels are not directly
  comparable (median intercept 74.4 vs 51.8 dB by day), only spatial and
  temporal structure is.

  ![Measurement speed by case](figures/velocidad_en.png)

- Calibration also differs structurally. In Geneva, gain takes only a few
  values (four by day, five at night), with most tracks at −22.5 or 0 dB. In
  Gandhinagar it is widely dispersed: −35 to +25 dB by day and up to +64 dB at
  night.

- In Gandhinagar, 31% of daytime points (1436 of 4700) and 20% of nighttime
  points (970 of 4767) are left out of the model because they fall outside
  every NoiseCapture hexagon, so they have no area measurement count. They are
  far from any area (by day, a median of 2.9 km from the nearest hexagon), so
  they were excluded rather than imputed. No Geneva points are excluded for
  this reason.

- The weekend subset is not representative in speed. Locations with
  enough weekday/weekend mix to estimate $\beta$ have a median speed of
  21.4 km/h at night in Gandhinagar, against 38 km/h for the full set.

- In Gandhinagar, tracks with one or two observations, which the local model
  cannot fit well, have much larger residuals (median |residual| 9.1 to
  14.6 dB, against about 3 dB elsewhere), although they hold under 1% of
  points. In Geneva the difference is smaller. Filtering short tracks is an
  open improvement.

- The area measurement count is still a NoiseCapture aggregate that includes
  the measurements themselves; it acts as a control for sampling intensity,
  not for sound level. The baseline-level evaluation was run only for daytime
  Geneva and daytime Gandhinagar, on points with other tracks in their
  hexagon. Results are read as exploratory associations, not as causal effects
  or out-of-sample predictive validation.

- In nighttime Gandhinagar, 3% of locations have a heading-effect amplitude
  above 20 dB (maximum 34 dB). Extreme amplitudes call for caution and are not
  read directly as physical noise differences. The figure limits the visible
  range to 25 dB, but summaries are computed with all estimates.

- GWR local estimates are spatially correlated, so $\lvert z \rvert \ge 2$ flags
  locations worth attention rather than independent significance tests.

## Contents

- `README.md`: project overview in English
- `README.es.md`: project overview in Spanish
- `*.html`: standalone interactive maps
- `figures/`: README figures

## Authors

Analysis and maps in this repository: Cristian Antonio.
Part of a two-person final project for the Spatial Statistics course at
Universidad de Buenos Aires (2025), together with Ezequiel Grenat.

## Data licence

Noise data from the NoiseCapture project (Noise-Planet, UMRAE and
Lab-STICC), used under the Open Database License (ODbL).
