\name{SfPalette}
\alias{SfPalette}
\title{Colour gradients for district maps}
\description{
Gradients suitable for filling a choropleth map. A sequential gradient is a
single hue running light to dark, which is what a magnitude needs; a diverging
gradient is two opposed hues with a neutral grey midpoint, which is what a
value read against a baseline needs. Multi-hue "rainbow" gradients are
deliberately not offered: they invent boundaries the data does not have.
}
\usage{
SfPalette(name = c("blue", "grey", "gray", "blue-red", "red-blue"),
          n = 64, rev = FALSE)
}
\arguments{
\item{name}{Gradient name. \code{"blue"} is a sequential single-hue ramp for
  magnitudes and \code{"grey"} its neutral equivalent; \code{"blue-red"} and
  \code{"red-blue"} are diverging ramps with a neutral grey midpoint.}
\item{n}{Number of colours to return. With a diverging gradient an odd \code{n}
  places a neutral colour at the centre, and an even \code{n} places a class
  boundary there.}
\item{rev}{Reverse the returned gradient?}
}
\value{A character vector of \code{n} hex colours, ordered low to high.}
\details{
Any vector of colours works with \code{\link{SfDistrictMap}}, so the base R
palettes are available too: \code{hcl.colors(64, "YlOrRd", rev = TRUE)},
\code{heat.colors(64)}, \code{gray.colors(64)}, or anything from
\code{colorRampPalette}. Pair a diverging gradient with the \code{center}
argument of \code{SfDistrictMap} so the neutral midpoint falls on the value
that means "no difference".
}
\seealso{\code{\link{SfDistrictMap}}, \code{\link{SfDistrictColors}}}
\examples{
SfPalette("blue", 5)
SfPalette("blue-red", 9)

d <- data.frame(district = 1:11, value = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
                                           12.9, 7.3, 5.8, 8.9, 10.4))
SfDistrictMap(d, col = SfPalette("grey", 32))
}
\keyword{color}
