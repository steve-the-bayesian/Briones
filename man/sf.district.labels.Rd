\name{sf.district.labels}
\alias{sf.district.labels}
\docType{data}
\title{Where to put a district's label on the map}
\description{
One row per map part worth labelling, giving the point inside it at which a
label reads best. Most districts are a single part and so appear once, but a
district drawn as several disjoint parts appears once per part -- which is how
Treasure Island gets a District 6 label of its own rather than being left
unmarked.
}
\usage{sf.district.labels}
\format{
A data frame of 12 rows and 6 columns:
\describe{
  \item{district}{Integer district number, 1 to 11.}
  \item{part}{Ring identifier, matching \code{part} in
    \code{\link{sf.districts}}.}
  \item{long, lat}{The label point: the interior point of the part that lies
    farthest from its boundary, an approximate pole of inaccessibility. This is
    used rather than the centroid because the centroid of a concave or
    elongated part can fall outside the part itself.}
  \item{primary}{\code{TRUE} for each district's largest part. That part
    carries the full label; the others carry only the district number, since
    they are small and their job is simply to identify which district they
    belong to.}
  \item{area.km2}{Area of the part in square kilometres.}
}
Only \emph{major} parts are included -- the twelve marked \code{major} in
\code{\link{sf.districts}}. Two water slivers in the Bay and the offshore
Farallon Islands are too small or too far out to label.
}
\source{
Computed from \code{\link{sf.districts}} by \code{data-raw/02-build-rda.R}.
}
\seealso{\code{\link{SfDistrictMap}} and its \code{label.parts} argument,
  \code{\link{sf.district.info}}}
\examples{
sf.district.labels

## The only district currently drawn in more than one labelled piece
sf.district.labels[!sf.district.labels$primary, ]

## The label points, over the map
SfDistrictMap(labels = FALSE, legend = FALSE)
points(sf.district.labels$long, sf.district.labels$lat,
       pch = 21, bg = "white")
}
\keyword{datasets}
