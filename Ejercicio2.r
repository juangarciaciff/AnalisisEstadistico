### -------------------------------------------------------------------------
### CURSO.....: Master en Big Data y Business Analytics
### ASIGNATURA: Análisis Estadístico
### EJERCICIO.: Predicción de Series Temporales
### ALUMNO....: Juan Antonio García Cuevas
### FECHA.....: 20/12/2016
### -------------------------------------------------------------------------

### -------------------------------------------------------------------------
### Cargamos librerías:
### -------------------------------------------------------------------------
if (!require("itsmr")) {
  install.packages("itsmr") 
  library(itsmr)
}

### *************************************************************************
### *************************************************************************
### 1.- CARGA, REVISIÓN Y TRATAMIENTO DE DATOS
### *************************************************************************
### *************************************************************************

### Iniciamos variables:
pathdata <- "/home/juan/ciff/AnalisisEstadistico/AnalisisEstadistico/data2/"
pathimgs <- "/home/juan/ciff/AnalisisEstadistico/AnalisisEstadistico/images2/"
filedata <- "monthly-milk-production-pounds-p.csv"

### Movemos el directorio de trabajo al de datos, donde se encuentra el fichero CSV:
setwd(pathdata)

### Cargamos los datos del fichero CSV en un dataset:
df_milk <- read.csv(filedata, header=TRUE, sep=";")

### Movemos el directorio de trabajo al de imágenes, para exportar los gráficos que generaremos:
setwd(pathimgs)

### Mostramos información sobre el conjunto de datos:
str(df_milk)
head(df_milk)
summary(df_milk)

### Comprobamos que no hay ningún valor NaN:
df_milk[!complete.cases(df_milk),]

### Mostramos un gráfico con la evolución de la variable producción de leche a lo largo del tiempo:
plot(df_milk)
lines(df_milk)

dev.off()
png("df_milk.png")
plot(df_milk)
lines(df_milk)
dev.off()

# El conjunto de datos muestra información de la producción de leche en el periodo de enero 1962 a diciembre 1975. 
# Según la fuente de los datos la unidad de medida es libras por vaca.
# En la gráfica podemos observar una clara tendencia temporal ascendente.
# También podemos ver patrones de estacionalidad, picos de producción muy pronunciados en los meses de mayo, otros menores en los meses de enero y otros aún menores en los meses de octubre.
# Trataremos de crear un modelo que prediga la producción de leche en los 24 meses siguientes al periodo de observaciones.

### Separamos los datos en dos listas, la primera con el año y el mes y la segunda con los valores de producción de leche:
tiempo = df_milk[,1]
produccion = df_milk[,2]

### *************************************************************************
### *************************************************************************
### 2- ELIMINACIÓN DE LAS COMPONENTES DE ESTACIONALIDAD Y TENDENCIA
### *************************************************************************
### *************************************************************************

### -------------------------------------------------------------------------
### Estacionalidad:
### -------------------------------------------------------------------------

### Obtenemos la componente de estacionalidad:
estacionalidad = season(produccion, 12)

### La eliminamos del conjunto de datos:
df_milk2 = produccion - estacionalidad

### mostramos las gráficas:
par(mfrow = c(2, 1))
plot(tiempo, estacionalidad, main="Componente estacional")
lines(tiempo, estacionalidad)
plot(tiempo, df_milk2, main="Serie con estacionalidad corregida")
lines(tiempo, df_milk2)

dev.off()
png("estacionalidad.png")
par(mfrow = c(2, 1))
plot(tiempo, estacionalidad, main="Componente estacional")
lines(tiempo, estacionalidad)
plot(tiempo, df_milk2, main="Serie con estacionalidad corregida")
lines(tiempo, df_milk2)
dev.off()

# Comprobamos en la gráfica de la componente de estacionalidad que aparecen claramente picos en los meses de mayo y enero principalmente.
# Vemos en la gráfica de la nueva serie, en la que hemos eliminado la componente de estacionalidad, que sigue presentando tendencia ascendente.

### -------------------------------------------------------------------------
### Tendencia:
### -------------------------------------------------------------------------

### Obtenemos la componente de tendencia:
tendencia = trend(df_milk2, 1)

### La eliminamos del conjunto de datos:
df_milk3 = df_milk2 - tendencia

### mostramos las gráficas:
par(mfrow = c(2, 1))
plot(tiempo, tendencia, main="Componente de tendencia")
lines(tiempo, tendencia)
plot(tiempo, df_milk3, main="Serie con tendencia corregida")
lines(tiempo, df_milk3)
abline(0, 0)

dev.off()
png("tendencia.png")
par(mfrow = c(2, 1))
plot(tiempo, tendencia, main="Componente de tendencia")
lines(tiempo, tendencia)
plot(tiempo, df_milk3, main="Serie con tendencia corregida")
lines(tiempo, df_milk3)
abline(0, 0)
dev.off()

# Comprobamos en la gráfica de la componente de tendencia que ésta es claramente ascendente, y la eliminamos de la serie.
# Finalmente, hemos conseguido obtener una serie corregida, sin estacionalidad ni tendencia.

### *************************************************************************
### *************************************************************************
### 3- AUTOCORRELACIÓN 
### *************************************************************************
### *************************************************************************

### -------------------------------------------------------------------------
### Aplicamos funciones de autocorrelación ACF y PACF:
### -------------------------------------------------------------------------

# Sobre los datos desprovistos de componentes de estacionalidad y tendencia aplicamos las funciones de autocorrelación ACF y PACF.
# La Función de autocorrelación (ACF) mide la correlación entre dos variables separadas por k periodos.
# La Función de Autocorrelación Parcial (PACF) mide la correlación entre dos variables separadas por k periodos cuando no se considera la dependencia creada por los retardos intermedios existentes entre ambas.

par(mfrow = c(2, 1))
acf(df_milk3, length(df_milk3))
pacf(df_milk3, length(df_milk3))

dev.off()
png("acf_pacf.png")
par(mfrow = c(2, 1))
acf(df_milk3, length(df_milk3))
pacf(df_milk3, length(df_milk3))
dev.off()

# En la gráfica de autocorrelación total (ACF) podemos ver cómo los valores no nulos iniciales se van amortiguando a lo largo del tiempo. 
# En la grafica de la autocorrelación parcial (PACF) se puede ver un valor no nulo destacable.

### -------------------------------------------------------------------------
### Haremos el modelado con modelos autoregresivos (AR):
### -------------------------------------------------------------------------

# Los modelos autorregresivos son aquellos modelos ARMA(p,q) en los que q=0, por lo que podemos denotarlos como AR(p). 
# En un modelo AR(p) el valor en el momento t de la serie se expresa como una combinación lineal de las p observaciones anteriores de la serie más la innovación.

# Mostramos una gráfica con el valor de AICC para los 20 primeros valores de p:
vector = rep(0, 20)
for (p in 1:20) {
  vector[p] = yw(df_milk3, p)$aicc
}
plot(1:20, vector, type='l', xlab="Valor de p en modelos AR(p)", ylab="AICC")

dev.off()
png("aicc.png")
plot(1:20, vector, type='l', xlab="Valor de p en modelos AR(p)", ylab="AICC")
dev.off()

# Encontramos mínimos locales en los valores de p = 2, 4, 7 y 13.
# Tomaremos como hipótesis de trabajo los modelos AR(2), AR(4), AR(7), AR(13).

### -------------------------------------------------------------------------
### Modelo AR(2):
### -------------------------------------------------------------------------
arima(x = df_milk3, order = c(2, 0, 0), include.mean = FALSE)
# Coefficients:
#          ar1     ar2
#       0.6885  0.2180
# s.e.  0.0754  0.0758
# 
# sigma^2 estimated as 49.8:  log likelihood = -567.46,  aic = 1140.91

### -------------------------------------------------------------------------
### Modelo AR(4):
### -------------------------------------------------------------------------
arima(x = df_milk3, order = c(4, 0, 0), include.mean = FALSE)
# Coefficients:
#          ar1     ar2     ar3      ar4
#       0.6842  0.1998  0.1438  -0.1274
# s.e.  0.0764  0.0941  0.0941   0.0778
# 
# sigma^2 estimated as 48.85:  log likelihood = -565.87,  aic = 1141.73

### -------------------------------------------------------------------------
### Modelo AR(7):
### -------------------------------------------------------------------------
arima(x = df_milk3, order = c(7, 0, 0), include.mean = FALSE)
# Coefficients:
#          ar1     ar2     ar3      ar4     ar5      ar6     ar7
#       0.6979  0.1764  0.1740  -0.1451  0.0153  -0.1916  0.1898
# s.e.  0.0756  0.0933  0.0947   0.0948  0.0947   0.0935  0.0776
# 
# sigma^2 estimated as 46.92:  log likelihood = -562.63,  aic = 1141.25

### -------------------------------------------------------------------------
### Modelo AR(13):
### -------------------------------------------------------------------------
arima(x = df_milk3, order = c(13, 0, 0), include.mean = FALSE)
# Coefficients:
#          ar1     ar2     ar3      ar4      ar5      ar6     ar7      ar8     ar9     ar10     ar11    ar12     ar13
#       0.7434  0.1404  0.1719  -0.1513  -0.0102  -0.1354  0.1948  -0.0183  0.0587  -0.0956  -0.0995  0.2883  -0.1853
# s.e.  0.0755  0.0931  0.0938   0.0946   0.0958   0.0947  0.0949   0.0961  0.0959   0.0952   0.0974  0.0962   0.0797
# 
# sigma^2 estimated as 43.42:  log likelihood = -556.58,  aic = 1141.15

# No todos los coeficientes en los modelos AR(4), AR(7) y AR(13) son significativos.
# Quizá los modelos AR ajustados se pueden mejorar estableciendo coeficientes insignificantes a cero.

### -------------------------------------------------------------------------
### Intentamos mejorar el modelo AR(7).
### -------------------------------------------------------------------------

# Primero fijaremos ϕ4=0 y ϕ5=0
arima(x = df_milk3, order = c(7, 0, 0), fixed = c(NA, NA, NA, 0, 0, NA, NA, 0), transform.pars = FALSE)
# 
# Coefficients:
#          ar1     ar2     ar3  ar4  ar5     ar6     ar7  intercept
#       0.6862  0.1613  0.1140    0    0  -0.218  0.1718          0
# s.e.  0.0756  0.0924  0.0865    0    0   0.085  0.0761          0
# 
# sigma^2 estimated as 47.64:  log likelihood = -563.87,  aic = 1139.74

# Ahora probaremos añadiendo ϕ3=0
arima(x = df_milk3, order = c(7, 0, 0), fixed = c(NA, NA, 0, 0, 0, NA, NA, 0), transform.pars = FALSE)
# 
# Coefficients:
#          ar1     ar2  ar3  ar4  ar5      ar6     ar7  intercept
#       0.7051  0.2223    0    0    0  -0.1820  0.1693          0
# s.e.  0.0745  0.0804    0    0    0   0.0809  0.0765          0
# 
# sigma^2 estimated as 48.15:  log likelihood = -564.73,  aic = 1139.46

# Vemos en los coeficientes y el criterio AIC  que este modelo AR(7) es significativamente mejor.

### -------------------------------------------------------------------------
### Comparamos los modelos aurorregresivos competidores
### -------------------------------------------------------------------------

# AR(2):
#   AIC = 1140.91
#   sigma^2 estimated = 49.8
#   Ut = 0.689Ut − 1 + 0.218Ut − 2 + Zt.
# 
# AR(4):
#   AIC = 1141.73
#   sigma^2 estimated = 48.85
#   Ut = 0.684Ut − 1 + 0.2Ut − 2 + 0.144Ut − 3 − 0.127Ut − 4 + Zt
# 
# AR(7) mejorado:
#   AIC = 1139.46
#   sigma^2 estimated = 48.15
#   Ut = 0.705Ut − 1 + 0.222Ut − 2 − 0.182Ut − 6 + 0.169Ut − 7 + Zt
# 
# AR(13):
#   AIC = 1141.15
#   sigma^2 estimated = 243.425
#   Ut = 0.743Ut - 1 + 0.140Ut - 2 + 0.172Ut - 3 - 0.151Ut - 4 - 0.010Ut - 5 - 0.135Ut - 6 - 0.195Ut - 7 - 0.018Ut - 8 + 0.059Ut - 9 - 0.096Ut - 10 - 0.100Ut - 11 + 0.288Ut - 12 - 0.185Ut

### -------------------------------------------------------------------------
### Comprobamos el diagnóstico para AR(2):
### -------------------------------------------------------------------------
AR2 = arima(df_milk3, order = c(2,0,0), include.mean = FALSE)
mod.AR2 = specify(ar=AR2$coef)
residuosAR2 = Resid(df_milk3, a=mod.AR2)
test(residuosAR2)

dev.off()
png("diagnostico_ar2.png")
test(residuosAR2)
dev.off()

# Null hypothesis: Residuals are iid noise.
# Test                        Distribution Statistic   p-value
# Ljung-Box Q                Q ~ chisq(20)      28.8    0.0918
# McLeod-Li Q                Q ~ chisq(20)      7.75    0.9934
# Turning points T  (T-110.7)/5.4 ~ N(0,1)       102    0.1108
# Diff signs S       (S-83.5)/3.8 ~ N(0,1)        81    0.5053
# Rank P           (P-7014)/364.5 ~ N(0,1)      6978    0.9213

# Pasa todas las pruebas a nivel 0,05, pero la prueba de Ljung-Box con 0,09.

### -------------------------------------------------------------------------
### Comprobamos el diagnóstico para AR(4):
### -------------------------------------------------------------------------
AR4 = arima(df_milk3, order = c(4,0,0), include.mean = FALSE)
mod.AR4 = specify(ar=AR4$coef)
residuosAR4 = Resid(df_milk3, a=mod.AR4)
test(residuosAR4)

dev.off()
png("diagnostico_ar4.png")
test(residuosAR4)
dev.off()

## Null hypothesis: Residuals are iid noise.
## Test                        Distribution Statistic   p-value
## Ljung-Box Q                Q ~ chisq(20)     28.35    0.1014
## McLeod-Li Q                Q ~ chisq(20)      8.36    0.9892
## Turning points T  (T-110.7)/5.4 ~ N(0,1)       102    0.1108
## Diff signs S       (S-83.5)/3.8 ~ N(0,1)        83     0.894
## Rank P           (P-7014)/364.5 ~ N(0,1)      6962    0.8866

# Pasa todos los test.

### -------------------------------------------------------------------------
### Comprobamos el diagnóstico para AR(7) mejorado:
### -------------------------------------------------------------------------
AR7 = arima(df_milk3, order = c(7,0,0), fixed = c(NA,NA,0,0,0,NA,NA,0), transform.pars = FALSE)
mod.AR7 = specify(ar=AR7$coef)
residuosAR7 = Resid(df_milk3, a=mod.AR7)
test(residuosAR7)

dev.off()
png("diagnostico_ar7.png")
test(residuosAR7)
dev.off()

## Null hypothesis: Residuals are iid noise.
## Test                        Distribution Statistic   p-value
## Ljung-Box Q                Q ~ chisq(20)     21.63    0.3607
## McLeod-Li Q                Q ~ chisq(20)      7.63     0.994
## Turning points T  (T-110.7)/5.4 ~ N(0,1)       104      0.22
## Diff signs S       (S-83.5)/3.8 ~ N(0,1)        85    0.6894
## Rank P           (P-7014)/364.5 ~ N(0,1)      6892    0.7379

# Pasa todos los test.

### -------------------------------------------------------------------------
### Comprobamos el diagnóstico para AR(13):
### -------------------------------------------------------------------------
AR13 = arima(df_milk3,order=c(13,0,0), include.mean=FALSE)
mod.AR13 = specify(ar=AR13$coef)
residuosAR13 = Resid(df_milk3, a=mod.AR13)
test(residuosAR13)

dev.off()
png("diagnostico_ar13.png")
test(residuosAR13)
dev.off()

# Null hypothesis: Residuals are iid noise.
# Test                        Distribution Statistic   p-value
# Ljung-Box Q                Q ~ chisq(20)      6.47    0.9981
# McLeod-Li Q                Q ~ chisq(20)     13.08    0.8739
# Turning points T  (T-110.7)/5.4 ~ N(0,1)       102    0.1108
# Diff signs S       (S-83.5)/3.8 ~ N(0,1)        82    0.6894
# Rank P           (P-7014)/364.5 ~ N(0,1)      6957    0.8757

# Pasa todos los test.

### -------------------------------------------------------------------------
### Obtenemos un pronóstico a 24 meses con modelo AR(7) ajustado:
### -------------------------------------------------------------------------

xv = c("season", 12, "trend", 1)
forecast(produccion, xv, mod.AR7, h=24)

# Step     Prediction      sqrt(MSE)    Lower Bound    Upper Bound
# 1        867.533              1        865.573        869.493
# 2       830.3753       1.223583       827.9771       832.7736
# 3       926.9006       1.419415       924.1185       929.6826
# 4       943.6919       1.567043       940.6205       946.7633
# 5         1007.2       1.688229       1003.891       1010.509
# 6       980.2346       1.788504       976.7292       983.7401
# 7       933.7108       1.827185       930.1295       937.2921
# 8       893.5253       1.878474       889.8434       897.2071
# 9       853.4916       1.916325       849.7356       857.2476
# 10       859.1351       1.950799       855.3115       862.9587
# 11       830.4535       1.980177       826.5723       834.3346
# 12       869.2514       2.005816         865.32       873.1828
# 13       895.7047       2.033249       891.7195       899.6898
# 14       857.7626       2.053792       853.7372        861.788
# 15       953.6157       2.073218       949.5522       957.6792
# 16        970.715       2.089681       966.6193       974.8108
# 17       1033.313       2.104288       1029.189       1037.438
# 18       1007.309       2.117047       1003.159       1011.458
# 19       959.6912       2.127656        955.521       963.8614
# 20       919.4159       2.137495       915.2264       923.6054
# 21       879.0654       2.145848       874.8595       883.2713
# 22       884.2956       2.153319       880.0751       888.5161
# 23       855.4698       2.159839       851.2366       859.7031
# 24       893.7455       2.165592       889.5009       897.9901

dev.off()
png("pronostico.png")
forecast(produccion, xv, mod.AR7, h=24, opt=2)
dev.off()

### -------------------------------------------------------------------------
### Enlaces
### -------------------------------------------------------------------------

# -- Análisis de Series Temporales
# http://www.juanantonio.info/p_research/statistics/r/docs/analisis1.1.pdf

# -- Introducción a Series de Tiempo
# http://www.estadisticas.gobierno.pr/iepr/LinkClick.aspx?fileticket=4_BxecUaZmg%3D

# -- Modelos AR(1) y ARI(1,1)
# http://www.est.uc3m.es/esp/nueva_docencia/comp_col_get/lade/econometria_II/documentacion/Tema2bis_esther_ruiz_2007.pdf
