## Colour gradients and the small set of "chrome" inks used by the map.
##
## Design rules followed here:
##   * a sequential (magnitude) ramp is ONE hue, light -> dark. Never a rainbow.
##   * a diverging (polarity) ramp is two opposed hues -- one warm, one cool --
##     with a neutral grey midpoint, and the same number of steps per arm.
##   * label and axis text uses ink colours, never a colour from the ramp.

## Chrome inks. Kept in one place so a theme change is a single edit.
.sf.ink <- list(
  surface   = "#fcfcfb",   # chart surface; also the gap between districts
  primary   = "#0b0b0b",   # label text on light fills
  secondary = "#52514e",   # legend title
  muted     = "#898781",   # legend tick labels
  hairline  = "#e1e0d9",   # "no data" fill
  baseline  = "#c3c2b7"    # legend box outline
)

## Sequential blue, steps 100 (lightest) -> 700 (darkest).
.sf.blue <- c("#cde2fb", "#b7d3f6", "#9ec5f4", "#86b6ef", "#6da7ec", "#5598e7",
              "#3987e5", "#2a78d6", "#256abf", "#1c5cab", "#184f95", "#104281",
              "#0d366b")

.sf.mid  <- "#f0efec"      # neutral diverging midpoint -- must read as "nothing"
.sf.pole <- c(blue = "#2a78d6", red = "#e34948")

#' Colour gradients for district maps
#'
#' @param name Gradient name. \code{"blue"} is a sequential (single hue,
#'   light to dark) ramp for magnitudes; \code{"grey"} is its neutral
#'   equivalent; \code{"blue-red"} and \code{"red-blue"} are diverging ramps
#'   with a neutral grey midpoint, for values read against a baseline.
#' @param n Number of colours to return.
#' @param rev Reverse the returned gradient?
#' @return A character vector of \code{n} hex colours.
#' @export
SfPalette <- function(name = c("blue", "grey", "gray", "blue-red", "red-blue"),
                      n = 64, rev = FALSE) {
  name <- match.arg(name)
  if (!is.numeric(n) || length(n) != 1L || is.na(n) || n < 1)
    stop("'n' must be a single positive number of colours", call. = FALSE)
  n <- as.integer(n)

  out <- switch(name,
    "blue" = colorRampPalette(.sf.blue, space = "Lab")(n),
    "grey" = ,
    "gray" = colorRampPalette(c("#f0efec", "#0b0b0b"), space = "Lab")(n),
    "blue-red" = .SfDiverging(.sf.pole[["blue"]], .sf.pole[["red"]], n),
    "red-blue" = .SfDiverging(.sf.pole[["red"]], .sf.pole[["blue"]], n)
  )
  if (isTRUE(rev)) out <- rev(out)
  out
}

## Two equal-length arms meeting at the neutral midpoint. An odd 'n' puts a
## single midpoint colour at the centre; an even 'n' splits evenly, so the
## class boundary -- not a colour -- falls on the centre of the scale.
.SfDiverging <- function(low, high, n) {
  half <- n %/% 2L
  lo <- colorRampPalette(c(low, .sf.mid), space = "Lab")(half + 1L)
  hi <- colorRampPalette(c(.sf.mid, high), space = "Lab")(half + 1L)
  if (n %% 2L == 1L)
    c(lo[seq_len(half)], .sf.mid, hi[-seq_len(1L)])
  else
    c(lo[seq_len(half)], hi[-seq_len(1L)])
}

## Relative luminance (WCAG), used to choose a readable label ink over a fill.
.SfLuminance <- function(colour) {
  rgb <- col2rgb(colour, alpha = FALSE) / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  as.numeric(0.2126 * lin[1, ] + 0.7152 * lin[2, ] + 0.0722 * lin[3, ])
}

## Black or white ink, whichever reads better on 'fill'.
.SfContrastInk <- function(fill) {
  ink <- rep(.sf.ink$primary, length(fill))
  ok <- !is.na(fill)
  if (any(ok)) ink[ok] <- ifelse(.SfLuminance(fill[ok]) < 0.42,
                                 "#ffffff", .sf.ink$primary)
  ink
}
