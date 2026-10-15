\name{sf.district.info}
\alias{sf.district.info}
\docType{data}
\title{Supervisor district metadata}
\description{
One row per San Francisco supervisor district: the sitting supervisor, the area
of the district, and the point used to place its label on a map.
}
\usage{sf.district.info}
\format{
A data frame of 11 rows and 5 columns:
\describe{
  \item{district}{Integer district number, 1 to 11.}
  \item{supervisor}{Name of the sitting supervisor.}
  \item{area.km2}{Area of the district in square kilometres, excluding the
    offshore Farallon Islands part of District 4. The boundaries follow the
    shoreline but include some adjacent water, so these are areas of the
    jurisdictional polygon rather than land areas.}
  \item{long, lat}{The district's primary label point: the interior point of
    its largest part that lies farthest from that part's boundary. This is used
    rather than the centroid because the centroid of a concave or elongated
    district can fall outside the district itself. Districts drawn as several
    disjoint parts have further label points in
    \code{\link{sf.district.labels}}; this is the same as that table's
    \code{primary} row for the district.}
}
}
\source{
As \code{\link{sf.districts}}: DataSF "Current Supervisor Districts", current
as of 8 January 2025. Supervisors change with each election, so treat
\code{supervisor} as a snapshot and re-run \code{data-raw/} to refresh it.
}
\seealso{\code{\link{sf.districts}}, \code{\link{sf.district.labels}}}
\examples{
sf.district.info

## Largest districts by area
head(sf.district.info[order(-sf.district.info$area.km2), c("district", "area.km2")])
}
\keyword{datasets}
