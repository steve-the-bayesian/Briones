\name{sf.districts}
\alias{sf.districts}
\docType{data}
\title{San Francisco supervisor district boundaries}
\description{
Boundaries of the eleven San Francisco Board of Supervisors districts, as
polygon vertices in "long" format: one row per vertex, with a \code{part}
column identifying each ring. Most districts are a single ring, but District 4
and District 6 have several disjoint parts.
}
\usage{sf.districts}
\format{
A data frame of 7507 rows and 7 columns:
\describe{
  \item{long}{Longitude in decimal degrees (WGS 84).}
  \item{lat}{Latitude in decimal degrees (WGS 84).}
  \item{part}{Ring identifier, \code{"district.polygon.ring"}. Vertices sharing
    a value form one closed ring, and its first and last vertex are the same
    point.}
  \item{district}{Integer district number, 1 to 11.}
  \item{hole}{\code{TRUE} if the ring is a hole punched in the enclosing
    polygon rather than an outer boundary. No ring in the current data is a
    hole; the column is kept so that a future boundary revision containing one
    would still draw correctly.}
  \item{offshore}{\code{TRUE} for the single part covering the Farallon
    Islands, which belong to District 4 but lie some 40 km west of the city.}
  \item{major}{\code{TRUE} for the twelve parts that define the default map
    view. The three excluded parts are the offshore one and two water slivers
    in the Bay of under 0.2 square km, which would stretch the plot window by
    about a third for a few pixels of ink.}
}
}
\source{
DataSF, "Current Supervisor Districts" (dataset \code{f2zs-jevy}),
\url{https://data.sf.gov/}, retrieved 13 September 2026 and current as of
8 January 2025. These are the district lines adopted in the 2022
redistricting. The GeoJSON was flattened to this format by the scripts in
\code{data-raw/}; the geometry is otherwise unmodified, and is not simplified.
}
\seealso{\code{\link{sf.district.info}}, \code{\link{sf.district.labels}},
  \code{\link{SfDistrictPolygons}}}
\examples{
str(sf.districts)

## Draw it with nothing but base graphics
r <- sf.districts[sf.districts$major, ]
plot(r$long, r$lat, type = "n", asp = 1 / cos(37.77 * pi / 180))
for (p in unique(r$part)) polygon(r$long[r$part == p], r$lat[r$part == p])
}
\keyword{datasets}
