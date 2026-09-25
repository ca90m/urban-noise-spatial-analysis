# Estructura espacial del ruido urbano

[English](README.md) | **Español**

¿Se pueden inferir las dinámicas del tránsito urbano a partir de la estructura
espacial de los niveles de ruido? Este proyecto analiza mediciones de ruido
recolectadas de forma colaborativa en Ginebra (Suiza) y Gandhinagar (India),
comparando día y noche, y días de semana y fines de semana.

## Mapas interactivos

- [Gandhinagar: día](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_dia.html)
- [Gandhinagar: noche](https://ca90m.github.io/urban-noise-spatial-analysis/gandhinagar_noche.html)
- [Ginebra: día](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_dia.html)
- [Ginebra: noche](https://ca90m.github.io/urban-noise-spatial-analysis/ginebra_noche.html)

Los mapas se construyeron con leaflet en R. Se abren en cualquier navegador,
sin necesidad de instalar nada. Los controles de capas y las ventanas
emergentes permiten alternar entre español e inglés.

## Datos

Mediciones móviles de ruido con nivel sonoro, velocidad, rumbo, precisión del
GPS y ganancia de calibración del dispositivo, provenientes del conjunto de
datos colaborativo NoiseCapture ([Noise-Planet](https://noise-planet.org/),
UMRAE y Lab-STICC, distribuido bajo
[ODbL](https://opendatacommons.org/licenses/odbl/)). Las mediciones se obtienen
mediante una aplicación de Android, lo que explica la amplia dispersión en la
ganancia de calibración de los dispositivos. Los datos tienen una estructura
jerárquica: las muestras pertenecen a recorridos, y los recorridos a áreas
urbanas. Los registros se filtraron con criterios de calidad espaciotemporal y
umbrales de precisión, y las marcas de tiempo se convirtieron a la hora local.

## Metodología

**Dependencia espacial.** El índice I de Moran y los indicadores LISA mostraron
autocorrelación espacial global y agrupamientos locales en los niveles de
ruido. Se utilizó GWR para explorar cómo variaban las asociaciones con la
velocidad y la dirección del movimiento dentro de las áreas de estudio.

**Regresión local.** Se aplicó regresión geográficamente ponderada (GWR) con
dos representaciones del rumbo: direccional (0–360°), que distingue sentidos
opuestos, y axial (0° ≡ 180°), que los considera equivalentes. La comparación
buscó evaluar si el nivel de ruido se asociaba principalmente con el eje del
desplazamiento o si distinguir su sentido aportaba información. También se
incorporaron variables a nivel de área para representar el contexto local.

La geometría de las calles y las reflexiones del sonido entre fachadas
motivaron considerar patrones asociados con el eje de circulación. A su vez,
las diferencias de exposición a las fuentes y la emisión desigual de sonido
según la dirección podrían generar diferencias entre sentidos. También se
consideró el posible papel del efecto Doppler, ligado al movimiento relativo
entre fuente y receptor y al cambio en la frecuencia recibida.

El rumbo registrado corresponde al desplazamiento de quien mide y no
identifica directamente la dirección de llegada del sonido. Por eso, la
comparación permite evaluar qué representación del rumbo resulta más útil,
aunque las diferencias de ajuste no permiten identificar por sí solas los
mecanismos físicos que originan los patrones observados.

**Tratamiento de la calibración de los dispositivos.** Los recorridos no son
una agrupación útil para representar el contexto, porque las muestras de un
mismo recorrido pueden estar alejadas en el espacio y en el tiempo. La
ganancia de calibración, en cambio, es una propiedad del dispositivo, y los
residuos presentaron heterocedasticidad en relación con ella (GAM sobre
var(gain): p < 2e-16, SD95/05 ≈ 1.29). Esto se trató en dos pasos. Primero,
un LOESS robusto de los residuos en función de la ganancia permitió estimar
un sesgo, que se restó antes de volver a centrar los residuos. Segundo, como
la varianza seguía difiriendo según el nivel de ganancia, se calcularon
umbrales de anomalía para cada intervalo de ganancia a partir de la
distribución local de los residuos. Así, el criterio se adapta a la varianza
local.

## Etiquetas operativas

A cada ubicación se le asigna un régimen según cuál de sus coeficientes
locales predomina.

| Etiqueta | Interpretación |
|---|---|
| Predominio de la velocidad | El ruido varía con la velocidad de los vehículos; la dirección tiene poca influencia. |
| Cañón urbano / direccional | Predomina la orientación: a la misma velocidad, el ruido cambia según el eje de circulación. Es un patrón típico de calles encajonadas. |
| Base estacionaria | Nivel base local alto, con efectos débiles de la velocidad y la orientación. El ruido proviene del entorno más que del tránsito que pasa por el lugar. |
| Ruido uniforme | Todos los efectos son débiles y el nivel está cerca del nivel base local. |
| Transición / mixto | Los efectos de la velocidad y la orientación son comparables, sin que ninguno predomine. |
| Anómalo / a revisar | El residuo supera el umbral ajustado por calibración correspondiente a su intervalo de ganancia. Se marca para inspección, sin asignarle una interpretación. |

## Resultados

**Los umbrales que contemplan la calibración cambian la cantidad de anomalías
en un orden de magnitud.** Un umbral fijo de 5 dB identifica como anómalos al
24% de los puntos; el criterio que contempla la calibración reduce esa
proporción al 2%. La tasa se mantiene estable entre niveles de calibración
(1–2% en cada intervalo de ganancia), sin concentrarse en los dispositivos
con más ruido. Después de la corrección, la ganancia a nivel de recorrido
presenta una correlación casi nula con la mediana de los residuos (de −0.20
a +0.14 entre los cuatro casos). Los mapas conservan ambas capas para poder
compararlas directamente.

**El término direccional se comporta de forma muy distinta en cada ciudad.**
La mediana del coeficiente de alineación es +4.6 durante el día y +6.8 por la
noche en Gandhinagar, frente a +1.1 en Ginebra en ambos períodos. En
Gandhinagar, la orientación tiene entre cuatro y seis veces más peso. El
modelo axial fue seleccionado únicamente en Ginebra durante la noche,
donde también dejó los residuos con menor autocorrelación espacial de los
cuatro casos (I de Moran de los residuos de 0.08, frente a valores de 0.19 a
0.24 en los demás). Ambas especificaciones utilizan la misma cantidad de
predictores y términos de interacción; difieren en cómo representan la
dirección del movimiento.

**Los efectos del fin de semana difirieron entre ciudades y fueron mayores
durante la noche.**

| | Ubicaciones | Mediana de β_weekend | Patrón predominante |
|---|---|---|---|
| Gandhinagar, día | 1104 | −0.6 dB | Mixto: 35% con menos ruido, 35% con más ruido |
| Gandhinagar, noche | 573 | −5.8 dB | 79% con menos ruido |
| Ginebra, día | 214 | +1.7 dB | 67% con más ruido, sin disminuciones significativas |
| Ginebra, noche | 325 | +6.0 dB | 75% con más ruido, sin disminuciones significativas |

En Gandhinagar durante el día, la mediana del efecto es prácticamente cero.
Sin embargo, el 70% de las ubicaciones presenta un efecto distinguible,
repartido en partes iguales entre fines de semana con menos y con más ruido
en distintos corredores. Las estimaciones locales muestran patrones
opuestos dentro de la ciudad que la mediana cercana a cero no refleja.

**El ajuste del modelo varió entre las etiquetas asignadas.** Las ubicaciones
clasificadas como cañón urbano presentaron el mejor ajuste (mediana de
|residuo| de 1.7 a 1.8 dB, R² local de hasta 0.95 durante la noche), y las de
predominio de la velocidad, el peor entre los regímenes regulares (R² de
0.68). En la clase anómala, las medianas de los residuos van de 14.7 a
15.6 dB; esta clase reúne menos del 2% de los puntos. El R² global del modelo
varía entre 0.74 y 0.81.

## Limitaciones

- Las medianas de velocidad difieren mucho entre ciudades (≈39 km/h en
  Gandhinagar durante el día, ≈5 km/h en Ginebra), por lo que las mediciones
  se recolectaron en modos distintos: desde vehículos y a pie. Los niveles
  base no son directamente comparables (mediana del intercepto de 74.9
  frente a 53.0 dB durante el día). La comparación se limita a la estructura
  espacial y temporal.

- La calibración también presenta diferencias estructurales. La ganancia es
  casi constante en Ginebra (−14.4 dB en casi todos los recorridos) y está
  ampliamente dispersa en Gandhinagar (de −35 a +25 dB).

- El subconjunto con datos de fin de semana no es representativo en
  velocidad. Las ubicaciones con suficiente combinación de días de semana
  y fines de semana para estimar β tienen una mediana de velocidad de
  16.6 km/h en Gandhinagar durante la noche, frente a 38 km/h en el conjunto
  completo.

- Los residuos grandes se concentran en recorridos con una o dos
  observaciones, que el modelo local no logra ajustar bien. Filtrar los
  recorridos cortos es una mejora pendiente.

- Las estimaciones locales de GWR están correlacionadas espacialmente.
  Por eso, |z| ≥ 2 señala ubicaciones que merecen atención, sin constituir
  pruebas de significación independientes.

## Contenido

- `README.md`: resumen en inglés.
- `README.es.md`: resumen en español.
- `*.html`: mapas interactivos autocontenidos.

## Autores

Análisis y mapas de este repositorio: Cristian Antonio.
Parte de un trabajo final de la materia Estadística Espacial de la
Universidad de Buenos Aires (2025), realizado junto con Ezequiel Grenat.

## Licencia de los datos

Datos de ruido del proyecto NoiseCapture (Noise-Planet, UMRAE y Lab-STICC),
utilizados bajo la Open Database License (ODbL).
