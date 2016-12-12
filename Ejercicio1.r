## -------------------------------------------------------------------------
## SCRIPT....: PrecioVentaViviendasSegunSuperficie.r
## CURSO.....: Master en Big Data y Business Analytics
## ASIGNATURA: Análisis Estadístico
## EJERCICIO.: Construcción de un modelo de regresión
## ALUMNO....: Juan Antonio García Cuevas
## FECHA.....: 11/12/2016
## -------------------------------------------------------------------------

### -------------------------------------------------------------------------
### Iniciazación de librerías
### -------------------------------------------------------------------------
if (!require("gap")) {
  install.packages("gap") 
  library(gap)
}
install.packages("ggplot2") 
install.packages("dplyr")
install.packages("lattice")
install.packages("car")
install.packages("GGally")
install.packages("data.table")
install.packages("glmnet")
install.packages("plyr")
install.packages("vcd")
install.packages("vcdExtra")
install.packages("psych")
install.packages("car")
install.packages("ggExtra")
install.packages("ROCR")
install.packages("caTools")
install.packages("MASS")
install.packages("memisc")

library(gap)
library(ggplot2) 
library(dplyr)
library(lattice)
library(car)
library(GGally)
library(data.table)
library(glmnet)
library(plyr)
library(vcd)
library(vcdExtra)
library(psych)
library(car)
library(ggExtra)
library(ROCR)
library(caTools)
library(MASS)
library(memisc)

### ##########################################################################################
### ##########################################################################################
###
### 1.- Analizar el efecto de la superficie de la vivienda en el precio de la vivienda
###
### ##########################################################################################
### ##########################################################################################

### -------------------------------------------------------------------------
### -------------------------------------------------------------------------
### Carga de datos:
### Nos situamos en el directorio del fichero CSV y lo cargamos en un dataset
### -------------------------------------------------------------------------
### -------------------------------------------------------------------------

setwd("/home/juan/MASTER BIG DATA - CIFF/HERRAMIENTAS/ANÁLISIS ESTADÍSTICO/Ejercicio1")
getwd()
Ventas = read.csv("house_train.csv", stringsAsFactors=FALSE, sep=",")

### -------------------------------------------------------------------------
### Descripción de datos:
### -------------------------------------------------------------------------

str(Ventas)
head(Ventas)
summary(Ventas)

labels <- colnames(Ventas)
for (label in labels) {
  numvalores <- nrow(unique(Ventas[label]))
  cat('- Número de valores distintos de', label, ':', numvalores, '\n')
}
print('- Valores únicos de algunas variables')
for (label in labels) {
  numvalores <- nrow(unique(Ventas[label]))
  if(numvalores < 10) {
    print(unique(Ventas[label]))
  }
}

### Información sobre el conjunto de datos original:
# - El número de observaciones es de 17.384.
# - Hay 21 variables de distintos tipos: numéricas y alfanuméricas.
# - Las variables floors, waterfront, view y condition presentan un número reducido de valores distintos.

### Comprobamos que no hay ningún NaN.
Ventas[!complete.cases(Ventas),]

### -------------------------------------------------------------------------
### Análisis preliminar y normalización de la variable price:
### -------------------------------------------------------------------------

# Las variables de tipo monetario, como es el caso de price, suelen ser muy sesgadas y presentar muchos outliers.
# Lo comprobaremos y, en su caso, la normalizaremos con una transformación logarítmica.
# Mostramos gráficas para detectar visualmente la presencia de outliers y ver la forma de la distribución:

boxplot(table(Ventas$price))
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$price), fill = "black", color = "grey") + ggtitle("Price Distribution") + xlab("Price") + ylab("Frequency")

dev.off()
png("var_price_boxplot.png")
boxplot(table(Ventas$price))
dev.off()
png("var_price_ggplot.png")
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$price), fill = "black", color = "grey") + ggtitle("Price Distribution") + xlab("Price") + ylab("Frequency")
dev.off()

# En las gráficas podemos observar que la variable está muy sesgada a la derecha y presenta muchos outliers.
# Normalizamos la variable mediante transfomación logarítmica y la almacenaremos en una nueva variable en el dataset.
# Mostramos de nuevo las gráficas para detectar visualmente los outliers y la forma de la distribución de la nueva variable:

Ventas$price_log <- log(Ventas$price)
boxplot(Ventas$price_log)
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$price_log), fill = "black", color = "grey") + ggtitle("Price Distribution") + xlab("Price") + ylab("Frequency")

dev.off()
png("var_price_boxplot_log.png")
boxplot(Ventas$price_log)
dev.off()
png("var_price_ggplot_log.png")
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$price_log), fill = "black", color = "grey") + ggtitle("Price Distribution") + xlab("Price") + ylab("Frequency")
dev.off()

# La transformación logarítmica ha normalizado la distribución de price, aunque sigue presentando outliers a ambos lados y está algo sesgada a la derecha.

### -------------------------------------------------------------------------
### Análisis preliminar y normalización de la variable sqft_living:
### -------------------------------------------------------------------------

# Al igual que hemos hecho con la variable price, vamos a determinar visualmente los outliers y la distribución de la variable sqft_living.
# Mostramos gráficas para detectar visualmente la presencia de outliers y ver la forma de la distribución:

boxplot(table(Ventas$sqft_living))
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$sqft_living), fill = "black", color = "grey") + ggtitle("Sqft living Distribution") + xlab("Sqft living") + ylab("Frequency")

dev.off()
png("var_sqft_living_boxplot.png")
boxplot(table(Ventas$sqft_living))
dev.off()
png("var_sqft_living_ggplot.png")
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$sqft_living), fill = "black", color = "grey") + ggtitle("Sqft living Distribution") + xlab("Sqft living") + ylab("Frequency")
dev.off()

# En las gráficas podemos observar que la variable está también muy sesgada a la derecha y presenta muchos outliers.
# Normalizamos la variable mediante transfomación logarítmica y la almacenamos en una nueva variable en el dataset.
# Mostramos de nuevo las gráficas para detectar visualmente los outliers y la forma de la distribución de la nueva variable:

Ventas$sqft_living_log <- log(Ventas$sqft_living)
boxplot(Ventas$sqft_living_log)
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$sqft_living_log), fill = "black", color = "grey") + ggtitle("Price Distribution") + xlab("Price") + ylab("Frequency")

dev.off()
png("var_sqft_living_boxplot_log.png")
boxplot(Ventas$sqft_living_log)
dev.off()
png("var_sqft_living_ggplot_log.png")
ggplot(data=Ventas) + geom_histogram(aes(x=Ventas$sqft_living_log), fill = "black", color = "grey") + ggtitle("Price Distribution") + xlab("Price") + ylab("Frequency")
dev.off()

# La transformación logarítmica ha normalizado la distribución de sqft_living, aunque sigue presentando outliers a ambos lados y está algo sesgada a la derecha.

### -------------------------------------------------------------------------
### -------------------------------------------------------------------------
### Análisis del efecto de la superficie de la vivienda en el precio:
### -------------------------------------------------------------------------
### -------------------------------------------------------------------------

# Crearemos 4 modelos de regresión para determinar cual se ajusta más a una recta teniendo en cuenta una única variable explicativa: sqft_living. 

### -------------------------------------------------------------------------
### Primer modelo de regresión: Level-Level (efecto marginal)
### -------------------------------------------------------------------------

# Se aplica un modelo estrictamente lineal (level-level), ajustando una recta, y teniendo en cuenta tan solo una variable explicatica: sqft_living.
# La regresión se hace en niveles; se estima el efecto marginal.
# Interpretación del coeficiente estimado: un aumento de 1 unidad en sqft-living se corresponde con un aumento de beta unidades en price.

### Creamos el modelo
modelo1 = lm(price ~ sqft_living, data = Ventas)
summary(modelo1)

### Generamos las gráficas de análisis de residuos
par(mfrow = c(2, 2))
plot(modelo1$residuals)
smoothScatter(modelo1$residuals)
hist(modelo1$residuals)
qqnorm(modelo1$residuals); qqline(modelo1$residuals, col = 2)

# En el análisis de los residuos se puede ver que no se cumplen los supuestos de homogeneidad ni normalidad, por lo que la aplicación de OLS no es correcta.

### Exportamos a fichero las gráficas de análisis de residuos
dev.off()
png("residuos_lm1.png")
par(mfrow = c(2, 2))
plot(modelo1$residuals)
smoothScatter(modelo1$residuals)
hist(modelo1$residuals)
qqnorm(modelo1$residuals); qqline(modelo1$residuals, col = 2)
dev.off()

### Obtenemos el intervalo de confianza para el 95%
confint(modelo1, level = 0.95)

### -------------------------------------------------------------------------
### Segundo modelo de regresión: Log-Level (semieslasticidad)
### -------------------------------------------------------------------------

# Se aplica un modelo log-level, ajunstando una recta, y teniendo en cuenta tan solo una variable explicatica: sqft_living.
# La variable dependiente se expresa en logaritmos. Se conococe como semilelasticidad.
# Interpretación del coeficiente estimado: un aumento de 1 unidad en sqft-living se corresponde con un aumento del 100*beta% en price. 

### Creamos el modelo
modelo2 = lm(price_log ~ sqft_living, data = Ventas)
summary(modelo2)

### Generamos las gráficas de análisis de residuos
par(mfrow = c(2, 2))
plot(modelo2$residuals)
smoothScatter(modelo2$residuals)
hist(modelo2$residuals)
qqnorm(modelo2$residuals); qqline(modelo2$residuals, col = 2)

# En el análisis de los residuos parece verse que se cumplen los supuestos de normalidad y homogeneidad, aunque hay una gran presencia de outliers.
# La hipótesis de linealidad también se cumple. R² = 0.48.

### Exportamos a fichero las gráficas de análisis de residuos
dev.off()
png("residuos_lm2.png")
par(mfrow = c(2, 2))
plot(modelo2$residuals)
smoothScatter(modelo2$residuals)
hist(modelo2$residuals)
qqnorm(modelo2$residuals); qqline(modelo2$residuals, col = 2)
dev.off()

### Obtenemos el intervalo de confianza para el 95%
confint(modelo2, level = 0.95)

### -------------------------------------------------------------------------
### Tercer modelo de regresión: Level-Log
### -------------------------------------------------------------------------

# Se aplica un modelo level-log, ajunstando una recta, y teniendo en cuenta tan solo una variable explicatica: sqft_living.
# La variable independiente se expresa en logaritmos.
# Interpretación del coeficiente estimado: un aumento del 1% en sqft-living se corresponde con un aumento de beta/100 unidades en price.

### Creamos el modelo
modelo3 = lm(price ~ sqft_living_log, data = Ventas)
summary(modelo3)

### Generamos las gráficas de análisis de residuos
par(mfrow = c(2, 2))
plot(modelo3$residuals)
smoothScatter(modelo3$residuals)
hist(modelo3$residuals)
qqnorm(modelo3$residuals); qqline(modelo3$residuals, col = 2)

# En el análisis de los residuos se puede ver que no se cumplen los supuestos de homogeneidad ni normalidad, por lo que la aplicación de OLS no es correcta.

### Exportamos a fichero las gráficas de análisis de residuos
dev.off()
png("residuos_lm3.png")
par(mfrow = c(2, 2))
plot(modelo3$residuals)
smoothScatter(modelo3$residuals)
hist(modelo3$residuals)
qqnorm(modelo3$residuals); qqline(modelo3$residuals, col = 2)
dev.off()

### Obtenemos el intervalo de confianza para el 95%
confint(modelo3, level = 0.95)

### -------------------------------------------------------------------------
### Cuarto modelo de regresión: Log-Log (elasticidad)
### -------------------------------------------------------------------------

# Se aplica un modelo log-log, ajunstando una recta, y teniendo en cuenta tan solo una variable explicatica: sqft_living.
# Ambas variables, dependiente e independiente, se expresan en logaritmos. Se conoce como elasticidad constante.
# Interpretación del coeficiente estimado: una variación del 1% en sqft_living se corresponde con una varición promedio en price de un beta 1%.

### Creamos el modelo
modelo4 = lm(price_log ~ sqft_living_log, data = Ventas)
summary(modelo4)

### Generamos las gráficas de análisis de residuos
par(mfrow = c(2, 2))
plot(modelo4$residuals)
smoothScatter(modelo4$residuals)
hist(modelo4$residuals)
qqnorm(modelo4$residuals); qqline(modelo4$residuals, col = 2)

# En el análisis de los residuos parece verse que se cumplen bastante bien los supuestos de normalidad y homogeneidad.
# La hipótesis de linealidad también se cumple. R² = 0.45.

### Exportamos a fichero las gráficas de análisis de residuos
dev.off()
png("residuos_lm4.png")
par(mfrow = c(2, 2))
plot(modelo4$residuals)
smoothScatter(modelo4$residuals)
hist(modelo4$residuals)
qqnorm(modelo4$residuals); qqline(modelo4$residuals, col = 2)
dev.off()

### Obtenemos el intervalo de confianza para el 95%
confint(modelo4, level = 0.95)

### -------------------------------------------------------------------------
### Comparativa de los cuatro modelos
### -------------------------------------------------------------------------

par(mfrow = c(2, 2))
qqnorm(modelo1$residuals, main='Normal Q-Q Plot - Modelo 1'); qqline(modelo1$residuals, col = 2)
qqnorm(modelo2$residuals, main='Normal Q-Q Plot - Modelo 2'); qqline(modelo2$residuals, col = 2)
qqnorm(modelo3$residuals, main='Normal Q-Q Plot - Modelo 3'); qqline(modelo3$residuals, col = 2)
qqnorm(modelo4$residuals, main='Normal Q-Q Plot - Modelo 4'); qqline(modelo4$residuals, col = 2)

dev.off()
png("comparativa_qqnorm.png")
par(mfrow = c(2, 2))
qqnorm(modelo1$residuals, main='Normal Q-Q Plot - Modelo 1'); qqline(modelo1$residuals, col = 2)
qqnorm(modelo2$residuals, main='Normal Q-Q Plot - Modelo 2'); qqline(modelo2$residuals, col = 2)
qqnorm(modelo3$residuals, main='Normal Q-Q Plot - Modelo 3'); qqline(modelo3$residuals, col = 2)
qqnorm(modelo4$residuals, main='Normal Q-Q Plot - Modelo 4'); qqline(modelo4$residuals, col = 2)
dev.off()

# Podemos ver gráficamete que los modelos que mejor ajustan son el segundo y el cuarto, sobretodo el segundo.
# Aún así, vamos a compararlos mediantes distintas métricas para determinar cuantitativamente cual puede ser mejor:

### Métricas R² y R² ajustado
summary(modelo2)
# Multiple R-squared:  0.4828,	Adjusted R-squared:  0.4828 
summary(modelo4)
# Multiple R-squared:  0.4546,	Adjusted R-squared:  0.4546 

### Métrica AIC
AIC(modelo2)
# 15587.46
AIC(modelo4)
# 16510.51

### Métrica BIC 
BIC(modelo2)
# 15610.75
BIC(modelo4)
# 16533.8

# Las tres medidas parecen indicar que el modelo2 es mejor.

# Mostramos ahora en un gráfico la distribución y la recta de regresión con histogramas marginales
plot_center = ggplot(Ventas, aes(x=sqft_living, y=price_log)) + geom_point() + geom_smooth(method="lm")
ggMarginal(plot_center, type="histogram")

dev.off()
png("ggMarginal.png")
plot_center = ggplot(Ventas, aes(x=sqft_living, y=price_log)) + geom_point() + geom_smooth(method="lm")
ggMarginal(plot_center, type="histogram")
dev.off()


### ##########################################################################################
### ##########################################################################################
###
### 2.- Estimar el precio de venta de unos inmuebles de la cartera de la empresa
###
### ##########################################################################################
### ##########################################################################################

### -------------------------------------------------------------------------
### Realizamos un análisis más profundo de todas las variables
### -------------------------------------------------------------------------

### Comenzarmos por realizar un análisis más profundo de todas las variables.

# Primero eliminamos las variables Id y price.

# Después agrupamos las variables restantes de alguna forma más o menos lógica:
# 
# Variables relacionadas con el interior, con las dependencias internas de la vivienda:
# - bedrooms: número de habitaciones
# - bathrooms: número de baños
# - floors: número de plantas
# 
# Variables relacionadas con el exterior de la vivienda:
# - waterfront: indicador de estancia en primera línea al mar
# - view: número de orientaciones de la vivienda
# 
# Variables relacionadas con medidas de superficie:
# - sqft_living=superficie de la vivienda (en pies) 
# - sqft_lot: superficie de la parcela (en pies)
# - sqft_above: campo desconocido
# - sqft_basement: campo desconocido
# - sqft_living15: campo desconocido
# - sqft_lot15:campo desconocido
# 
# Variables relacionadas con fechas:
# - yr_built: año de construcción
# - yr_renovated: año de reforma
# - date: fecha asociada a la información 
# 
# Variables relacionadas con la localización de la vivienda:
# - zipcode: codigo postal
# - lat: latitud
# - long: longitud
# 
# Variables completamente desconocidas:
# - condition: campo desconocido
# - grade: campo desconocido

### -------------------------------------------------------------------------
### Analizamos las variables relacionadas con el interior, con las dependencias internas de la vivienda: bedrooms, bathrooms y floors
### -------------------------------------------------------------------------

table(Ventas$bedrooms)
table(Ventas$bathrooms)
table(Ventas$fllors)
ggpairs(Ventas[, c("bedrooms", "bathrooms", "floors", "sqft_living", "price")])

dev.off()
png("ggpairs_interior.png")
ggpairs(Ventas[, c("bedrooms", "bathrooms", "floors", "sqft_living", "price")])
dev.off()

# Excluiremos del modelo las siguientes variables: 
# - bedrooms y bathrooms: porque están muy correlacionadas con sqft_living (0.60 y 0.76) y entre sí (0.53).

### -------------------------------------------------------------------------
### Analizamos las variables relacionadas con el exterior de la vivienda: waterfront y view
### -------------------------------------------------------------------------

table(Ventas$waterfront)
table(Ventas$view)
ggpairs(Ventas[, c("waterfront", "view", "price")])

dev.off()
png("ggpairs_exterior.png")
ggpairs(Ventas[, c("waterfront", "view", "price")])
dev.off()

# Excluiremos del modelo las siguientes variables: 
# - waterfront y view: porque su correlación con price es bastante baja.

### -------------------------------------------------------------------------
### Analizamos las variables relacionadas con medidas de superficie: sqft_living, sqft_lot, sqft_above, sqft_basement, sqft_living15, sqft_lot15
### -------------------------------------------------------------------------

table(Ventas$sqft_lot)
table(Ventas$sqft_above)
table(Ventas$sqft_basement==0)
table(Ventas$sqft_living15)
table(Ventas$sqft_lot15)

# La variable sqft_basement parece hacer referencia a la superficie del "sótano", y vemos que hay 10.552 viviendas que tienen ese valor a 0, por lo que vamos a crear una variable dummy.
Ventas$basement<-(ifelse(Ventas$sqft_basement==0,0,1))

ggpairs(Ventas[, c("sqft_lot", "sqft_above", "basement", "sqft_living15", "sqft_lot15", "sqft_living", "price")])
dev.off()
png("ggpairs_superficie.png")
ggpairs(Ventas[, c("sqft_lot", "sqft_above", "basement", "sqft_living15", "sqft_lot15", "sqft_living", "price")])
dev.off()

# Excluiremos del modelo las siguientes variables: 
# - sqft-living15: por su alta correlación con sqft-living (0.76).
# - sqft-lot15: por su alta correlación con sqft-lot (0.73).
# - sqft-above: por su casi perfecta correlación con sqft-living (0.88)
# - basement: por su escasa correlación con price.

### -------------------------------------------------------------------------
### Analizamos las variables relacionadas con fechas: yr_built, yr_renovated, date
### -------------------------------------------------------------------------

table(Ventas$date)
table(Ventas$yr_built)
table(Ventas$yr_renovated==0)

# Convertimos la información de la variable date en fechas válidas
Ventas$date<-as.Date(Ventas$date,"%Y%m%d")

# Vemos que hay 724 viviendas reformadas y 16.660 sin reformar, por lo que vamos a crear una variable dummy.
Ventas$renovated<-(ifelse(Ventas$yr_renovated==0,0,1))

ggpairs(Ventas[, c("yr_built", "renovated", "date", "price")])
dev.off()
png("ggpairs_fechas.png")
ggpairs(Ventas[, c("yr_built", "renovated", "date", "price")])
dev.off()

# Excluiremos del modelo las siguientes variables: 
# - yr_built, yr_renovated y date: por su baja correlación con price.

### -------------------------------------------------------------------------
### Analizamos las variables relacionadas con la localización de la vivienda: zipcode, lat, long
### -------------------------------------------------------------------------

table(Ventas$zipcode)
table(Ventas$lat)
table(Ventas$long)
ggpairs(Ventas[, c("zipcode", "lat", "long", "price")])

dev.off()
png("ggpairs_localizacion.png")
ggpairs(Ventas[, c("zipcode", "lat", "long", "price")])
dev.off()

# Excluiremos del modelo las siguientes variables: 
# - Zipcode: porque tiene muchos niveles (70).

### -------------------------------------------------------------------------
### Analizamos las variables completamente desconocidas: condition, grade
### -------------------------------------------------------------------------

table(Ventas$condition)
table(Ventas$grade)
ggpairs(Ventas[, c("condition", "grade", "price")])

dev.off()
png("ggpairs_desconocidas.png")
ggpairs(Ventas[, c("condition", "grade", "price")])
dev.off()

# Excluiremos del modelo las siguientes variables: 
# - condition: por su baja correlación con price.  

### -------------------------------------------------------------------------
### Obtenemos el conjunto de datos para el modelo
### -------------------------------------------------------------------------

Ventas2 <- Ventas
variables_a_excluir <- c("id", "price", "bedrooms", "bathrooms", "sqft-living15", "sqft-lot15", "sqft-above", "yr_built", "yr_renovated", "renovated", "date", "waterfront", "view", "condition", "sqft_basement", "basement")
Ventas2 <- Ventas2[ , !(names(Ventas2) %in% variables_a_excluir)]

### Creamos los conjuntos de entrenamiento y prueba
set.seed(12357)
subsets = sample.split(Ventas2$price_log, SplitRatio = 0.7)
Train = subset(Ventas2, subsets == TRUE)
Test = subset(Ventas2, subsets == FALSE)

### Obtenemos el modelo y analizamos los residuos
modelo = lm(price_log~., data=Train)
summary(modelo)
par(mfrow = c(2, 2))
plot(modelo)

dev.off()
png("modelo_train.png")
par(mfrow = c(2, 2))
plot(modelo)
dev.off()

# Parecen cumplirse las hipotesis de normalidad y hommocedasticidad.

### Hacemos la estimación robusta:
modelo_r <- rlm(price_log~., data=Train)
summary(modelo_r)

coef(modelo)
coef(modelo_r)

# No hay diferencias considerables entre los estimadores OLS y estimadores OLS robustos, con la excepción de floors. El estimador de floors parece no converger, se ejecutará la regresión  Ridge.


### -------------------------------------------------------------------------
### Evaluamos el modelo comparando R adjusted en train y test
### -------------------------------------------------------------------------

Train$prediccion = predict(modelo, type="response")
R2_Train = 1 - sum((Train$price_log-Train$prediccion)^2)/sum((Train$price_log-mean(Train$price_log))^2)
R2_Train

Test$prediccion = predict(modelo,newdata=Test,type="response")
R2_Test = 1 - sum((Test$price_log-Test$prediccion)^2)/sum((Test$price_log-mean(Test$price_log))^2)
R2_Test

# Vemos que los R² adjusted en train y test son parecidos: 0.8933131 y 0.894066

### -------------------------------------------------------------------------
### Evaluamos el modelo con un análisis de colinealidad
### -------------------------------------------------------------------------

# En primer lugar, se comprueba que no hay diferencias entre R^2 y R^2 ajustados en Train.

summary(modelo)$r.squared
summary(modelo)$adj.r.squared

# En segundo lugar, se obtiene la matriz de correlaciones, para estudiar las relaciones entre variables independientes.

dropscor <- c("lat","long","zipcode", "price_log", "logsqft_lot", "prediccion") 
# se eliman aquellas variables creadas en el exploratorio asi como las que determina la función alias
traincor<-Train[ , !(names(Train) %in% dropscor)]

cor(traincor)

# Como puede observarse hay correlaciones altas entre variables independientes. No se repiten los resultados, ya que se detallaron en el exploratorio.Cuando dos de los variables explicativas están muy correlacionados entre sí puede provocar el aumento de la Varianza del modelo y la no convergencia de los coeficientes asociados.


### Modelos Ridge y Lasso

# Los modelos de Regresión Ridge y Lasso son modelo con coeficiente de regularización para evitar que los coeficientes tomen valores muy elevados. En nuestro caso, no tenemos coeficientes elevados en la estimacion OLS si en la estimación OLS robusta, no obstante como la matriz de correlaciones parece indicar que hay relaciones lineales altas entre variables independientes, vamos a proceder a su aplicación.

# - Se utilizan para corregir problemas de overfitting y de multicolinealidad.
# - Lasso también se utiliza para reducir la complejidad mediante selección de variables.
# - Con Lasso se simplifica el modelo, pero se hunden los R2
# - Como nuestros esimadores están cercanos a cero, se aplicará Ridge y no Lasso.


### -------------------------------------------------------------------------
### Regresión Ridge
### -------------------------------------------------------------------------

variables <- c("bedrooms", "bathrooms", "sqft-living15", "sqft-lot15", "sqft-above", "yr_built", "yr_renovated", "renovated", "date", "waterfront", "view", "condition", "sqft_basement", "basement")
Lambda = 5
Pruebas = 100
Coeficientes = matrix(0, nrow=Pruebas, ncol=length(variables)+1)
Coeficientes = as.data.frame(Coeficientes)
colnames(Coeficientes) = c("termino_independiente", variables)
SCE_TRAIN1_modeloRidge = c()
STC_TRAIN1_modeloRidge = c()
R2_TRAIN1_modeloRidge = c()
SCE_TEST1_modeloRidge = c()
STC_TEST1_modeloRidge = c()
R2_TEST1_modeloRidge = c()
for (i in 1:Pruebas) {
  modelo_glmnet=glmnet(x=as.matrix(Train[,variables]),y=Train$price_log,lambda=Lambda*(i-1)/Pruebas,alpha=0)
  Coeficientes[i,]=c(modelo_glmnet$a0,as.vector(modelo_glmnet$beta))
  prediccionesTrain=predict(modelo_glmnet,newx = as.matrix(Train[,variables]))
  SCE_TRAIN1_modeloRidge=c(SCE_TRAIN1_modeloRidge,sum((Train$price_log-prediccionesTrain)^2))
  STC_TRAIN1_modeloRidge=c(STC_TRAIN1_modeloRidge,sum((Train$price_log-mean(Train$price_log))^2))
  R2_TRAIN1_modeloRidge=c(R2_TRAIN1_modeloRidge,1-sum((Train$price_log-prediccionesTrain)^2)/sum((Train$price_log-mean(Train$price_log))^2))
  
  prediccionesTest=predict(modelo_glmnet,newx = as.matrix(Test[,variables]))
  SCE_TEST1_modeloRidge=c(SCE_TEST1_modeloRidge,sum((Test$price_log-prediccionesTest)^2))
  STC_TEST1_modeloRidge=c(STC_TEST1_modeloRidge,sum((Test$price_log-mean(Test$price_log))^2))
  R2_TEST1_modeloRidge=c(R2_TEST1_modeloRidge,1-sum((Test$price_log-prediccionesTest)^2)/sum((Test$price_log-mean(Test$price_log))^2))
}

colores=rainbow(length(variables))
plot(Coeficientes[,1],type="l",col="white",ylim=c(-4,2))
for (i in 1:length(variables)){
  lines(Coeficientes[,i+1],type="l",col=colores[i])
}

plot(R2_TRAIN1_modeloRidge,col="red",type="l", ylim=c(0,1))
lines(R2_TEST1_modeloRidge,col="blue",type="l")


max(R2_TEST1_modeloRidge)
which(R2_TEST1_modeloRidge==max(R2_TEST1_modeloRidge))
Caso=62
R2_TRAIN1_modeloRidge[Caso]
R2_TEST1_modeloRidge[Caso]
Lambda*(Caso-1)/Pruebas
Coeficientes[Caso,]
modelo_glmnet=glmnet(x=as.matrix(Train[,variables]),y=Train$price_log,lambda=Lambda*(Caso-1)/Pruebas,alpha=0)
modelo_glmnet$beta


# Tras la regresión Ridge, el R^2 se estabiliza en torno a 0.4.

R2_TRAIN1_modeloRidge[Caso]
R2_TEST1_modeloRidge[Caso]

# Comparando los coeficientes del OLS original con los obtenidos de la regresión Ridge, los coeficientes difieren bastante. Se ha corregido por multicolinealidad.

coef(modelo)
coef(modelo_glmnet)

# Comparando los coeficientes del OLS original con los obtenidos de la regresión Ridge, los coeficientes difieren bastante. Se ha corregido por multicolinealidad.

coef(modelo)
coef(modelo_glmnet)

#Las predicciones se encuentran en las matrices
prediccionesTrain
prediccionesTest

# Medición de la accuracy vía Mean Squarred Error

y_hat = prediccionesTest
y= Test$price_log
mse<-(sum((y_hat-y)^2))/(nrow(Test))
sprintf("MSE para el model Ridge: %f", mse)
ggplot(data.frame(y_hat, y), aes(x=y_hat, y=y)) +
  geom_point(color='blue') +
  geom_abline(color='red', linetype=2) +
  xlab("Predicted") +
  ylab("Actual") +
  ggtitle("Accuracy del Modelo Ridge")


## -------------------------------------------------------------------------


## -------------------------------------------------------------------------

### -------------------------------------------------------------------------
### Añadir columna de price al fichero house_test.csv
### -------------------------------------------------------------------------

# Cargamos los datos
house_test = read.csv("house_test.csv", stringsAsFactors=FALSE, sep=",")

# Revisamos los datos cargados
str(house_test)
head(house_test)
summary(house_test)


house_test$basement <- (ifelse(house_test$sqft_basement==0,0,1))
house_test$renovated <- (ifelse(house_test$yr_renovated==0,0,1))

# Se necesita un model objeto para poder utilizar la función predict. Con los coeficientes estimados del modelo Ridge no es posible realizarlo, con esta funcíon, sin construir manualmente el vector. Podría realizarse con el modelo OLS, antes de corregir por colinealidad -aunque sabemos que algunos estimadres no son muy robustos. Y mediante una función inversa de log calcular el price.

house_test$prediccionOLS==predict(modelo,newdata=house_test,type="response") #no la vamos a ejecutar  


rcoefi<-coef(modelo_glmnet) # Alternativamente se construye un vector con los coeficientes de la regresíon Ridge
ridgecoef<-c(0,rcoefi[2], rcoefi[3], rcoefi[4], rcoefi[5],rcoefi[6], rcoefi[7],rcoefi[8], 0, rcoefi[9], 0, 0, 0,0, rcoefi[10], rcoefi[11], rcoefi[12],0,0, rcoefi[13], rcoefi[14])


# Multiplicación de matrices para la obtención de price en el data set house_test

variables_a_eliminar <- c("date")
house_test_prediction<-house_test[ , !(names(house_test) %in% variables_a_eliminar)]
intercept<-as.matrix((rep(rcoefi[1], nrow(house_test))))
betas<-(as.matrix(house_test_prediction) %*% as.matrix(ridgecoef))
price_log<-intercept+betas



house_test$price=exp(price_log)


write.csv(house_test, file = "House_test_withprices.csv")


## -------------------------------------------------------------------------


