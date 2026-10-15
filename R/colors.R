## Mapping numeric values onto a colour gradient, following the conventions of
## image() and heatmap(): 'col' is a vector of colours and the value range is
## cut into length(col) equal bins, or into user-supplied 'breaks'.

#' Map values onto a colour gradient
#'
#' Translates numeric values into fill colours using the same conventions as
#' \code{\link[graphics]{image}}: \code{col} is a vector of colours, and the
#' value range is divided into \code{length(col)} equal-width bins. Supply
#' \code{breaks} instead to control the bin edges directly.
#'
#' @param values Numeric vector. \code{NA} values receive \code{na.col}.
#' @param col Vector of colours forming the gradient, ordered from the low end
#'   of the scale to the high end.
#' @param zlim Length-2 numeric range the gradient should span. Defaults to the
#'   range of \code{values}.
#' @param breaks Numeric vector of bin edges, of length \code{length(col) + 1}.
#'   Overrides \code{zlim}. Need not be equally spaced.
#' @param center Numeric value to centre the scale on, which makes \code{zlim}
#'   symmetric about it. Use with a diverging gradient so that the neutral
#'   midpoint colour falls exactly on \code{center}. Ignored if \code{zlim} or
#'   \code{breaks} is given.
#' @param clip If \code{TRUE} (the default) values outside \code{zlim} take the
#'   colour of the nearest end of the gradient. If \code{FALSE} they are treated
#'   as missing and get \code{na.col}, which is what \code{image} does.
#' @param na.col Colour for missing (or, when \code{clip = FALSE}, out-of-range)
#'   values.
#' @return A list with components \code{col} (a colour per input value),
#'   \code{breaks}, \code{zlim}, \code{palette} and \code{na.col}.
#' @examples
#' SfDistrictColors(c(10, 20, 30), col = SfPalette("blue", 8))
#' @export
SfDistrictColors <- function(values,
                             col = SfPalette("blue", 64),
                             zlim = NULL,
                             breaks = NULL,
                             center = NULL,
                             clip = TRUE,
                             na.col = "#e1e0d9") {
  values <- as.numeric(values)
  if (!length(col)) stop("'col' must contain at least one colour", call. = FALSE)

  ## Non-finite values (NaN, Inf) are as unmappable as NA; treat them alike.
  values[!is.finite(values)] <- NA_real_

  if (!is.null(breaks)) {
    breaks <- sort(as.numeric(breaks))
    if (length(breaks) != length(col) + 1L)
      stop("'breaks' must have one more element than 'col' (",
           length(col) + 1L, " expected, ", length(breaks), " supplied)",
           call. = FALSE)
    zlim <- range(breaks)
  } else {
    zlim <- .SfZlim(values, zlim, center)
    breaks <- seq(zlim[1L], zlim[2L], length.out = length(col) + 1L)
  }

  z <- values
  if (isTRUE(clip)) z <- pmin(pmax(z, zlim[1L]), zlim[2L])

  ## right = TRUE, include.lowest = TRUE matches image()'s binning: bins are
  ## (b1, b2], ... with the very lowest edge included.
  idx <- .bincode(z, breaks, right = TRUE, include.lowest = TRUE)
  out <- rep(NA_character_, length(z))
  ok <- !is.na(idx)
  out[ok] <- col[idx[ok]]
  out[is.na(out)] <- na.col

  list(col = out, breaks = breaks, zlim = zlim, palette = col, na.col = na.col)
}

## Work out the range the gradient spans.
.SfZlim <- function(values, zlim, center) {
  if (!is.null(zlim)) {
    zlim <- range(as.numeric(zlim), na.rm = TRUE)
    if (!all(is.finite(zlim)) || zlim[1L] > zlim[2L])
      stop("'zlim' must be two finite values, low then high", call. = FALSE)
    if (zlim[1L] == zlim[2L]) zlim <- zlim + c(-0.5, 0.5)
    return(zlim)
  }

  if (!any(!is.na(values))) {
    ## Nothing to scale (outline-only map). Any finite range will do.
    return(c(0, 1))
  }

  zlim <- range(values, na.rm = TRUE)
  if (!is.null(center)) {
    center <- as.numeric(center)[1L]
    if (!is.finite(center)) stop("'center' must be a finite value", call. = FALSE)
    half <- max(abs(zlim - center))
    if (half == 0) half <- 0.5
    zlim <- center + c(-half, half)
  }
  ## A single distinct value would give a zero-width scale; widen it so the
  ## value lands in the middle of the gradient rather than on an edge.
  if (zlim[1L] == zlim[2L]) {
    pad <- if (zlim[1L] == 0) 0.5 else abs(zlim[1L]) / 2
    zlim <- zlim + c(-pad, pad)
  }
  zlim
}
