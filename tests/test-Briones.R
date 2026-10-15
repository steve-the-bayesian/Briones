## Base-R test suite: the package has no dependencies, so neither do its tests.
## Run by R CMD check, or directly with Rscript tests/test-Briones.R.

library(Briones)

failures <- 0L
check <- function(label, expr) {
  ok <- isTRUE(tryCatch(expr, error = function(e) {
    cat("  ERROR in", label, ":", conditionMessage(e), "\n"); FALSE
  }))
  if (!ok) {
    failures <<- failures + 1L
    cat("FAIL:", label, "\n")
  }
  invisible(ok)
}

## Draw to a throwaway device so plotting is exercised without writing files.
OpenNull <- function() {
  pdf(file = NULL, width = 7, height = 7)
  invisible(NULL)
}

d <- data.frame(district = 1:11,
                pct.rep = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
                            12.9, 7.3, 5.8, 8.9, 10.4))

## ---------------------------------------------------------------- the data ---

check("11 districts", nrow(sf.district.info) == 11L)
check("districts are 1:11", identical(sort(sf.district.info$district), 1:11))
check("every district has geometry",
      identical(sort(unique(sf.districts$district)), 1:11))
check("no missing coordinates",
      !anyNA(sf.districts$long) && !anyNA(sf.districts$lat))
check("rings are closed", {
  s <- split(sf.districts, sf.districts$part)
  all(vapply(s, function(r) {
    n <- nrow(r)
    r$long[1] == r$long[n] && r$lat[1] == r$lat[n]
  }, logical(1)))
})
check("rings have at least 4 vertices", {
  s <- split(sf.districts, sf.districts$part)
  all(vapply(s, nrow, integer(1)) >= 4L)
})
check("coordinates are in and around San Francisco", {
  m <- sf.districts[sf.districts$major, ]
  all(m$long > -122.6 & m$long < -122.3 & m$lat > 37.6 & m$lat < 37.9)
})
check("exactly one offshore part",
      length(unique(sf.districts$part[sf.districts$offshore])) == 1L)
check("offshore parts are never major",
      !any(sf.districts$major & sf.districts$offshore))
check("every major part has a label point", {
  major <- unique(sf.districts$part[sf.districts$major])
  setequal(major, sf.district.labels$part)
})
check("exactly one primary label point per district",
      identical(sort(sf.district.labels$district[sf.district.labels$primary]),
                1:11))
check("Treasure Island is labelled and belongs to district 6", {
  ## The island is district 6's secondary part; without its own label point
  ## nothing on the map would say which district it belongs to.
  sec <- sf.district.labels[!sf.district.labels$primary, ]
  nrow(sec) == 1L && sec$district == 6L && sec$part == "6.3.1" &&
    sec$long > -122.38 && sec$long < -122.355 &&
    sec$lat > 37.80 && sec$lat < 37.84
})
check("the primary label point is the largest part of its district", {
  s <- split(sf.district.labels, sf.district.labels$district)
  all(vapply(s, function(r)
    isTRUE(r$primary[which.max(r$area.km2)]), logical(1)))
})
check("sf.district.info holds the primary label point", {
  p <- sf.district.labels[sf.district.labels$primary, ]
  i <- sf.district.info
  all(i$long == p$long[match(i$district, p$district)]) &&
    all(i$lat == p$lat[match(i$district, p$district)])
})
check("every label point falls inside the part it labels", {
  ## Ray casting: a point is inside the ring if a ray from it crosses the
  ## boundary an odd number of times. A label must sit in the part it names,
  ## which a centroid would not guarantee for a concave shape.
  inside <- function(px, py, x, y) {
    hits <- FALSE
    j <- length(x)
    for (i in seq_along(x)) {
      if (((y[i] > py) != (y[j] > py)) &&
          (px < (x[j] - x[i]) * (py - y[i]) / (y[j] - y[i]) + x[i]))
        hits <- !hits
      j <- i
    }
    hits
  }
  all(vapply(seq_len(nrow(sf.district.labels)), function(k) {
    r <- sf.districts[sf.districts$part == sf.district.labels$part[k], ]
    inside(sf.district.labels$long[k], sf.district.labels$lat[k],
           r$long, r$lat)
  }, logical(1)))
})
check("areas are positive and plausible",
      all(sf.district.info$area.km2 > 0) &&
        abs(sum(sf.district.info$area.km2) - 122) < 5)

## -------------------------------------------------------------- gradients ---

check("SfPalette returns n colours", length(SfPalette("blue", 7)) == 7L)
check("palette colours are valid", {
  x <- SfPalette("blue-red", 13)
  !anyNA(x) && all(!is.na(col2rgb(x)[1, ]))
})
check("sequential ramp runs light to dark", {
  x <- SfPalette("blue", 9)
  l <- colSums(col2rgb(x))
  all(diff(l) < 0)
})
check("diverging ramp is lightest in the middle", {
  x <- SfPalette("blue-red", 9)
  l <- colSums(col2rgb(x))
  which.max(l) == 5L
})
check("rev reverses", identical(SfPalette("blue", 5, rev = TRUE),
                                rev(SfPalette("blue", 5))))
check("SfPalette rejects a bad n",
      inherits(tryCatch(SfPalette("blue", 0), error = function(e) e), "error"))

## ------------------------------------------------------------ value scale ---

check("one colour per value", {
  s <- SfDistrictColors(c(1, 2, 3), col = SfPalette("blue", 4))
  length(s$col) == 3L
})
check("breaks are one longer than col", {
  s <- SfDistrictColors(1:3, col = SfPalette("blue", 6))
  length(s$breaks) == 7L
})
check("lowest value gets the first colour, highest the last", {
  p <- SfPalette("blue", 8)
  s <- SfDistrictColors(c(0, 10), col = p)
  s$col[1] == p[1] && s$col[2] == p[8]
})
check("NA gets na.col", {
  s <- SfDistrictColors(c(1, NA), col = SfPalette("blue", 4),
                        na.col = "#123456")
  s$col[2] == "#123456"
})
check("NaN and Inf are treated as missing", {
  s <- SfDistrictColors(c(1, NaN, Inf, -Inf), col = SfPalette("blue", 4),
                        na.col = "#123456")
  all(s$col[2:4] == "#123456")
})
check("clip pins out-of-range values to the ends", {
  p <- SfPalette("blue", 8)
  s <- SfDistrictColors(c(-5, 99), col = p, zlim = c(0, 10))
  s$col[1] == p[1] && s$col[2] == p[8]
})
check("clip = FALSE drops out-of-range values, as image() does", {
  s <- SfDistrictColors(c(-5, 99), col = SfPalette("blue", 8),
                        zlim = c(0, 10), clip = FALSE, na.col = "#123456")
  all(s$col == "#123456")
})
check("center makes the scale symmetric", {
  s <- SfDistrictColors(c(40, 55), col = SfPalette("blue-red", 9),
                        center = 50)
  identical(s$zlim, c(40, 60))
})
check("a constant value still maps", {
  s <- SfDistrictColors(c(5, 5, 5), col = SfPalette("blue", 8))
  s$zlim[1] < 5 && s$zlim[2] > 5 && !anyNA(s$col)
})
check("all-NA values still map", {
  s <- SfDistrictColors(rep(NA_real_, 3), col = SfPalette("blue", 8))
  all(s$col == s$na.col)
})
check("explicit breaks are used verbatim", {
  b <- c(0, 1, 5, 20)
  s <- SfDistrictColors(c(0.5, 3, 10), col = SfPalette("blue", 3),
                        breaks = b)
  identical(s$breaks, b) && !anyNA(s$col)
})
check("wrong-length breaks is an error",
      inherits(tryCatch(SfDistrictColors(1, col = SfPalette("blue", 4),
                                         breaks = 1:3),
                        error = function(e) e), "error"))
check("bins follow image(): upper edge belongs to its bin", {
  p <- SfPalette("blue", 2)
  s <- SfDistrictColors(c(0, 0.5, 1), col = p, zlim = c(0, 1))
  identical(s$col, c(p[1], p[1], p[2]))
})

## ------------------------------------------------------------------- maps ---

OpenNull()
on.exit(dev.off(), add = TRUE)

check("map returns a row per district", {
  r <- SfDistrictMap(d)
  nrow(r) == 11L && all(!is.na(r$col))
})
check("map carries the scale as attributes", {
  r <- SfDistrictMap(d)
  !is.null(attr(r, "breaks")) && !is.null(attr(r, "zlim"))
})
check("values land on the right districts", {
  r <- SfDistrictMap(d)
  identical(r$value, d$pct.rep)
})
check("a map with no data draws", {
  r <- SfDistrictMap()
  all(is.na(r$value)) && nrow(r) == 11L
})
check("district identifiers may be strings", {
  r <- SfDistrictMap(data.frame(district = paste("District", 1:11),
                                v = d$pct.rep))
  identical(r$value, d$pct.rep)
})
check("zero-padded identifiers work", {
  r <- SfDistrictMap(data.frame(district = sprintf("%02d", 1:11),
                                v = d$pct.rep))
  identical(r$value, d$pct.rep)
})
check("named vectors work", {
  r <- SfDistrictMap(setNames(d$pct.rep, d$district))
  identical(r$value, d$pct.rep)
})
check("an unnamed vector of the right length works", {
  r <- SfDistrictMap(d$pct.rep)
  identical(r$value, d$pct.rep)
})
check("rows may be in any order", {
  r <- SfDistrictMap(d[sample(11), ])
  identical(r$value, d$pct.rep)
})
check("missing districts come back NA", {
  r <- SfDistrictMap(d[d$district <= 5, ])
  all(is.na(r$value[6:11])) && identical(r$value[1:5], d$pct.rep[1:5])
})
check("missing districts are filled with na.col", {
  r <- SfDistrictMap(d[d$district <= 5, ], na.col = "#123456")
  all(r$col[6:11] == "#123456")
})
check("explicit column names are honoured", {
  dd <- data.frame(sd = 1:11, a = d$pct.rep, b = rev(d$pct.rep))
  r <- SfDistrictMap(dd, district = "sd", value = "b")
  identical(r$value, rev(d$pct.rep))
})
check("unrecognised districts warn and are dropped", {
  dd <- rbind(d, data.frame(district = 12, pct.rep = 1))
  r <- withCallingHandlers(SfDistrictMap(dd),
                           warning = function(w) invokeRestart("muffleWarning"))
  got <- tryCatch({ SfDistrictMap(dd); FALSE },
                  warning = function(w) TRUE)
  got && identical(r$value, d$pct.rep)
})
check("duplicate districts are an error",
      inherits(tryCatch(SfDistrictMap(rbind(d, d)),
                        error = function(e) e), "error"))
check("a missing column name is an error",
      inherits(tryCatch(SfDistrictMap(d, value = "nope"),
                        error = function(e) e), "error"))
check("district and value cannot be the same column",
      inherits(tryCatch(SfDistrictMap(d, district = "district",
                                      value = "district"),
                        error = function(e) e), "error"))
check("a non-numeric value column is an error",
      inherits(tryCatch(SfDistrictMap(data.frame(district = 1:11,
                                                 v = letters[1:11])),
                        error = function(e) e), "error"))
check("an empty data frame is an error",
      inherits(tryCatch(SfDistrictMap(d[0, ]), error = function(e) e),
               "error"))
check("an unusable label keyword is an error",
      inherits(tryCatch(SfDistrictMap(d, labels = "nope"),
                        error = function(e) e), "error"))
check("every label combination draws", {
  for (k in list(TRUE, FALSE, NULL, "district", "supervisor", "value",
                 c("district", "value"),
                 c("district", "supervisor", "value")))
    SfDistrictMap(d, labels = k)
  TRUE
})
check("label.parts draws with both settings", {
  for (lp in c(TRUE, FALSE))
    for (k in list(TRUE, "district", "value", c("district", "value")))
      SfDistrictMap(d, labels = k, label.parts = lp)
  TRUE
})
check("a district missing from the data still labels its island", {
  ## District 6 absent: the island should be labelled 6 just like the
  ## mainland, not silently dropped.
  r <- SfDistrictMap(d[d$district != 6, ], labels = c("district", "value"))
  is.na(r$value[r$district == 6])
})
check("base R palettes work", {
  r <- SfDistrictMap(d, col = heat.colors(12))
  length(unique(r$col)) > 1L
})
check("a single-colour gradient works", {
  r <- SfDistrictMap(d, col = "#2a78d6")
  all(r$col == "#2a78d6")
})
check("offshore = TRUE draws", { SfDistrictMap(d, offshore = TRUE); TRUE })
check("add = TRUE overlays", {
  SfDistrictMap(d)
  SfDistrictMap(labels = FALSE, legend = FALSE, col = NA, border = "black",
                add = TRUE)
  TRUE
})
check("explicit xlim/ylim draw", {
  SfDistrictMap(d, xlim = c(-122.48, -122.38), ylim = c(37.74, 37.81))
  TRUE
})
check("the legend can be drawn by hand", {
  s <- SfDistrictColors(d$pct.rep)
  SfDistrictMap(d, legend = FALSE)
  r <- SfDistrictLegend(s$breaks, s$palette, title = "x", na.col = "#cccccc")
  length(r$at) >= 2L
})
check("a wrong-length legend is an error",
      inherits(tryCatch(SfDistrictLegend(1:3, SfPalette("blue", 8)),
                        error = function(e) e), "error"))

## -------------------------------------------------------------- polygons ----

check("polygons come back merged with values", {
  p <- SfDistrictPolygons(d)
  "value" %in% names(p) &&
    all(p$value[p$district == 2] == d$pct.rep[2]) &&
    !any(p$offshore)
})
check("polygons without data have no value column",
      !("value" %in% names(SfDistrictPolygons())))
check("offshore polygons can be requested",
      any(SfDistrictPolygons(offshore = TRUE)$offshore))

## ------------------------------------------------------------------------ ---

if (failures > 0L) stop(failures, " test(s) failed") else cat("All tests passed.\n")
