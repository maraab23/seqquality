# Generalized sequence quality index

The package only comprises a single function which computes a generalized version of the sequence quality index proposed by Manzoni and Mooi-Reci (2018). The index is defined as

<img src="https://render.githubusercontent.com/render/math?math=Q_{i}=\frac{\sum_{i=1}^{k}{q_{i}i^{w}_{i}}}{\sum_{i=1}^{k}{q_{max}i^{w%20}_{i}}}">


The package can be installed using `install_github` from the `devtools` package:

```R
install.packages("devtools")
library(devtools)
install_github("maraab23/seqquality")
library(seqquality)
```
 
