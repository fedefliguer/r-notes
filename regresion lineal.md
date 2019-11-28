## Teorema Frisch–Waugh–Lovell
``` r
coef(lm(y1 ~ x1 + x2))[2] = coef[ lm(residuals(lm(y1 ~ x2)) ~ -1 + residuals(lm(x1 ~ x2))) ]
```
El beta1 de una regresión múltiple es igual al beta de regresar: los residuos de la regresión de la variable explicada sobre beta2, sobre los residuos de la X1 sobre beta2. Siendo beta2 la/s variable/s que, juntas o separadas, consolidan todo el resto de información que X1 no contiene. Esto es una manera de reducir cualquier regresión a una doble
