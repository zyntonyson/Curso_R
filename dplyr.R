################# INTRODUCCIÓN AL MANEJO DE DATOS CON R ######################


library(tidyverse)
library(magrittr)

##################################   MAGRITTR ################################################3
# Pipes  %>% , permiten ejecutar funciones en hilo, es decir una composición de
# funciones f(g(x)). La implementación original viene del paquete magrittr


#EJERCICIO 1: GENERAR UNA MATRIZ 4*4 CON ENTRADAS DEL 1 A 16 ALEATORIAMENTE. 
#Determinar cuál columna tiene la media mayor 

# Muchas asignaciones de pasos intermedios inecesarios
set.seed(1013)
a<-sample(16) 
a<-matrix(a,ncol=4,byrow=T)
a<-colMeans(a)
which.max(a)

# Código  poco fácil de leer o de modificar
set.seed(1013) 
which.max(colMeans(matrix(sample(16),ncol = 4,byrow = T)))


# Uso de pipes
set.seed(1013)
a<-sample(16) %>% 
  matrix(.,ncol=4,byrow = T) %>% 
  colMeans()  %>%
  which.max()


# EJERCICIO 2 : Dado el vector X. Calcule el logaritmo de x, posteriormente 
# calcule el logaritmo de las diferencias consecutivas, redondee el resultado

x <- c(0.109, 0.359, 0.63, 0.996, 0.515, 0.142, 0.017, 0.829, 0.907)
round(exp(diff(log(x))), 1)


#Pipes

c(0.109, 0.359, 0.63, 0.996, 0.515, 0.142, 0.017, 0.829, 0.907) %>% 
  log() %>% 
  diff() %>%
  exp() %>% 
  round(1)



# EJERCICIO 3: Generar 100 puntos (x,y) provenientes de una normal estándar y 
# y graficar una muestra aleatoria de 20 de ellos 


set.seed(1013)
rnorm(200) %>% 
  matrix(ncol = 2) %>% 
  tibble() %>% 
  sample_n(20) %>% 
  plot()


#EJERCICIO 4  Sea X un vector  de tamaño 100 proveniente de una normal estándar,
#actualice X como un vector ordenado
# uso de %<>% 

set.seed(1013)
X<-rnorm(100)
X<-X %>%
  abs() %>% 
  sort()
X
  
#compound assignment pipe-operator 
set.seed(1013)
X<-rnorm(100)
X %<>%
  abs() %>% 
  sort()
X

#EJERCICIO 5: Del dataset iris seleccione los casos que sean menores al mayores 
#a la media de Sepal.Lenght. Calcule la correlación de Sepal.Lenght y Sepal.Width
#en el subset
# Uso del  exposition pipe-operator

iris %>%
  subset(Sepal.Length > mean(Sepal.Length)) %$%
  cor(Sepal.Length, Sepal.Width)




# Operador %T%  Tee operator
# Funciona semejante %>%  pero conserva la salida original anterior y 
# no el resultado ejecutado


rnorm(200) %>%
  matrix(ncol = 2) %T>%
  plot %>% # plot usually does not return anything.
  colSums


## Más ejemplos de usos de pipes
## 

# Integración natural con ggplot
tibble(z=1:100,x=2*z+4,y=z^2+x) %>%
  sample_frac(0.2) %>%  
  ggplot()+ aes(x,z) + geom_point()

# Generar funciones

trig_fest <- . %>% tan %>% cos %>% sin

1:10 %>% trig_fest()

trig_fest(pi)

## Mas información en el documentación magrittr
## Funciones lambda




################################## DPLYR ####################################


#las cinco funciones clave de dplyr que te permiten resolver 
#la gran mayoría de tus desafíos de manipulación de datos:

#Filtrar o elegir las observaciones por sus valores 
#(filter() — del inglés filtrar).
#Reordenar las filas (arrange() — del inglés organizar).
#Seleccionar las variables por sus nombres 
#(select() — del inglés seleccionar).
#Crear nuevas variables con transformaciones de variables existentes 
#(mutate() — del inglés mutar o transformar).
#Contraer muchos valores en un solo resumen 
#(summarise() — del inglés resumir).
#Todas estas funciones se pueden usar junto con 
#group_by() (del inglés agrupar por), 
#que cambia el alcance de cada función para que actúe ya 
#no sobre todo el conjunto de datos sino de grupo en grupo. 
#

library(nycflights13)
data("flights")

#####  Vistazo al dataset#########

flights %>% 
  #head(5)
  #names()
  str()   
  #summary() 


#### filtrar casos ######

filter(flights,month==12,day==5)  # Vuelos del 5/12

filter(flights,dest=='DAY',dep_delay>20) # Destino DAY con retraso mayor a 20

filter(flights,month==11 | month==12)  # Vuelos noviembre y diciembre

filter(flights,day %in% c(15:30))  # Segunda quincena de todos los meses


#->EJERCICIOS ADICIONALES<-
#Encuentra todos los vuelos que:

  # Tuvieron un retraso de llegada de dos o más horas
  # Volaron a Houston (IAH oHOU)
  # Fueron operados por United, American o Delta
  # Partieron en invierno (julio, agosto y septiembre)
  # Llegaron más de dos horas tarde, pero no salieron tarde
  # Se retrasaron por lo menos una hora, pero repusieron más de 30 minutos en vuelo
  # Partieron entre la medianoche y las 6 a.m. (incluyente)


#### Ordenar casos#####

arrange(flights,year,month,day)

#usando pipe
flights %>% 
  #arrange(year,month,day)  # Ordenar yy/mm/dd
  arrange(desc(dep_delay))  # Decreciente al atraso de salida
  
  
  
#->EJERCICIOS ADICIONALES<-
  # Ordena vuelos para encontrar los vuelos más retrasados. 
  # Encuentra los vuelos que salieron más temprano.
  # Ordena vuelos para encontrar los vuelos más rápidos.
  # ¿Cuáles vuelos viajaron más tiempo? 
  # ¿Cuál viajó menos tiempo?


####  Seleccionar columnas ########
####  Ojo: select es una función que suele tener enmascaramientos con otros
####  paquetes (e.g MASS)  puede usarse directo de la libreria con
####  dplyr::select()

select(flights,month,arr_time)

#pipe 

flights %>% 
  select(month,arr_time)
  #select(dep_time:origin)
  #select(-(year:day))
  #select(ends_with('delay'))


##  AÑADIR NUEVAS VARIABLES  

flights %>% 
    select(flight, ends_with('delay'), distance, air_time) %>%
    mutate( profit=dep_delay-arr_delay,
            horas_vuelo=air_time/60 %>% round(0),
            velocidad_media=distance/air_time*60)
  

flights %>% 
  select(flight, ends_with('delay'), distance, air_time) %>%
  transmute( profit=dep_delay-arr_delay,
          horas_vuelo=air_time/60 %>% round(0),
          velocidad_media=distance/air_time*60)


## EFECTUAR RESUMENES
## 

flights %>% 
  #summarise(atraso=mean(dep_delay,na.rm=T))
  summarise(atraso=max(dep_delay,na.rm=T))
    

# Resumen de retraso de partida por fechas
flights %>% 
  group_by(year,month,day) %>% 
  summarise(delay=mean(dep_delay,na.rm=T))


# Resumen de retraso de partida por destino

flights %>% 
  group_by(dest) %>% 
  summarise(
    cases=n(),
    distance= mean(distance, na.rm = T),
    delay=mean(dep_delay,na.rm=T),
    )


#¿Habra alguna relación entre la distancia y el retraso al destino?



flights %>% 
  group_by(dest) %>% 
  summarise(
    cases=n(),
    distance= mean(distance, na.rm = T),
    delay=mean(dep_delay,na.rm=T),
  ) %>% 
  filter(cases>20, dest!='HNL') %>% 
  ggplot() + aes(distance,delay) +
  geom_point(aes(size=cases),alpha=0.5)+
  geom_smooth(se=F)

################## TALLER ####################
# Considera las  calificaciones de los alumnos del cuarto grado
# responde las preguntas
# 

datos<-read_csv('https://raw.githubusercontent.com/zyntonyson/Curso_R/master/cuarto_grado.csv')


# Una mirada al dataset
datos %>% 
        #str()
        head()
        


# Tidy data, cada renglón en un observación
# 

  datos %<>%
    separate(nombre, into = c("apellido", "primer")) %>% 
    separate(fecha, into = c("dia", "mes", "año"), convert = TRUE) %>% 
    gather("materia", "puntos", "matematica", "ingles")

  
  datos %>% head()

  

  
  ## Conocimiento
  
  #1.¿Cual es el promedio actual por cada clase?
  
  
  datos %>%
    group_by(materia) %>%
    summarise(promedio = mean(puntos))
  
  
  #2.¿Cuales son los promedios de cada estudiante en matematica?
  
  
  datos %>%
    filter(materia == "matematica") %>%
    group_by(matricula, primer, apellido) %>%
    summarise(promedio = mean(puntos))
  
  
  #3.¿Cuales son los promedios de cada estudiante en ingles?
  
  
  datos %>%
    filter(materia == "ingles") %>%
    group_by(matricula, primer, apellido) %>%
    summarise(promedio = mean(puntos))
  
  
  #4.¿Quienes tienen los mejores promedios en ingles?
  
  
  datos %>%
    filter(materia == "ingles") %>%
    group_by(matricula, primer, apellido) %>%
    summarise(promedio = mean(puntos)) %>% 
    arrange(desc(promedio)) %>%
    ungroup() %>% 
    mutate(puesto = row_number())
  
  
  #5.¿Cual es la historia del ultimo lugar?
  
  
  datos %>%
    filter(matricula == 105, materia == "ingles") 
  
  
  
  datos %>%
    filter(matricula == 105, materia == "ingles") %>%
    ggplot() +
    geom_line(aes(mes, puntos))
  
  
  #6.¿Cual es la historia de todos los alumnos?
  
  
  datos %>%
    filter(materia == "ingles") %>%
    ggplot() +
    geom_line(aes(mes, puntos, group = matricula))
  #geom_line(aes(mes, puntos, group = matricula, color = apellido))
  
  
  #Formalizar la grafica
  
  
  datos %>%
    group_by(materia, mes) %>%
    summarise(promedio = mean(puntos)) %>%
    ggplot() +
    geom_line(aes(mes, promedio, color = materia)) +
    labs(title = "Promedios mensuales por cada materia")
  
  
  
      