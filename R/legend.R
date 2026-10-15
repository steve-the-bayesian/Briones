## The colour-scale legend. A continuous gradient is unreadable without one,
## so SfDistrictMap() draws it by default.

#' Draw a colour-gradient legend
#'
#' Draws a vertical colour bar with tick labels, by default just outside the
#' right-hand edge of the current plot region. Called automatically by
#' \code{\link{SfDistrictMap}}; exported so that a legend can be placed
#' manually, for example when several maps share one scale.
#'
#' @param breaks Numeric bin edges, as returned by
#'   \code{\link{SfDistrictColors}}.
#' @param col Vector of colours, one per bin, low to high.
#' @param title Optional label drawn above the bar.
#' @param at Numeric values to tick. Defaults to \code{pretty(range(breaks))}.
#' @param labels Tick labels; defaults to \code{format(at)}.
#' @param x,y Horizontal and vertical extent of the bar in normalised figure
#'   coordinates. \code{NULL} places the bar just right of the plot region,
#'   spanning the middle of its height.
#' @param cex Character expansion for the tick labels.
#' @param na.col If not \code{NULL}, an extra swatch drawn below the bar for
#'   missing values.
#' @param na.label Label for the missing-value swatch.
#' @return Invisibly, a list giving the bar's user-coordinate extent.
#' @export
SfDistrictLegend <- function(breaks, col, title = NULL,
                             at = NULL, labels = NULL,
                             x = NULL, y = NULL, cex = 0.75,
                             na.col = NULL, na.label = "no data") {
  n <- length(col)
  if (length(breaks) != n + 1L)
    stop("'breaks' must have one more element than 'col'", call. = FALSE)

  plt <- par("plt")
  if (is.null(x)) {
    ## Sit in the right margin, a little clear of the plot region.
    x <- c(min(plt[2L] + 0.020, 0.97), min(plt[2L] + 0.055, 0.995))
  }
  if (is.null(y)) {
    mid <- mean(plt[3:4])
    span <- 0.46 * (plt[4L] - plt[3L])
    y <- c(mid - span, mid + span)
  }

  ## Work in user coordinates so rect()/text() behave normally; xpd = NA lets
  ## the bar live outside the plot region.
  xu <- grconvertX(x, from = "nfc", to = "user")
  yu <- grconvertY(y, from = "nfc", to = "user")

  op <- par(xpd = NA)
  on.exit(par(op), add = TRUE)

  edges <- seq(yu[1L], yu[2L], length.out = n + 1L)
  rect(xu[1L], edges[-(n + 1L)], xu[2L], edges[-1L], col = col, border = NA)
  rect(xu[1L], yu[1L], xu[2L], yu[2L], border = .sf.ink$baseline, lwd = 0.8)

  if (is.null(at)) {
    at <- pretty(range(breaks), n = 5)
    at <- at[at >= min(breaks) & at <= max(breaks)]
    if (length(at) < 2L) at <- range(breaks)
  }
  if (is.null(labels)) labels <- format(at, trim = TRUE)

  ## approx() rather than a linear rescale, so unequal 'breaks' tick correctly:
  ## the bar always shows equal-height bins.
  pos <- stats::approx(breaks, edges, xout = at, rule = 2)$y
  tick <- (xu[2L] - xu[1L]) * 0.35
  segments(xu[2L], pos, xu[2L] + tick, pos, col = .sf.ink$baseline, lwd = 0.8)
  text(xu[2L] + tick * 1.6, pos, labels, adj = c(0, 0.5), cex = cex,
       col = .sf.ink$muted)

  if (!is.null(na.col)) {
    h <- (yu[2L] - yu[1L]) / max(n, 12)
    gap <- 2.2 * h
    rect(xu[1L], yu[1L] - gap - 3 * h, xu[2L], yu[1L] - gap,
         col = na.col, border = .sf.ink$baseline, lwd = 0.8)
    text(xu[2L] + tick * 1.6, yu[1L] - gap - 1.5 * h, na.label,
         adj = c(0, 0.5), cex = cex, col = .sf.ink$muted)
  }

  if (!is.null(title) && nzchar(title)) {
    text(xu[1L], yu[2L] + (yu[2L] - yu[1L]) * 0.03, title,
         adj = c(0, 0), cex = cex * 1.05, col = .sf.ink$secondary,
         font = 1)
  }

  invisible(list(x = xu, y = yu, at = at))
}
