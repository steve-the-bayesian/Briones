\name{SfDistrictLegend}
\alias{SfDistrictLegend}
\title{Draw a colour-gradient legend}
\description{
Draws a vertical colour bar with tick labels, by default just outside the
right-hand edge of the current plot region. Called automatically by
\code{\link{SfDistrictMap}}; exported so a legend can be placed by hand, for
example one shared legend for a row of maps drawn with \code{legend = FALSE}.
}
\usage{
SfDistrictLegend(breaks, col, title = NULL, at = NULL, labels = NULL,
                 x = NULL, y = NULL, cex = 0.75, na.col = NULL,
                 na.label = "no data")
}
\arguments{
\item{breaks}{Numeric bin edges, as returned by
  \code{\link{SfDistrictColors}}.}
\item{col}{Vector of colours, one per bin, low to high.}
\item{title}{Optional label drawn above the bar.}
\item{at}{Numeric values to tick. Defaults to \code{pretty(range(breaks))}.}
\item{labels}{Tick labels; defaults to \code{format(at)}.}
\item{x, y}{Horizontal and vertical extent of the bar in normalised figure
  coordinates. \code{NULL} places the bar just right of the plot region,
  spanning the middle of its height.}
\item{cex}{Character expansion for the tick labels.}
\item{na.col}{If not \code{NULL}, an extra swatch drawn below the bar for
  missing values.}
\item{na.label}{Label for the missing-value swatch.}
}
\value{Invisibly, a list giving the bar's extent in user coordinates and the
  tick positions used.}
\details{
The bar always shows bins of equal height, so unequally spaced \code{breaks}
produce unevenly spaced ticks. That is deliberate: it shows that the classes
cover unequal ranges of the data.
}
\seealso{\code{\link{SfDistrictMap}}, \code{\link{SfDistrictColors}}}
\examples{
d <- data.frame(district = 1:11, value = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
                                           12.9, 7.3, 5.8, 8.9, 10.4))
s <- SfDistrictColors(d$value)
SfDistrictMap(d, legend = FALSE, mar = c(0.6, 0.6, 0.6, 5.4))
SfDistrictLegend(s$breaks, s$palette, title = "\% Rep")
}
\keyword{aplot}
