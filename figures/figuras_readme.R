# Figuras del README (español e inglés).
# Requiere: los ocho Excel de diagnóstico y beta_align.csv (β_align por punto de los mapas principales).
library(readxl); library(dplyr); library(ggplot2)

textos <- list(
  es = list(casos = c("Gandhinagar, día", "Gandhinagar, noche", "Ginebra, día", "Ginebra, noche"),
            sens_x = "con nivel base (dB)", sens_y = "sin nivel base (dB)",
            sens_tit = "Sensibilidad del efecto de fin de semana al nivel base",
            sens_sub = "Ubicaciones admisibles en ambas versiones; la diagonal indica igualdad",
            al_y = "(dB)", al_tit = "Efecto del rumbo por caso",
            al_sub = "Amplitud del efecto del rumbo en cada punto (modelo principal)",
            al_cap = "Se muestran valores de hasta %d dB; quedan fuera del gráfico %d puntos (%.0f%%) de Gandhinagar de noche."),
  en = list(casos = c("Gandhinagar, day", "Gandhinagar, night", "Geneva, day", "Geneva, night"),
            sens_x = "with baseline level (dB)", sens_y = "without baseline level (dB)",
            sens_tit = "Sensitivity of the weekend effect to the baseline level",
            sens_sub = "Locations admissible in both versions; the diagonal marks equality",
            al_y = "(dB)", al_tit = "Heading effect by case",
            al_sub = "Amplitude of the heading effect at each point (main model)",
            al_cap = "Values up to %d dB shown; %d points (%.0f%%) from nighttime Gandhinagar fall outside the plot.")
)
archivos <- c("gandhinagar_dia", "gandhinagar_noche", "geneve_dia", "geneve_noche")
leer <- function(nombre, sufijo) read_excel(paste0("diagnostico_leaflet_", nombre, sufijo, ".xlsx"),
                                            sheet = "Weekend_por_punto")
dir.create("figures", showWarnings = FALSE)

for (idioma in names(textos)) {
  tx <- textos[[idioma]]

  # 1) Sensibilidad del efecto de fin de semana
  datos <- do.call(rbind, lapply(seq_along(archivos), function(k) {
    inner_join(leer(archivos[k], ""), leer(archivos[k], "_sinbase"),
               by = "row_id", suffix = c("_con", "_sin")) |>
      filter(as.logical(mask_weekend_ok_con), as.logical(mask_weekend_ok_sin)) |>
      transmute(caso = factor(tx$casos[k], levels = tx$casos),
                con = beta_weekend_raw_con, sin = beta_weekend_raw_sin)
  }))
  g1 <- ggplot(datos, aes(con, sin)) +
    geom_hline(yintercept = 0, colour = "grey75") +
    geom_vline(xintercept = 0, colour = "grey75") +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey40") +
    geom_point(alpha = 0.35, size = 0.9, colour = "#2b6cb0") +
    facet_wrap(~ caso, ncol = 2) + coord_equal() +
    labs(x = bquote(beta[weekend] ~ .(tx$sens_x)), y = bquote(beta[weekend] ~ .(tx$sens_y)),
         title = tx$sens_tit, subtitle = tx$sens_sub) +
    theme_minimal(base_size = 11)
  ggsave(sprintf("figures/sensibilidad_finde_%s.png", idioma), g1,
         width = 7, height = 7, dpi = 150, bg = "white")

  # 2) Coeficiente de alineación por caso
  al <- read.csv("beta_align.csv") |>
    mutate(caso = factor(tx$casos[match(paste(ciudad, franja),
                         c("Gandhinagar dia", "Gandhinagar noche", "Ginebra dia", "Ginebra noche"))],
                         levels = tx$casos))
  med <- al |> group_by(caso, ciudad) |> summarise(m = median(beta_align), q3 = quantile(beta_align, 0.75), .groups = "drop") |>
    mutate(ypos = ifelse(q3 - m > 1.5, m, q3))   # etiqueta sobre la caja si la caja es muy chata
  tope <- 25
  fuera <- sum(al$beta_align > tope)
  pct   <- 100 * fuera / sum(al$ciudad == "Gandhinagar" & al$franja == "noche")
  g2 <- ggplot(al, aes(caso, beta_align, fill = ciudad)) +
    geom_boxplot(outlier.size = 0.4, outlier.alpha = 0.3, width = 0.6) +
    geom_text(data = med, aes(y = ypos, label = sprintf("%.1f", m)),
              vjust = -0.6, size = 3.4, fontface = "bold") +
    scale_fill_manual(values = c(Gandhinagar = "#f6ad55", Ginebra = "#63b3ed"), guide = "none") +
    coord_cartesian(ylim = c(0, tope)) +
    labs(x = NULL, y = bquote(beta[align] ~ .(tx$al_y)), title = tx$al_tit, subtitle = tx$al_sub,
         caption = sprintf(tx$al_cap, tope, fuera, pct)) +
    theme_minimal(base_size = 11)
  ggsave(sprintf("figures/alineacion_%s.png", idioma), g2,
         width = 7, height = 4.5, dpi = 150, bg = "white")
}
cat("listo\n")
