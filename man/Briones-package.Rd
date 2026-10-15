\name{Briones-package}
\alias{Briones-package}
\alias{Briones}
\docType{package}
\title{Choropleth Maps of San Francisco Supervisor Districts}
\description{
Pass a data frame with one row per San Francisco supervisor district and a
numeric column, and get a map of the city with each district shaded by that
value. The colour gradient is given the same way as in \code{image} or
\code{heatmap}: a vector of colours, optionally with \code{zlim} or
\code{breaks}.
}
\details{
The one function most users need is \code{\link{SfDistrictMap}}.
\code{\link{SfPalette}} supplies gradients, \code{\link{SfDistrictColors}}
exposes the value-to-colour mapping on its own, and
\code{\link{SfDistrictLegend}} draws a colour bar where you want it.
\code{\link{sf.districts}}, \code{\link{sf.district.info}} and
\code{\link{sf.district.labels}} are the bundled boundary, metadata and
label-point tables; the boundaries are also available pre-merged with your
values from \code{\link{SfDistrictPolygons}} for use with other graphics
systems.

District boundaries ship with the package, so nothing is downloaded at run
time. Base graphics are used throughout and there are no package
dependencies -- no spatial libraries, no GDAL, nothing to compile.
}
\examples{
d <- data.frame(district = 1:11,
                pct.rep = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
                            12.9, 7.3, 5.8, 8.9, 10.4))
SfDistrictMap(d, main = "Registered Republicans by district")
}
\author{Steve}
\keyword{package}
