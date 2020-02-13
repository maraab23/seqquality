#' Sequence Quality Index
#'
#' Calculates a generalized version of the sequence quality index for a state
#' sequence object. The original version of the index proposed by \cite{Manzoni &
#' Mooi-Reci 2018} was defined for the binary case: states were either marked as failures or successes.
#' Drawing on the work of \cite{Ritschard et al. 2018}, the generalized version allows to specify a quality hierarchy assigning
#' a (unique) quality score to each state.
#'
#' @param seqdata State sequence object (class \code{stslist}) created with the \code{\link[TraMineR]{seqdef}} function.
#' @param stqual Numeric vector defining a quality hierarchy of states. Length has to match length of the sequence alphabet.
#'   If not specified default equals order of elements in the aplphabet with higher-order states indicating higher quality.
#' @param weight Number or numeric vector specifying weighting factor (see details). Default is 1.
#' @param time.varying Default is \code{FALSE}.
#'
#' @details
#' The generalized sequence index is a generalization of the index proposed by \cite{Manzoni & Mooi-Reci 2018}. It is defined as
#' \deqn{Q(x) = \frac{\sum_{i=1}^{k}{q_{i}i^{w}_{i}}}{\sum_{i=1}^{k}{q_{max}i^{w }_{i}}}}
#' where \eqn{i} indicates the position within the sequence and \eqn{k} the total length of the sequence.
#' \eqn{w} is a weighting factor simultaneously affecting how strong the index reacts to (and recovers from) a change in state quality.
#' \eqn{q_{i}} is weighting factor denoting the quality of a state at position \eqn{i}. The function normalizes the quality factor
#' (\code{stqual}) to have a values between 0 and 1. Therefore, \eqn{q_{max}=1}. If no quality vector is specified (\code{stqual= NULL}),
#' the first state of the alphabet is coded 0, whereas the state at the top is coded 1. For the states in-between each step up the hierarchy
#' increases the value of the vector by \eqn{\frac{1}{(l(A)−1)}}, with \eqn{l(A)} indicating the length of the alphabet. This procedure was
#' borrowed from \code{\link[TraMineR]{seqprecstart }}.
#'
#' It is possible to assign the same quality score to multiple states to the alphabet. As a matter of fact, a \code{stqual} vector only
#' comprising the values 0 and 1 is identical to the original (binary) version of the quality index proposed by \cite{Manzoni & Mooi-Reci 2018}.
#'
#' @return Data frame (actually tibble) or list of data frames if \code{time.varying = TRUE} and multiple weights are specified.
#'
#' @examples
#' # Load TraMineR and use its 'actcal' example data set (first 200 rows)
#' # and define sequence object 'actcal.seq'
#' library(TraMineR)
#' data(actcal)
#' actcal <- actcal[1:200,] ## subset: first 200 rows
#' actcal.seq <- seqdef(actcal[,13:24])
#'
#' # Quality index using original state order
#' # (does not make much sense here)
#' seqquality(actcal.seq)
#'
#' # Quality index using an alternative quality hierarchy
#' seqquality(actcal.seq, stqual = 4:1)
#'
#' # Quality index at every position of the sequence (time.varying = T)
#' # and with three different weights
#' seqquality(actcal.seq, stqual = c(4:1), weight = c(.5,1,2), time.varying = T)
#'
#' @references
#' Manzoni, A. and Mooi-Reci, I. (2018), "Measuring Sequence Quality", in G. Ritschard, and M. Studer,
#' \emph{Sequence Analysis and Related Approaches: Innovative Methods and Applications},
#' Series Life Course Research and Social Policies, Vol. 10, pp 261-278. Cham: Springer.
#'
#' Ritschard, G., Bussi, M., and O'Reilly, J. (2018), "An index of precarity for measuring
#' early employment insecurity", in G. Ritschard, and M. Studer,
#' \emph{Sequence Analysis and Related Approaches: Innovative Methods and Applications},
#' Series Life Course Research and Social Policies, Vol. 10, pp 279-295. Cham: Springer.
#'
#' @author Marcel Raab
#'
#' @seealso
#' \href{https://sa-book.github.io/companion/rChapter2-5.html#bonus-material-generalized-version-of-the-sequence-quality-index}{Companion web page for our book on sequence analysis}
#'
#' @import dplyr purrr
#'
#' @export

seqquality <-
  function(seqdata, stqual = NULL, weight = 1, time.varying = FALSE) {
    if (!inherits(seqdata, "stslist"))
      stop("data is not a sequence object, use 'seqdef' function to create one")

    alphlength <- length(attributes(seqdata)$alphabet)

    if (class(weight) != "numeric") {
      stop("weight must be a single number or a numeric vector")
    }

    if (is.null(stqual)) {
      stqual <- seq(from = 0, to = 1, by = 1/(alphlength - 1))
    }

    if (!(class(stqual) %in% c("numeric", "integer"))) {
      stop("stqual must be a numeric vector")
    }

    else if (length(stqual) != alphlength) {
      stop("'stqual' must have the same length as the sequence alphabet")
    }

    # normalize quality hierarchy
    qual <- (stqual-min(stqual))/(max(stqual)-min(stqual))
    #qual.max <- max(qual)

    scores <- as_tibble(seqdata) %>%
      mutate_all(as.numeric) %>%
      mutate_all(~qual[.x])

    denominator <- scores %>%
      mutate_all(~if_else(!is.na(.x),1,.x))

    if (time.varying == FALSE) {
      output <- map_dfc(weight, function(wgt){
        denominator <- map_dfc(1:ncol(denominator),
                               ~(denominator[,.x]*.x)^wgt) %>%
          as_tibble() %>%
          transmute(denominator = rowSums(.))

        numerator <- map_dfc(1:ncol(scores),
                             ~(scores[,.x]*.x)^wgt) %>%
          as_tibble() %>%
          transmute(numerator = rowSums(.))

        aux <- round((numerator/denominator),3)

        colnames(aux) <- paste0("w=",wgt)

        as_tibble(aux)
      })
    }

    # Time-varying version - returns list of tibbles
    # if multiple weights are specified
    if (time.varying == TRUE) {

      output <- map(weight, function(wgt){
        denominator <- map_dfc(1:ncol(denominator),~(denominator[,.x]*.x)^wgt) %>%
          t()

        denominator <- suppressMessages(as_tibble(denominator,
                                                  .name_repair = "universal")) %>%
          cumsum() %>%
          t()

        numerator <- map_dfc(1:ncol(scores),~(scores[,.x]*.x)^wgt) %>%
          t()

        numerator <- suppressMessages(as_tibble(numerator,
                                                  .name_repair = "universal")) %>%
          cumsum() %>%
          t()
        aux <- round((numerator/denominator),3)
        suppressMessages(as_tibble(aux, .name_repair = "universal")) %>%
          rename_all(~paste0("t=",1:ncol(aux))) %>%
          mutate(weight = wgt) %>%
          select(weight, starts_with("t"))
      })
      names(output) <- paste0("w=",weight)
      if (length(output) == 1) output <- output[[1]]
    }
    return(output)
  }
