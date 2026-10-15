\name{SfDistrictMap}
\alias{SfDistrictMap}
\title{Map a numeric variable by San Francisco supervisor district}
\description{
Draws the eleven San Francisco Board of Supervisors districts, shading each one
according to a numeric value. The colour gradient is specified the same way as
in \code{\link[graphics]{image}} and \code{\link[stats]{heatmap}}: \code{col} is
a vector of colours spanning the scale, optionally with \code{zlim} or
\code{breaks}.
}
\usage{
SfDistrictMap(data = NULL, district = NULL, value = NULL,
              col = SfPalette("blue", 64), zlim = NULL, breaks = NULL,
              center = NULL, clip = TRUE, na.col = "#e1e0d9",
              border = "#fcfcfb", lwd = 1.2, lty = 1, labels = TRUE,
              label.cex = 0.8, label.col = "auto", label.digits = NULL,
              label.parts = TRUE, legend = TRUE, legend.title = NULL,
              main = NULL, sub = NULL, xlim = NULL, ylim = NULL,
              offshore = FALSE, add = FALSE, mar = NULL, ...)
}
\arguments{
\item{data}{A data frame with one row per district, a named numeric vector, or
  \code{NULL} to draw an unfilled reference map.}
\item{district}{Name of the column in \code{data} holding district
  identifiers. Guessed if \code{NULL}.}
\item{value}{Name of the column holding the values to map. Guessed if
  \code{NULL}.}
\item{col}{Vector of colours forming the gradient, low to high. The default is
  a sequential single-hue ramp; see \code{\link{SfPalette}}. Any colour vector
  works, including \code{hcl.colors(64, "YlOrRd")} or \code{heat.colors(64)}.}
\item{zlim}{Length-2 range the gradient spans. Defaults to the range of the
  data. Fix it explicitly to put several maps on one scale.}
\item{breaks}{Bin edges, of length \code{length(col) + 1}; overrides
  \code{zlim}. Use for unequal classes such as quantile bins.}
\item{center}{Value to centre the scale on, which makes \code{zlim} symmetric
  about it. Use with a diverging gradient, e.g. \code{center = 50} together
  with \code{col = SfPalette("blue-red")}.}
\item{clip}{If \code{TRUE} (the default), values beyond \code{zlim} take the
  colour at that end of the gradient rather than being drawn as missing.}
\item{na.col}{Fill colour for districts with no value. Choose something clearly
  distinct from the gradient: the default light grey reads well against a
  sequential ramp, but against a diverging ramp, whose midpoint is itself a
  neutral grey, a darker value such as \code{"#c3c2b7"} separates better.}
\item{border, lwd, lty}{Colour, width and type of the district boundaries. The
  default border is the chart surface colour, which reads as a thin gap between
  districts.}
\item{labels}{What to print inside each district: any of \code{"district"},
  \code{"supervisor"} and \code{"value"}, stacked in the order given.
  \code{TRUE} means \code{"district"}; \code{FALSE} or \code{NULL} means no
  labels.}
\item{label.cex, label.col, label.digits}{Size, colour and number of decimal
  places for those labels. \code{label.col = "auto"} picks black or white per
  district, whichever contrasts with the fill. Long labels such as supervisor
  names may need \code{label.cex} below the default.}
\item{label.parts}{Also put a bare district number on each substantial
  disjoint part of a district. This is what identifies Treasure Island as part
  of District 6; without it the island carries no label and there is nothing on
  the map to say which district it belongs to. Applies only when \code{labels}
  includes \code{"district"} -- a lone \code{6} on the island, beside
  mainland labels reading \code{6.4}, would read as a value rather than a
  district number.}
\item{legend}{Draw the colour-scale legend?}
\item{legend.title}{Title for the legend. Defaults to the name of the value
  column.}
\item{main, sub}{Title and subtitle.}
\item{xlim, ylim}{Longitude and latitude range of the view. The default frames
  the city, which excludes two water slivers of under 0.2 square km in the Bay
  that would otherwise stretch the window for a few pixels of ink; they are
  still drawn if the view is widened.}
\item{offshore}{Include the offshore Farallon Islands portion of District 4?
  \code{FALSE} by default: it lies some 40 km west of the city and would
  otherwise dominate the map.}
\item{add}{Draw on top of an existing plot instead of starting a new one?}
\item{mar}{Figure margins. The default leaves room for the legend and title.}
\item{...}{Further arguments passed to \code{\link[graphics]{title}}.}
}
\details{
\code{data} is normally a data frame with one row per district: one column
identifying the district and one holding the value. Column names are guessed
when not given -- a column named something like \code{district} for the
identifier, and the first numeric column for the value -- but naming
\code{district} and \code{value} explicitly is clearer. District identifiers may
be numbers (\code{1}, \code{1.0}) or strings (\code{"1"}, \code{"01"},
\code{"District 1"}).

Districts absent from \code{data}, or present with an \code{NA} value, are
filled with \code{na.col} and get a "no data" swatch in the legend. Supplying
two rows for one district is an error, since which value to draw would be
ambiguous; aggregate first.

A district made of several disjoint parts is labelled on each substantial one,
so Treasure Island shows the number 6. See \code{label.parts}.

Longitude and latitude are plotted directly, with no map projection. The aspect
ratio is corrected for the latitude of San Francisco, which is what keeps the
shapes from looking stretched; over a city-sized area the difference from a
projected map is not visible.
}
\value{
Invisibly, a data frame with one row per district giving the value and fill
colour used, with the scale's \code{breaks} and \code{zlim} attached as
attributes.
}
\seealso{
\code{\link{SfPalette}} for gradients, \code{\link{SfDistrictColors}} for the
value-to-colour mapping on its own, \code{\link{SfDistrictLegend}} to place a
legend by hand, \code{\link{sf.districts}} for the boundary data and
\code{\link{sf.district.labels}} for the label points.
}
\examples{
## Percent of registered voters registered Republican (illustrative figures)
d <- data.frame(district = 1:11,
                pct.rep = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
                            12.9, 7.3, 5.8, 8.9, 10.4))

SfDistrictMap(d, main = "Registered Republicans by district")

## Show the numbers too
SfDistrictMap(d, labels = c("district", "value"), legend.title = "\% Rep")

## Diverging gradient centred on the citywide figure
SfDistrictMap(d, col = SfPalette("blue-red", 64), center = 9.1,
              na.col = "#c3c2b7", labels = c("district", "value"))

## Unequal classes
SfDistrictMap(d, breaks = quantile(d$pct.rep, seq(0, 1, length.out = 6)),
              col = SfPalette("blue", 5))

## Two maps on one shared scale, so the colours are comparable
d$pct.dem <- c(58, 49, 61, 52, 71, 68, 50, 66, 70, 63, 57)
op <- par(mfrow = c(1, 2))
SfDistrictMap(d, value = "pct.rep", zlim = c(0, 75), main = "Republican")
SfDistrictMap(d, value = "pct.dem", zlim = c(0, 75), main = "Democrat")
par(op)

## A reference map of who represents what
SfDistrictMap(labels = c("district", "supervisor"), legend = FALSE,
              label.cex = 0.62, na.col = "#f0efec",
              main = "San Francisco supervisor districts")
}
\keyword{hplot}
\keyword{spatial}
