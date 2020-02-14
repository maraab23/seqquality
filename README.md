# Generalized sequence quality index

The package only comprises a single function which computes a generalized version of the sequence quality index proposed by *Manzoni and Mooi-Reci (2018)*. The index is defined as

<img src="http://bit.ly/2SrBrhU" align="center" border="0" alt="Q_{i}=\frac{\sum_{i=1}^{k}{q_{i}i^{w}_{i}}}{\sum_{i=1}^{k}{q_{max}i^{w }_{i}}}" width="198" height="73" />

where <img src="https://render.githubusercontent.com/render/math?math=i"> indicates the position within the sequence and <img src="https://render.githubusercontent.com/render/math?math=k"> the total length of the sequence. <img src="https://render.githubusercontent.com/render/math?math=w"> is a weighting factor simultaneously affecting how strong the index reacts to (and recovers from) a change in state quality. <img src="https://render.githubusercontent.com/render/math?math=q_{i}"> is a weighting factor denoting the quality of a state at position <img src="https://render.githubusercontent.com/render/math?math=i">. The function normalizes <img src="https://render.githubusercontent.com/render/math?math=q_{i}"> to have values between 0 and 1. Therefore, <img src="https://render.githubusercontent.com/render/math?math=q_{max}=1">. If no quality vector is specified, the first state of the alphabet is coded 0, whereas the last state is coded 1. For the states in-between each step up the hierarchy increases the value of the vector by <img src="https://render.githubusercontent.com/render/math?math={1}/{(l(A)-1)}">, with <img src="https://render.githubusercontent.com/render/math?math=l(A)"> indicating the length of the alphabet. This procedure was borrowed from the `seqprecstart`, a helper function used for the implementation of the sequence precarity index proposed by *Ritschard et al. (2018)*. 


The package can be installed using `install_github` from the `devtools` package:

```R
install.packages("devtools")
library(devtools)
install_github("maraab23/seqquality")
library(seqquality)
```

## Reference

Manzoni, A., & Mooi-Reci, I. (2018). *Measuring Sequence Quality*. In G. Ritschard & M. Studer (Eds.), Sequence Analysis and Related Approaches (pp. 261–278). doi: 10.1007/978-3-319-95420-2_15

Ritschard, G., Bussi, M., & O’Reilly, J. (2018). *An Index of Precarity for Measuring Early Employment Insecurity*. In G. Ritschard & M. Studer (Eds.), Sequence Analysis and Related Approaches (pp. 279–295). doi: 10.1007/978-3-319-95420-2_16
