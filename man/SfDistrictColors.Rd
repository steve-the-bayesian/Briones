\name{SfDistrictColors}
\alias{SfDistrictColors}
\title{Map values onto a colour gradient}
\description{
Translates numeric values into fill colours using the same conventions as
\code{\link[graphics]{image}}: \code{col} is a vector of colours, and the value
range is divided into \code{length(col)} equal-width bins. Supply \code{breaks}
instead to control the bin edges directly. \code{\link{SfDistrictMap}} calls
this internally; it is exported so the same mapping can be reused, for instance
to colour points or a table to match a map.
}
\usage{
SfDistrictColors(values, col = SfPalette("blue", 64), zlim = NULL,
                 breaks = NULL, center = NULL, clip = TRUE,
                 na.col = "#e1e0d9")
}
\arguments{
\item{values}{Numeric vector. \code{NA}, \code{NaN} and infinite values all
  receive \code{na.col}.}
\item{col}{Vector of colours forming the gradient, low end first.}
\item{zlim}{Length-2 numeric range the gradient should span. Defaults to the
  range of \code{values}.}
\item{breaks}{Numeric bin edges, of length \code{length(col) + 1}. Overrides
  \code{zlim}, and need not be equally spaced.}
\item{center}{Numeric value to centre the scale on, which makes \code{zlim}
  symmetric about it. Ignored if \code{zlim} or \code{breaks} is given.}
\item{clip}{If \code{TRUE} (the default) values outside \code{zlim} take the
  colour of the nearest end of the gradient. If \code{FALSE} they are treated
  as missing and get \code{na.col}, which is what \code{image} does.}
\item{na.col}{Colour for missing (or, when \code{clip = FALSE}, out-of-range)
  values.}
}
\value{
A list with components \code{col} (one colour per input value), \code{breaks},
\code{zlim}, \code{palette} (the gradient used) and \code{na.col}.
}
\details{
Bins follow \code{image}: they are half-open on the left, \code{(b1, b2]}, with
the lowest edge included. A scale with no width -- every value identical, or a
zero-width \code{zlim} -- is widened slightly so the value lands mid-gradient
rather than on an edge.
}
\seealso{\code{\link{SfDistrictMap}}, \code{\link{SfPalette}}}
\examples{
SfDistrictColors(c(10, 20, 30, NA), col = SfPalette("blue", 8))

## A fixed scale, so two sets of values are directly comparable
a <- SfDistrictColors(c(1, 5, 9), zlim = c(0, 10))
b <- SfDistrictColors(c(2, 6, 8), zlim = c(0, 10))
identical(a$breaks, b$breaks)
}
\keyword{color}
