\name{SfDistrictPolygons}
\alias{SfDistrictPolygons}
\title{District boundaries, optionally merged with your own values}
\description{
Returns the district boundaries as vertices in "long" format -- one row per
vertex, with a \code{part} column identifying each ring -- optionally with your
own values merged on by district. Useful for drawing the map with another
graphics system.
}
\usage{
SfDistrictPolygons(data = NULL, district = NULL, value = NULL,
                   offshore = FALSE)
}
\arguments{
\item{data}{Optional data frame or named numeric vector of values, handled
  exactly as in \code{\link{SfDistrictMap}}.}
\item{district}{Name of the district identifier column in \code{data}.}
\item{value}{Name of the value column in \code{data}.}
\item{offshore}{Include the offshore Farallon Islands part of District 4?}
}
\value{
A data frame of vertices with columns \code{long}, \code{lat}, \code{part},
\code{district}, \code{hole}, \code{offshore}, \code{major} and
\code{supervisor}. When \code{data} is supplied, a \code{value} column is
merged on by district.
}
\seealso{\code{\link{sf.districts}}, \code{\link{SfDistrictMap}}}
\examples{
str(SfDistrictPolygons())

## With ggplot2, if it is installed:
\dontrun{
library(ggplot2)
d <- data.frame(district = 1:11, value = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
                                           12.9, 7.3, 5.8, 8.9, 10.4))
ggplot(SfDistrictPolygons(d), aes(long, lat, group = part, fill = value)) +
  geom_polygon(colour = "white") +
  coord_map() +
  scale_fill_gradientn(colours = SfPalette("blue", 64))
}
}
\keyword{datasets}
\keyword{spatial}
