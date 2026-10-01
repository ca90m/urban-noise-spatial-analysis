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

Los mapas corresponden a los modelos principales, que incluyen el nivel base
del área. Las variantes sin ese predictor se utilizaron como análisis de
sensibilidad y sus resultados se resumen más adelante.

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

**Especificación del modelo.** Para cada medición $i$, tomada en la ubicación
$u_i$, el nivel de ruido $L_i$ (dB) se modela como:

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

Todos los coeficientes dependen de la ubicación: GWR los estima en cada punto,
con más peso para las observaciones cercanas. $v_i$ es la velocidad
estandarizada. $\tilde c_i$ y $\tilde s_i$ son el coseno y el seno del rumbo
$\theta_i$, centrados en su media. En el modelo direccional se usan
$\cos\theta_i$ y $\sin\theta_i$; en el axial, $\cos 2\theta_i$ y
$\sin 2\theta_i$, que valen lo mismo para $\theta$ y $\theta + 180^\circ$. Por
eso el modelo axial no distingue sentidos opuestos. El término entre corchetes
permite que el efecto del rumbo cambie con la velocidad.

Los demás términos son controles. $h^c_i$ y $h^s_i$ representan la hora como
coseno y seno de $2\pi \cdot \text{hora}_i / 24$, de modo que las 23 h y las
0 h quedan cerca. $b_i$ es el nivel habitual del área a esa hora y en ese tipo
de día (lunes a viernes, sábado o domingo), según el perfil horario de
NoiseCapture (la mediana, LA50, de cada hora), estandarizado. Si falta el valor
de esa hora, se usa la mediana general del área. $m_i$ es el logaritmo
de uno más la cantidad de mediciones del área, estandarizado. $w_i$ es el
indicador de fin de semana, centrado.

Dos de estos controles entran residualizados (es decir, ortogonalizados). El
seno de la hora se reemplaza por el residuo de su regresión lineal sobre el
coseno, y $b_i$, por el residuo de su regresión sobre el seno y el coseno de la
hora. Es solo una reparametrización: el ajuste, los residuos y el coeficiente
$\beta_{\text{base}}$ son los mismos que sin residualizar. Lo que cambia es el
reparto entre coeficientes: los términos horarios recogen el ciclo diario
completo, incluida la parte asociada al nivel habitual del área, y el
intercepto cambia su punto de referencia.

Cada coeficiente se lee así:

| Coeficiente | Qué mide |
|---|---|
| $\beta_0$ | Nivel base del lugar: el nivel esperado a velocidad media, con las demás variables en su valor de referencia. En los mapas se muestra trasladado a velocidad nula. |
| $\beta_{\text{speed}}$ | Cuántos dB cambia el nivel por cada desvío estándar de velocidad, promediando sobre los rumbos. En los mapas se expresa en dB por m/s. |
| $\beta_{\cos}$, $\beta_{\sin}$ | Efecto del rumbo a velocidad media. En el modelo direccional, $\beta_{\cos}$ compara el desplazamiento hacia el norte con el desplazamiento hacia el sur, y $\beta_{\sin}$, hacia el este con hacia el oeste. En el axial, $\beta_{\cos}$ compara el eje norte-sur con el eje este-oeste, y $\beta_{\sin}$, el eje noreste-suroeste con el eje noroeste-sureste. En todos los casos, la diferencia entre ambos es el doble del coeficiente, y un valor positivo indica más ruido en el primero. Por separado dependen de cómo se orientan los ejes; por eso se resumen en $\beta_{\text{align}}$. |
| $\gamma_{\cos}$, $\gamma_{\sin}$ | Cuánto cambia el efecto del rumbo por cada desvío estándar de velocidad. Visto al revés, indican si el efecto de la velocidad depende del rumbo. |
| $\beta_{\text{hc}}$, $\beta_{\text{hs}}$ | Describen conjuntamente la variación horaria del nivel dentro de cada franja (día, de 7 a 19 h; noche, de 19 a 7 h) mediante términos coseno y seno, incluida la parte asociada al nivel habitual del área. |
| $\beta_{\text{base}}$ | Asociación con el nivel habitual del área, en dB por cada desvío estándar de ese nivel. Se usa en la asignación de la etiqueta de base estacionaria. |
| $\beta_{\text{count}}$ | dB por cada desvío estándar del logaritmo de la cantidad de mediciones del área. Funciona sobre todo como control de la intensidad de muestreo, sin una lectura física directa. |
| $\beta_{\text{weekend}}$ | Diferencia local de nivel entre fines de semana y días hábiles, en dB, más allá de la que ya refleja el nivel habitual del área para cada tipo de día. |
| $\beta_{\text{align}}$ | Amplitud del efecto del rumbo, en dB. Se detalla más abajo. |

Ambas variantes tienen los mismos términos y difieren solo en cómo codifican el
rumbo. El ancho de banda es adaptativo y se eligió por AICc, junto con el
kernel (gaussiano o bicuadrado). Entre las dos variantes se eligió la de mayor
R² local medio; ante un empate, la de menor AICc.

Para el efecto de fin de semana se ajustó además una variante sin el nivel base
del área, con las mismas observaciones, la misma codificación del rumbo y los
mismos pesos espaciales (kernel y ancho de banda) que el modelo principal. Ese
control se construye con las propias mediciones y distingue por tipo de día,
así que puede absorber parte del contraste entre fines de semana y días
hábiles. Comparar ambas versiones muestra cuánto depende ese resultado del
control.

**Coeficiente de alineación.** El efecto del rumbo se resume en un solo valor
por ubicación:

```math
\beta_{\text{align}}(u) = \sqrt{\beta_{\cos}(u)^2 + \beta_{\sin}(u)^2}
```

A velocidad media, el término de rumbo es una onda de amplitud
$\beta_{\text{align}}$, con período de 360° en el modelo direccional y de 180°
en el axial. Según el rumbo, el nivel sube o baja hasta esa cantidad de dB, y
la diferencia entre el rumbo más ruidoso y el más silencioso es el doble. Por
construcción, el coeficiente nunca es negativo.

**Tratamiento de la calibración de los dispositivos.** Los recorridos no son
una agrupación útil para representar el contexto, porque las muestras de un
mismo recorrido pueden estar alejadas en el espacio y en el tiempo. La
ganancia de calibración, en cambio, es una propiedad del dispositivo, y la
magnitud de los residuos $r_i$ varió con ella. Para evaluarlo se modeló
$\log r_i^2$ en función de la ganancia: con un GAM en Gandhinagar y con un
ANOVA en Ginebra, donde la ganancia toma pocos valores. Como se mide respecto
de cero, esa magnitud refleja tanto la dispersión como el sesgo de los
residuos. En Gandhinagar de día la relación fue significativa (p < 2e-16): la
magnitud típica de los residuos en el percentil 95 de ganancia fue unas 1.18
veces la del percentil 5. En Ginebra de
día también lo fue (p = 9.3e-08), pero en sentido inverso (0.72).

Esto se trató en dos pasos. Primero, un LOESS robusto $\hat b(g)$ de los
residuos en función de la ganancia permitió estimar un sesgo, que se restó
antes de volver a centrar los residuos:

```math
r^{\text{db}}_i = r_i - \hat b(g_i) - \mathrm{mediana}\big(r - \hat b(g)\big)
```

Segundo, como la varianza seguía difiriendo según la ganancia, se calcularon
umbrales de anomalía para cada intervalo de ganancia $k$ (≤ −20, −20 a −15,
−15 a −12 y > −12 dB) a partir de la distribución local de los residuos:

```math
U_k = \max\big\{\,5\ \text{dB},\ \mathrm{P}_{95}\big(|r^{\text{db}}| \text{ en el intervalo } k\big)\big\}
```

Los intervalos con menos de 100 puntos usan el percentil 95 global. Un punto
se marca como anómalo si supera el umbral de su intervalo y, además, forma
parte de un agrupamiento alto-alto de LISA sobre $\lvert r^{\text{db}} \rvert$ (4 vecinos
más cercanos, α = 0.05, con el residuo y el promedio de los vecinos por encima
de 5 dB). Así, los errores aislados quedan fuera y se retienen las zonas donde
el modelo falla de forma sostenida.

## Etiquetas operativas

A cada ubicación se le asigna un régimen según cuál de sus coeficientes
locales predomina. Cada coeficiente se compara con su propia distribución
dentro de la ciudad y el período. Por eso las etiquetas son relativas: indican
qué efecto sobresale en cada lugar, no valores comparables entre ciudades.

| Etiqueta | Interpretación |
|---|---|
| Predominio de la velocidad | El ruido varía con la velocidad de desplazamiento; la dirección tiene poca influencia. |
| Cañón urbano / direccional | Predomina la orientación: a la misma velocidad, el ruido cambia según el eje de circulación. Es un patrón compatible con calles encajonadas. |
| Base estacionaria | Nivel base local alto, con efectos débiles de la velocidad y la orientación. El nivel depende más del lugar que del desplazamiento de quien mide. |
| Ruido uniforme | Velocidad y orientación empatadas o relativamente débiles, con el nivel predicho a no más de 3 dB del intercepto y este cercano a la mediana del caso. |
| Transición / mixto | Sin predominio claro de velocidad u orientación según las reglas utilizadas: sus magnitudes normalizadas son comparables o ambas son relativamente bajas. |
| Anómalo / a revisar | El residuo supera el umbral ajustado por calibración de su intervalo de ganancia y forma parte de un agrupamiento de residuos altos. Se marca para inspección, sin asignarle una interpretación. |

### Reglas de asignación

Los coeficientes de velocidad y alineación se normalizan por su percentil 75
dentro de cada caso:

```math
s_i = \frac{|\beta_{\text{speed},i}|}{\mathrm{P}_{75}\big(|\beta_{\text{speed}}|\big)},
\qquad
a_i = \frac{\beta_{\text{align},i}}{\mathrm{P}_{75}\big(\beta_{\text{align}}\big)}
```

Un efecto es fuerte si $\max(s_i, a_i) \ge 0.8$, y hay empate si $s_i / a_i$
está entre $1/1.2$ y $1.2$. Las etiquetas se asignan en este orden, y cada
punto recibe la primera que cumple:

1. **Anómalo / a revisar**: cumple el criterio de anomalías descrito en la
   sección de calibración.
2. **Predominio de la velocidad**: hay un efecto fuerte y $s_i / a_i > 1.2$.
3. **Cañón urbano / direccional**: hay un efecto fuerte y $s_i / a_i < 1/1.2$.
4. **Base estacionaria**: el intercepto supera su percentil 75, o $\beta_{\text{base}}$
   supera la mediana de $\lvert \beta_{\text{base}} \rvert$ más su MAD; y ni la velocidad ni la
   alineación superan su percentil 75.
5. **Transición / mixto**: el resto, es decir, puntos con empate o con ambos
   efectos débiles.

Por último, un punto no anómalo con empate o efectos débiles pasa a **ruido
uniforme** si su nivel predicho está a no más de 3 dB del intercepto y el
intercepto está cerca de la mediana (a no más de 0.33 veces el rango
intercuartílico).

## Resultados

**El criterio de anomalías reduce la cantidad de puntos marcados en un orden de
magnitud.** Según el caso, un umbral fijo de 5 dB marca entre el 21% y el 26%
de los puntos. Exigir además que formen un agrupamiento de residuos altos
(LISA alto-alto) reduce esa proporción a entre el 3% y el 6%, y el umbral por
intervalo de ganancia, a entre el 1.0% y el 2.2%. La tasa final por intervalo
de ganancia va de 0% a 3%; que sea pareja es esperable en parte por
construcción, ya que el umbral es un percentil dentro de cada intervalo. En
Ginebra de noche, 13 de los 18 anómalos corresponden a dispositivos con
ganancia de −22.5 dB. Como diagnóstico adicional, se calculó la correlación de
Spearman entre la ganancia mediana de cada recorrido y su proporción de puntos
anómalos. Fue débil en Gandhinagar (−0.07 de día y +0.19 de noche; p ≥ 0.07) y
negativa en Ginebra (−0.25 de día y −0.30 de noche; p ≈ 0.04 y 0.05): allí,
los recorridos con menor ganancia tienden a tener más anómalos. Con cuatro
pruebas, ninguna de estas correlaciones resiste una corrección por
comparaciones múltiples. Los mapas
conservan las distintas capas para poder compararlas directamente.

**El término direccional se comporta de forma muy distinta en cada ciudad.**
La mediana del coeficiente de alineación es 4.8 dB durante el día y 7.0 dB por
la noche en Gandhinagar, frente a 0.6 dB en Ginebra en ambos períodos. A la
velocidad media de cada caso, eso implica diferencias típicas de 10 a 14 dB
entre el rumbo más ruidoso y el más silencioso en Gandhinagar, y de alrededor
de 1 dB en Ginebra. El modelo axial fue seleccionado únicamente en Ginebra
durante la noche, donde también dejó los residuos con menor autocorrelación
espacial de los cuatro casos (I de Moran de los residuos de 0.01, frente a
valores de 0.05 a 0.27 en los demás). Ambas especificaciones utilizan la misma
cantidad de predictores y términos de interacción; difieren en cómo
representan la dirección del movimiento.

**Los efectos del fin de semana difirieron entre ciudades y fueron mayores
durante la noche.** Como $\beta_{\text{weekend}}$ se ajusta por el perfil del área por tipo de
día, no representa la diferencia total entre fines de semana y días hábiles.

| | Ubicaciones | Mediana de $\beta_{\text{weekend}}$ | Patrón predominante |
|---|---|---|---|
| Gandhinagar, día | 1145 | −1.5 dB | Mixto: 45% con menos ruido, 36% con más ruido |
| Gandhinagar, noche | 732 | −4.3 dB | 58% con menos ruido, 15% con más ruido |
| Ginebra, día | 214 | +0.1 dB | Ninguna ubicación con $\lvert z \rvert \ge 2$ |
| Ginebra, noche | 325 | +1.4 dB | 18% con más ruido, sin disminuciones significativas |

**Cómo se estima y filtra $\beta_{\text{weekend}}$.** Es el coeficiente del indicador de fin de semana: la diferencia local
de nivel entre fines de semana y días hábiles, en dB, ajustada por los demás
términos del modelo. Solo se informa donde puede estimarse de forma razonable.
Entre los $k$ vecinos más cercanos (10% de los puntos, entre 30 y 150) debe haber
entre un 10% y un 90% de mediciones de fin de semana, el R² local debe ser de al
menos 0.5 y el efecto no debe superar los 12 dB en valor absoluto. Un efecto se
considera distinguible cuando el cociente entre el coeficiente y su error
estándar es de al menos 2 en valor absoluto.

En Gandhinagar durante el día, la mediana es de −1.5 dB, pero el 81% de las
ubicaciones presenta un efecto distinguible: 45% con menos ruido y 36% con
más, en distintos corredores. Las estimaciones locales muestran patrones
opuestos dentro de la ciudad que la mediana no refleja.

**Sensibilidad al nivel base del área.** La tabla compara el modelo principal
con una variante sin ese predictor, manteniendo las mismas observaciones, la
codificación del rumbo y los pesos espaciales. Se resumen solo las ubicaciones
que cumplen los criterios de presentación en ambas versiones. Al retirar el
predictor cambian el R² local y los coeficientes, por lo que también puede
cambiar qué ubicaciones cumplen esos criterios, incluido el límite de ±12 dB.
Los resultados describen el subconjunto común, no todas las estimaciones ni
toda la ciudad. Por eso las medianas con nivel base difieren de las de la tabla
anterior.

| | Ubicaciones comunes | Mediana con nivel base | Mediana sin nivel base | Mismo signo |
|---|---|---|---|---|
| Gandhinagar, día | 902 | −1.5 dB | −0.3 dB | 96% |
| Gandhinagar, noche | 579 | −4.4 dB | −5.7 dB | 96% |
| Ginebra, día | 141 | −0.5 dB | +2.7 dB | 66% |
| Ginebra, noche | 133 | +1.5 dB | +3.7 dB | 99% |

En Gandhinagar y en Ginebra de noche, el signo del coeficiente se mantuvo en
aproximadamente el 96% o más de las ubicaciones comunes. En ese subconjunto
persistieron el predominio negativo nocturno de Gandhinagar, la coexistencia
de signos durante el día y el predominio positivo nocturno de Ginebra. Las
magnitudes variaron al retirar el perfil, especialmente en Ginebra. Durante la
noche, la mediana pasó de +1.5 a +3.7 dB; entre las 133 ubicaciones comunes, el
20% alcanzó $\lvert z \rvert \ge 2$ sin nivel base, frente a ninguna con él. En Ginebra de día,
el signo coincidió en el 66% de las ubicaciones comunes y la mediana pasó de
−0.5 a +2.7 dB.

Retirar el nivel base también empeoró el ajuste dentro de la muestra: el R²
local medio bajó 0.05 en Gandhinagar y entre 0.24 y 0.30 en Ginebra, y aumentó
la autocorrelación espacial de los residuos en los cuatro casos. Como el perfil
se construye con las mismas mediciones, esto no indica que el modelo con nivel
base prediga mejor observaciones nuevas, y la comparación no permite separar
cuánto de su aporte es contexto local y cuánto reutilización de la respuesta.

**El ajuste del modelo varió entre las etiquetas asignadas, sin un orden común
a ambas ciudades.** En Gandhinagar, las ubicaciones de cañón urbano tuvieron el
menor |residuo| medio (2.5 dB de día y 2.7 dB de noche) y, de noche,
también el mayor R² local medio (0.90). En Ginebra de día, cañón urbano tuvo el mayor
R² local (0.87) y base estacionaria el menor |residuo| medio (2.8 dB); de noche, el
mejor ajuste correspondió a ruido uniforme y base estacionaria (1.3 y 1.8 dB;
R² de 0.93 y 0.92). Las de predominio de la velocidad tuvieron el mayor
|residuo| medio entre los regímenes regulares en tres de los cuatro casos
(de 3.9 a 4.2 dB). En la clase anómala, el |residuo| medio va de
15.5 a 18.0 dB; esta clase reúne como máximo el 2.2% de los puntos. El R²
local medio del modelo varía entre 0.72 y 0.87.

## Interpretación

En Gandhinagar, donde las mediciones se tomaron desde vehículos, el ruido
aparece fuertemente ligado al movimiento: según el rumbo, el nivel cambia unos
10 a 14 dB a velocidad media. Ese patrón es compatible con corredores de
tránsito con sentidos de circulación marcados, aunque también podría reflejar
el ruido del propio vehículo o la geometría de las calles. El predominio de
coeficientes negativos durante la noche se mantuvo al retirar el nivel base,
sobre las ubicaciones admitidas en ambas versiones.

En Ginebra, donde se midió caminando, el rumbo pesa poco y el nivel habitual de
cada zona explica buena parte de la variación. El fin de semana nocturno tiende
a ser más ruidoso, pero el tamaño de ese efecto depende de cómo se controle el
contexto del lugar.

En conjunto, los modelos muestran una asociación con el rumbo más marcada en
Gandhinagar y una mayor sensibilidad del ajuste al perfil del área en Ginebra.
La comparación con y sin ese perfil permitió distinguir patrones de signos
que se mantuvieron de magnitudes que dependieron del control utilizado. Las
diferencias en el modo de medición y el origen del perfil impiden atribuir
estos resultados únicamente a las ciudades. Se describen asociaciones
exploratorias, no efectos causales.

## Limitaciones

- Las medianas de velocidad difieren mucho entre ciudades (≈39 km/h en
  Gandhinagar durante el día, ≈5 km/h en Ginebra), por lo que las mediciones
  se recolectaron en modos distintos: desde vehículos y a pie. Los niveles
  base no son directamente comparables (mediana del intercepto de 75.0
  frente a 54.2 dB durante el día). La comparación se limita a la estructura
  espacial y temporal.

- La calibración también presenta diferencias estructurales. En Ginebra, la
  ganancia toma pocos valores (cuatro de día y cinco de noche), y la mayoría
  de los recorridos está en −22.5 o 0 dB. En Gandhinagar está ampliamente
  dispersa: de −35 a +25 dB durante el día y hasta +64 dB por la noche.

- El subconjunto con datos de fin de semana no es representativo en
  velocidad. Las ubicaciones con suficiente combinación de días de semana
  y fines de semana para estimar $\beta$ tienen una mediana de velocidad de
  17.8 km/h en Gandhinagar durante la noche, frente a 38 km/h en el conjunto
  completo.

- En Gandhinagar, los recorridos con una o dos observaciones, que el modelo
  local no logra ajustar bien, tienen residuos mucho mayores (mediana de
  |residuo| de 6.2 a 15.1 dB, frente a unos 2.5 dB en el resto), aunque reúnen
  menos del 1% de los puntos. En Ginebra la diferencia es pequeña. Filtrar los
  recorridos cortos es una mejora pendiente.

- El nivel habitual del área y la cantidad de mediciones provienen de
  agregados que NoiseCapture calcula con las mismas mediciones colaborativas,
  por lo que pueden incluir las observaciones que se modelan. No son una
  referencia independiente, y esa dependencia puede favorecer el ajuste dentro
  de la muestra; residualizar el nivel del área no la elimina. Por eso los
  resultados se interpretan como asociaciones exploratorias, no como efectos
  causales ni como una validación predictiva fuera de muestra.

- Las estimaciones locales de GWR están correlacionadas espacialmente.
  Por eso, $\lvert z \rvert \ge 2$ señala ubicaciones que merecen atención, sin constituir
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
