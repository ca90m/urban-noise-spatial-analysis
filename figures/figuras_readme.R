# Figuras del README (español e inglés), modelo principal sin nivel base.
# Requiere: los ocho Excel de diagnóstico (principal y "_conbase"), beta_align.csv y velocidad.csv
# (amplitud del rumbo y velocidad por punto, extraídas de los mapas principales).
library(readxl); library(dplyr); library(ggplot2)

textos <- list(
  es = list(casos = c("Gandhinagar, día", "Gandhinagar, noche", "Ginebra, día", "Ginebra, noche"),
            sens_x = "sin nivel base, modelo principal (dB)", sens_y = "con nivel base (dB)",
            sens_tit = "Sensibilidad del efecto de fin de semana al nivel base",
            sens_sub = "Ubicaciones admisibles en ambas versiones, con las mismas observaciones y pesos.\nLa diagonal indica igualdad.",
            al_tit = "Efecto del rumbo por caso",
            al_sub = "Amplitud del efecto del rumbo en cada punto (modelo principal)",
            al_cap = "Se muestran valores de hasta %d dB; quedan fuera del gráfico %d puntos de Gandhinagar de noche.",
            vel_x = "Velocidad registrada (km/h)", vel_y = "Puntos", vel_tit = "Velocidad de las mediciones por caso",
            vel_sub = "La línea punteada marca la mediana", vel_med = "mediana %.0f km/h",
            ev_tit = "¿Qué aporta el nivel base del área?",
            ev_sub = "R² local medio sobre los puntos con otros recorridos en su hexágono, con pesos fijos",
            ev_y = "R² local medio",
            ev_ver = c("Sin nivel base", "Perfil sin el propio recorrido", "Perfil de NoiseCapture"),
            ev_casos = c("Ginebra, día\n(957 puntos)", "Gandhinagar, día\n(2462 puntos)")),
  en = list(casos = c("Gandhinagar, day", "Gandhinagar, night", "Geneva, day", "Geneva, night"),
            sens_x = "without baseline level, main model (dB)", sens_y = "with baseline level (dB)",
            sens_tit = "Sensitivity of the weekend effect to the baseline level",
            sens_sub = "Locations admissible in both versions, with the same observations and weights.\nThe diagonal marks equality.",
            al_tit = "Heading effect by case",
            al_sub = "Amplitude of the heading effect at each point (main model)",
            al_cap = "Values up to %d dB shown; %d points from nighttime Gandhinagar fall outside the plot.",
            vel_x = "Recorded speed (km/h)", vel_y = "Points", vel_tit = "Measurement speed by case",
            vel_sub = "The dotted line marks the median", vel_med = "median %.0f km/h",
            ev_tit = "What does the area's baseline level add?",
            ev_sub = "Mean local R² on points with other tracks in their hexagon, fixed weights",
            ev_y = "Mean local R²",
            ev_ver = c("No baseline", "Profile without own track", "NoiseCapture profile"),
            ev_casos = c("Geneva, day\n(957 points)", "Gandhinagar, day\n(2462 points)"))
)
archivos <- c("gandhinagar_dia", "gandhinagar_noche", "geneve_dia", "geneve_noche")
leer <- function(nombre, sufijo) read_excel(paste0("diagnostico_leaflet_", nombre, sufijo, ".xlsx"),
                                            sheet = "Weekend_por_punto")
claves <- c("Gandhinagar dia", "Gandhinagar noche", "Ginebra dia", "Ginebra noche")
colores <- c(Gandhinagar = "#f6ad55", Ginebra = "#63b3ed")
dir.create("figures", showWarnings = FALSE)

for (idioma in names(textos)) {
  tx <- textos[[idioma]]
  caso_de <- function(ciudad, franja) factor(tx$casos[match(paste(ciudad, franja), claves)], levels = tx$casos)

  # 1) Sensibilidad del efecto de fin de semana (principal sin nivel base vs. con nivel base)
  datos <- do.call(rbind, lapply(seq_along(archivos), function(k) {
    inner_join(leer(archivos[k], ""), leer(archivos[k], "_conbase"),
               by = "row_id", suffix = c("_sin", "_con")) |>
      filter(as.logical(mask_weekend_ok_sin), as.logical(mask_weekend_ok_con)) |>
      transmute(caso = factor(tx$casos[k], levels = tx$casos),
                sin = beta_weekend_raw_sin, con = beta_weekend_raw_con)
  }))
  n_caso <- datos |> count(caso)
  g1 <- ggplot(datos, aes(sin, con)) +
    geom_hline(yintercept = 0, colour = "grey75") + geom_vline(xintercept = 0, colour = "grey75") +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey40") +
    geom_point(alpha = 0.35, size = 0.9, colour = "#2b6cb0") +
    geom_text(data = n_caso, aes(x = -Inf, y = Inf, label = paste0("n = ", n)),
              hjust = -0.2, vjust = 1.5, size = 3.3, inherit.aes = FALSE) +
    facet_wrap(~ caso, ncol = 2) + coord_equal() +
    labs(x = bquote(beta[weekend] ~ .(tx$sens_x)), y = bquote(beta[weekend] ~ .(tx$sens_y)),
         title = tx$sens_tit, subtitle = tx$sens_sub) +
    theme_minimal(base_size = 11)
  ggsave(sprintf("figures/sensibilidad_finde_%s.png", idioma), g1, width = 7, height = 7, dpi = 150, bg = "white")

  # 2) Amplitud del efecto del rumbo por caso
  al <- read.csv("beta_align.csv") |> mutate(caso = caso_de(ciudad, franja))
  med <- al |> group_by(caso, ciudad) |>
    summarise(m = median(beta_align), q3 = quantile(beta_align, 0.75), .groups = "drop") |>
    mutate(ypos = ifelse(q3 - m > 1.5, m, q3))
  tope <- 25; fuera <- sum(al$beta_align > tope)
  g2 <- ggplot(al, aes(caso, beta_align, fill = ciudad)) +
    geom_boxplot(outlier.size = 0.4, outlier.alpha = 0.3, width = 0.6) +
    geom_text(data = med, aes(y = ypos, label = sprintf("%.1f", m)), vjust = -0.6, size = 3.4, fontface = "bold") +
    scale_fill_manual(values = colores, guide = "none") +
    coord_cartesian(ylim = c(0, tope)) +
    labs(x = NULL, y = bquote(beta[align] ~ "(dB)"), title = tx$al_tit, subtitle = tx$al_sub,
         caption = sprintf(tx$al_cap, tope, fuera)) +
    theme_minimal(base_size = 11)
  ggsave(sprintf("figures/alineacion_%s.png", idioma), g2, width = 7, height = 4.5, dpi = 150, bg = "white")

  # 3) Velocidad de las mediciones
  ve <- read.csv("velocidad.csv") |> mutate(caso = caso_de(ciudad, franja))
  vmed <- ve |> group_by(caso, ciudad) |> summarise(m = median(velocidad_kmh), .groups = "drop")
  g3 <- ggplot(ve, aes(velocidad_kmh, fill = ciudad)) +
    geom_histogram(binwidth = 2, boundary = 0, colour = "white", linewidth = 0.1) +
    geom_vline(data = vmed, aes(xintercept = m), linetype = "dotted", linewidth = 0.6) +
    geom_label(data = vmed, aes(x = m, y = Inf, label = sprintf(tx$vel_med, m)),
               vjust = 1.3, hjust = -0.05, size = 3.1, fill = "white", label.size = 0) +
    facet_wrap(~ caso, ncol = 2, scales = "free_y") +
    scale_fill_manual(values = colores, guide = "none") + coord_cartesian(xlim = c(0, 90)) +
    labs(x = tx$vel_x, y = tx$vel_y, title = tx$vel_tit, subtitle = tx$vel_sub) +
    theme_minimal(base_size = 11)
  ggsave(sprintf("figures/velocidad_%s.png", idioma), g3, width = 7, height = 5, dpi = 150, bg = "white")

  # 4) Evaluación del nivel base (corridas con muestra común y pesos fijos)
  ev <- data.frame(caso = rep(tx$ev_casos, each = 3), version = rep(tx$ev_ver, 2),
                   r2 = c(0.24, 0.41, 0.71, 0.61, 0.62, 0.64))
  ev$caso <- factor(ev$caso, levels = tx$ev_casos); ev$version <- factor(ev$version, levels = tx$ev_ver)
  g4 <- ggplot(ev, aes(caso, r2, fill = version)) +
    geom_col(position = position_dodge(width = 0.75), width = 0.7) +
    geom_text(aes(label = sprintf("%.2f", r2)), position = position_dodge(width = 0.75), vjust = -0.4, size = 3.3) +
    scale_fill_manual(values = c("#cbd5e0", "#68d391", "#f6ad55"), name = NULL) +
    scale_y_continuous(limits = c(0, 0.8), expand = c(0, 0)) +
    labs(x = NULL, y = tx$ev_y, title = tx$ev_tit, subtitle = tx$ev_sub) +
    theme_minimal(base_size = 11) + theme(legend.position = "bottom")
  ggsave(sprintf("figures/evaluacion_nivel_base_%s.png", idioma), g4, width = 7, height = 4.5, dpi = 150, bg = "white")
}
cat("listo\n")
