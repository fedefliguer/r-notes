## Outliers mediante boxlpot
``` r
boxplot(data)

# Forma estándar de encontrar
cuantiles<-quantile(data, c(0.25, 0.5, 0.75), type = 7)
outliers_min<-as.numeric(cuantiles[1])-1.5*data  # Valor por debajo de lo cual serán outliers 
outliers_max<-as.numeric(cuantiles[3])+1.5*data  # Valor por encima de lo cual serán outliers

# Forma sencilla
bp = boxplot(data)
out_inf = bp$stats[1]
out_sup = bp$stats[5]
```

# Outliers mediante Desvíos de la Media
``` r
desvio<-sd(data)
outliers_max<-mean(data)+N*desvio
outliers_min<-mean(data)-N*desvio
```

# Outliers mediante Z-Score
``` r
data$zscore<-(data$Road_55dB-mean(data$Road_55dB))/sd(data$Road_55dB)
umbral<-2
max(data$zscore)
min(data$zscore)
```

# Outliers multivariados mediante LOF
``` r
library(Rlof)
data$score<-lof(data, k=3)
umbral<-4
data$outlier <- (data$score>umbral)
```

## LOF usando distancias de Mahalanobis
``` r
data$mahalanobis <- mahalanobis(data[,1:3], colMeans(data[,1:3]), cov(data[,1:3]))
data <- data[order(data$mahalanobis,decreasing = TRUE),] # Ordenamos de forma decreciente, según el score de Mahalanobis
data$outlier <- (data$mahalanobis>umbral)
```
