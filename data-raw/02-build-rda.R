## Build the packaged datasets from the flattened CSVs.
##
## Run from the package root:  Rscript data-raw/02-build-rda.R
## Requires 01-geojson-to-csv.py to have been run first.
## Uses base R only -- the package must install without any dependencies.

poly <- read.csv("data-raw/district-polygons.csv", stringsAsFactors = FALSE)
meta <- read.csv("data-raw/district-meta.csv", stringsAsFactors = FALSE)

poly$part <- factor(poly$part, levels = unique(poly$part))

## ---------------------------------------------------------------- helpers ---

## Signed area of a closed ring via the shoelace formula. Coordinates are
## degrees, so x is pre-scaled by cos(lat) before use where real areas matter.
RingArea <- function(x, y) {
  n <- length(x)
  if (n < 4L) return(0)
  i <- seq_len(n - 1L)
  sum(x[i] * y[i + 1L] - x[i + 1L] * y[i]) / 2
}

## Ray-casting point-in-polygon test, vectorised over the query points.
InRing <- function(px, py, x, y) {
  inside <- rep(FALSE, length(px))
  n <- length(x)
  j <- n
  for (i in seq_len(n)) {
    xi <- x[i]; yi <- y[i]; xj <- x[j]; yj <- y[j]
    hit <- ((yi > py) != (yj > py)) &
      (px < (xj - xi) * (py - yi) / (yj - yi) + xi)
    inside <- xor(inside, hit)
    j <- i
  }
  inside
}

## Distance from each query point to the nearest edge of a ring.
DistToRing <- function(px, py, x, y) {
  n <- length(x)
  x0 <- x[-n]; y0 <- y[-n]; x1 <- x[-1L]; y1 <- y[-1L]
  dx <- x1 - x0; dy <- y1 - y0
  len2 <- dx * dx + dy * dy
  len2[len2 == 0] <- .Machine$double.eps
  out <- numeric(length(px))
  for (k in seq_along(px)) {
    t <- ((px[k] - x0) * dx + (py[k] - y0) * dy) / len2
    t <- pmin(pmax(t, 0), 1)
    ex <- x0 + t * dx - px[k]
    ey <- y0 + t * dy - py[k]
    out[k] <- sqrt(min(ex * ex + ey * ey))
  }
  out
}

## Interior point of a ring that is farthest from its boundary -- an
## approximate pole of inaccessibility. Far more reliable than a centroid for
## concave or elongated districts, where the centroid can fall outside the
## district entirely. Coarse grid, then two refinement passes.
LabelPoint <- function(x, y, lat0) {
  sx <- cos(lat0 * pi / 180)          # scale longitude so distances are metric-ish
  xs <- x * sx
  xr <- range(xs); yr <- range(y)
  best <- c(mean(xr), mean(yr)); best.d <- -Inf
  step <- c(diff(xr), diff(yr)) / 24

  for (pass in 1:3) {
    gx <- seq(max(xr[1], best[1] - 12 * step[1]),
              min(xr[2], best[1] + 12 * step[1]), length.out = 25)
    gy <- seq(max(yr[1], best[2] - 12 * step[2]),
              min(yr[2], best[2] + 12 * step[2]), length.out = 25)
    g <- expand.grid(x = gx, y = gy)
    ok <- InRing(g$x, g$y, xs, y)
    if (any(ok)) {
      d <- DistToRing(g$x[ok], g$y[ok], xs, y)
      i <- which.max(d)
      if (d[i] > best.d) {
        best.d <- d[i]
        best <- c(g$x[ok][i], g$y[ok][i])
      }
    }
    step <- step / 6
  }
  c(long = best[1] / sx, lat = best[2])
}

## ------------------------------------------------------------------ build ---

parts <- split(poly, poly$part)
part.info <- do.call(rbind, lapply(parts, function(p) {
  sx <- cos(mean(p$lat) * pi / 180)
  a <- abs(RingArea(p$long * sx, p$lat))
  data.frame(part = as.character(p$part[1]), district = p$district[1],
             hole = p$hole[1], offshore = p$offshore[1],
             area = a, stringsAsFactors = FALSE)
}))

## one degree of latitude ~ 111.32 km; longitude already scaled above
DEG.KM <- 111.320
part.info$area.km2 <- part.info$area * DEG.KM^2

## Parts that define the default map view. Two sub-0.2 sq km water slivers in
## the Bay (one east of Mission Bay, one north of Alcatraz) sit well outside the
## built-up city and would otherwise stretch the plot window by a third for a
## few pixels of ink. There is a wide gap in the area distribution -- the next
## smallest part is Treasure Island at 2.3 sq km -- so the cut is unambiguous.
MAJOR.KM2 <- 0.5
part.info$major <- !as.logical(part.info$offshore) &
  part.info$area.km2 >= MAJOR.KM2

info <- meta[order(meta$district), ]
rownames(info) <- NULL

info$area.km2 <- NA_real_
for (i in seq_len(nrow(info))) {
  parts.d <- part.info[part.info$district == info$district[i] &
                       !part.info$offshore, ]
  ## jurisdictional area of the mainland parts: outer rings minus holes
  info$area.km2[i] <- round(
    sum(parts.d$area.km2[parts.d$hole == 0]) - sum(parts.d$area.km2[parts.d$hole == 1]), 3)
}

## A label point for every major outer ring, not just the biggest one per
## district. District 6 is the case that matters: Treasure Island is a separate
## part, and without its own label there is nothing on the map to say which
## district the island belongs to.
lab <- part.info[part.info$major & part.info$hole == 0, ]
lab <- lab[order(lab$district, -lab$area.km2), ]

label.rows <- lapply(seq_len(nrow(lab)), function(i) {
  p <- parts[[lab$part[i]]]
  lp <- LabelPoint(p$long, p$lat, mean(p$lat))
  data.frame(district = as.integer(lab$district[i]),
             part     = lab$part[i],
             long     = round(unname(lp[1]), 6),
             lat      = round(unname(lp[2]), 6),
             area.km2 = lab$area.km2[i],
             stringsAsFactors = FALSE)
})
sf.district.labels <- do.call(rbind, label.rows)

## Rows are ordered by descending area within each district, so the first row
## for a district is its largest part: the one that carries the full label.
sf.district.labels$primary <- !duplicated(sf.district.labels$district)
sf.district.labels <- sf.district.labels[, c("district", "part", "long", "lat",
                                             "primary", "area.km2")]
rownames(sf.district.labels) <- NULL

stopifnot(sum(sf.district.labels$primary) == nrow(info),
          !anyNA(sf.district.labels$long), !anyNA(sf.district.labels$lat))

## sf.district.info keeps the primary point, so the common one-label-per-district
## case needs only that table.
primary <- sf.district.labels[sf.district.labels$primary, ]
info$long <- primary$long[match(info$district, primary$district)]
info$lat <- primary$lat[match(info$district, primary$district)]

sf.districts <- data.frame(
  long     = poly$long,
  lat      = poly$lat,
  part     = as.character(poly$part),
  district = as.integer(poly$district),
  hole     = as.logical(poly$hole),
  offshore = as.logical(poly$offshore),
  major    = part.info$major[match(as.character(poly$part), part.info$part)],
  stringsAsFactors = FALSE
)

sf.district.info <- data.frame(
  district   = as.integer(info$district),
  supervisor = info$supervisor,
  area.km2   = info$area.km2,
  long       = info$long,
  lat        = info$lat,
  stringsAsFactors = FALSE
)

save(sf.districts, file = "data/sf.districts.rda", compress = "xz")
save(sf.district.info, file = "data/sf.district.info.rda", compress = "xz")
save(sf.district.labels, file = "data/sf.district.labels.rda", compress = "xz")

cat("sf.districts     :", nrow(sf.districts), "vertices,",
    length(unique(sf.districts$part)), "parts,",
    length(unique(sf.districts$part[sf.districts$major])), "major\n")
cat("default view     : lon",
    paste(round(range(sf.districts$long[sf.districts$major]), 4), collapse = " "),
    "| lat",
    paste(round(range(sf.districts$lat[sf.districts$major]), 4), collapse = " "),
    "\n")
cat("sf.district.info :", nrow(sf.district.info), "districts\n")
cat("sf.district.labels:", nrow(sf.district.labels), "label points,",
    sum(!sf.district.labels$primary), "on secondary parts\n")
print(sf.district.info)
print(sf.district.labels[!sf.district.labels$primary, ])
