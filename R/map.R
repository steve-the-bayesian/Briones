## The user-facing map. Draws the eleven supervisor districts, filled by value.

#' Map a numeric variable by San Francisco supervisor district
#'
#' Draws the eleven San Francisco Board of Supervisors districts, shading each
#' one according to a numeric value. The colour gradient is specified the same
#' way as in \code{\link[graphics]{image}} and
#' \code{\link[stats]{heatmap}}: \code{col} is a vector of colours spanning the
#' scale, optionally with \code{zlim} or \code{breaks}.
#'
#' \code{data} is normally a data frame with one row per district: one column
#' identifying the district and one holding the value. Column names are guessed
#' when not given -- a column called something like \code{district} for the
#' identifier, and the first numeric column for the value -- but naming
#' \code{district} and \code{value} explicitly is clearer. District identifiers
#' may be numbers (\code{1}, \code{1.0}) or strings (\code{"1"},
#' \code{"District 1"}). Districts absent from \code{data}, or present with an
#' \code{NA} value, are filled with \code{na.col}.
#'
#' A named numeric vector (names being district identifiers) is also accepted,
#' as is \code{NULL}, which draws an unfilled reference map.
#'
#' @param data A data frame, a named numeric vector, or \code{NULL}.
#' @param district Name of the column in \code{data} holding district
#'   identifiers. Guessed if \code{NULL}.
#' @param value Name of the column holding the values to map. Guessed if
#'   \code{NULL}.
#' @param col Vector of colours forming the gradient, low to high. The default
#'   is a sequential single-hue ramp; see \code{\link{SfPalette}}. Any colour
#'   vector works, including \code{hcl.colors(64, "YlOrRd")} or
#'   \code{heat.colors(64)}.
#' @param zlim Length-2 range the gradient spans. Defaults to the range of the
#'   data. Fix it explicitly to compare several maps on one scale.
#' @param breaks Bin edges, of length \code{length(col) + 1}; overrides
#'   \code{zlim}. Use for unequal classes such as quantile bins.
#' @param center Value to centre the scale on, making \code{zlim} symmetric
#'   about it. Use with a diverging gradient, e.g. \code{center = 50} with
#'   \code{col = SfPalette("blue-red")}.
#' @param clip If \code{TRUE} (default), values beyond \code{zlim} take the end
#'   colour of the gradient rather than being drawn as missing.
#' @param na.col Fill colour for districts with no value.
#' @param border,lwd,lty Colour, width and type of the district boundaries. The
#'   default border is the chart surface colour, which reads as a thin gap
#'   between districts.
#' @param labels What to print inside each district: any of \code{"district"},
#'   \code{"supervisor"} and \code{"value"}, stacked in the order given.
#'   \code{TRUE} means \code{"district"}; \code{FALSE} or \code{NULL} means no
#'   labels.
#' @param label.cex,label.col,label.digits Size, colour and number of decimal
#'   places for those labels. \code{label.col = "auto"} picks black or white per
#'   district, whichever contrasts with the fill.
#' @param label.parts Also put a bare district number on each substantial
#'   disjoint part of a district, so that Treasure Island is identifiable as
#'   part of District 6. Applies only when \code{labels} includes
#'   \code{"district"}.
#' @param legend Draw the colour-scale legend?
#' @param legend.title Title for the legend. Defaults to the name of the value
#'   column.
#' @param main,sub Title and subtitle.
#' @param xlim,ylim Longitude and latitude range of the view. The default frames
#'   the city, which excludes two sub-0.2 square km water slivers in the Bay
#'   that would otherwise stretch the window for a few pixels of ink; they are
#'   still drawn if the view is widened.
#' @param offshore Include the offshore Farallon Islands portion of District 4?
#'   \code{FALSE} by default: it lies some 40 km west of the city and would
#'   otherwise dominate the map.
#' @param add Draw on top of an existing plot instead of starting a new one?
#' @param mar Figure margins. The default leaves room for the legend and title.
#' @param \dots Further arguments passed to \code{\link[graphics]{title}}.
#' @return Invisibly, a data frame with one row per district giving the value
#'   and fill colour used, with the scale's \code{breaks} and \code{zlim}
#'   attached as attributes.
#' @seealso \code{\link{SfPalette}}, \code{\link{SfDistrictColors}},
#'   \code{\link{SfDistrictLegend}}, \code{\link{sf.districts}}
#' @examples
#' ## Made-up registration percentages
#' d <- data.frame(district = 1:11,
#'                 pct.rep = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4,
#'                             12.9, 7.3, 5.8, 8.9, 10.4))
#' SfDistrictMap(d, main = "Registered Republicans by district")
#'
#' ## Diverging scale centred on the citywide figure
#' SfDistrictMap(d, col = SfPalette("blue-red", 64), center = 9.1,
#'                 labels = c("district", "value"))
#'
#' ## An empty reference map
#' SfDistrictMap(labels = c("district", "supervisor"), legend = FALSE)
#' @export
SfDistrictMap <- function(data = NULL,
                          district = NULL,
                          value = NULL,
                          col = SfPalette("blue", 64),
                          zlim = NULL,
                          breaks = NULL,
                          center = NULL,
                          clip = TRUE,
                          na.col = "#e1e0d9",   # .sf.ink$hairline
                          border = "#fcfcfb",   # .sf.ink$surface
                          lwd = 1.2,
                          lty = 1,
                          labels = TRUE,
                          label.cex = 0.8,
                          label.col = "auto",
                          label.digits = NULL,
                          label.parts = TRUE,
                          legend = TRUE,
                          legend.title = NULL,
                          main = NULL,
                          sub = NULL,
                          xlim = NULL,
                          ylim = NULL,
                          offshore = FALSE,
                          add = FALSE,
                          mar = NULL,
                          ...) {
  info <- sf.district.info
  geom <- sf.districts
  if (!isTRUE(offshore)) geom <- geom[!geom$offshore, , drop = FALSE]

  vals <- .SfExtract(data, district, value, info$district)
  if (is.null(legend.title)) legend.title <- vals$label

  scale <- SfDistrictColors(vals$values, col = col, zlim = zlim,
                            breaks = breaks, center = center, clip = clip,
                            na.col = na.col)
  fill <- scale$col

  if (!add) {
    if (is.null(mar)) {
      mar <- c(0.6, 0.6, if (is.null(main) && is.null(sub)) 0.6 else 2.4,
               if (isTRUE(legend)) 5.4 else 0.6)
    }
    op <- par(mar = mar)
    on.exit(par(op), add = TRUE)
    ## Frame the city, not the outlying slivers -- see the 'major' column.
    frame.rows <- if (isTRUE(offshore)) rep(TRUE, nrow(geom)) else geom$major
    box <- geom[frame.rows, , drop = FALSE]
    if (is.null(xlim)) xlim <- range(box$long) + c(-1, 1) * diff(range(box$long)) * 0.01
    if (is.null(ylim)) ylim <- range(box$lat) + c(-1, 1) * diff(range(box$lat)) * 0.01

    plot.new()
    ## No projection: longitude/latitude are plotted directly, with the aspect
    ## ratio corrected for the city's latitude so shapes are not stretched.
    plot.window(xlim = xlim, ylim = ylim,
                asp = 1 / cos(mean(ylim) * pi / 180),
                xaxs = "i", yaxs = "i")
  }

  ## One path per polygon: a district can have several disjoint parts (islands),
  ## and a part can have holes, which polypath() fills correctly.
  polys <- sub("\\.[0-9]+$", "", geom$part)
  for (p in unique(polys)) {
    rows <- geom[polys == p, , drop = FALSE]
    d <- match(rows$district[1L], info$district)
    rings <- split(rows, factor(rows$part, levels = unique(rows$part)))
    if (length(rings) == 1L) {
      polygon(rows$long, rows$lat, col = fill[d], border = border,
              lwd = lwd, lty = lty)
    } else {
      xs <- unlist(lapply(rings, function(r) c(r$long, NA)), use.names = FALSE)
      ys <- unlist(lapply(rings, function(r) c(r$lat, NA)), use.names = FALSE)
      keep <- seq_len(length(xs) - 1L)   # drop the trailing NA separator
      polypath(xs[keep], ys[keep], col = fill[d], border = border,
               lwd = lwd, lty = lty, rule = "evenodd")
    }
  }

  keys <- .SfLabelKeys(labels)
  if (length(keys)) {
    lab <- sf.district.labels
    ## A district drawn as several disjoint parts -- District 6, which includes
    ## Treasure Island -- gets a bare district number on the secondary parts, so
    ## it is clear which district the island belongs to. Only when district
    ## numbers are being shown at all: a lone "6" next to mainland labels
    ## reading "6.4" would look like a value rather than a district.
    if (!isTRUE(label.parts) || !"district" %in% keys)
      lab <- lab[lab$primary, , drop = FALSE]
    d <- match(lab$district, info$district)
    txt <- character(nrow(lab))
    full <- .SfLabelText(keys, info, vals$values, label.digits)
    txt[lab$primary] <- full[d[lab$primary]]
    txt[!lab$primary] <- as.character(lab$district[!lab$primary])
    ## Secondary parts are small, so their number is set slightly smaller.
    cex <- ifelse(lab$primary, label.cex, label.cex * 0.85)
    ink <- if (identical(label.col, "auto")) .SfContrastInk(fill)[d] else
      rep_len(label.col, nrow(lab))

    ## Hide a secondary number when its district's own label came out empty,
    ## so a district never shows a label on the island but none on land.
    show <- nzchar(txt) & (lab$primary | nzchar(full[d]))
    text(lab$long[show], lab$lat[show], txt[show],
         cex = cex[show], col = ink[show])
  }

  if (isTRUE(legend))
    SfDistrictLegend(scale$breaks, scale$palette, title = legend.title,
                     na.col = if (anyNA(vals$values)) na.col else NULL)

  if (!is.null(main) || !is.null(sub))
    title(main = main, sub = sub, col.main = .sf.ink$primary,
          col.sub = .sf.ink$secondary, ...)

  out <- data.frame(district = info$district, supervisor = info$supervisor,
                    value = vals$values, col = fill,
                    stringsAsFactors = FALSE)
  attr(out, "breaks") <- scale$breaks
  attr(out, "zlim") <- scale$zlim
  invisible(out)
}

#' District boundaries, optionally merged with your own values
#'
#' Returns the polygon vertices in "long" format -- one row per vertex, with a
#' \code{part} column identifying each ring. Handy for drawing the map with
#' another graphics system, for instance
#' \code{ggplot(SfDistrictPolygons(d), aes(long, lat, group = part,
#' fill = value)) + geom_polygon()}.
#'
#' @inheritParams SfDistrictMap
#' @param offshore Include the offshore Farallon Islands part of District 4?
#' @return A data frame of vertices. When \code{data} is supplied, a
#'   \code{value} column is merged on by district.
#' @examples
#' str(SfDistrictPolygons())
#' @export
SfDistrictPolygons <- function(data = NULL, district = NULL, value = NULL,
                               offshore = FALSE) {
  geom <- sf.districts
  if (!isTRUE(offshore)) geom <- geom[!geom$offshore, , drop = FALSE]
  geom <- geom[order(geom$district), , drop = FALSE]
  rownames(geom) <- NULL

  info <- sf.district.info
  geom$supervisor <- info$supervisor[match(geom$district, info$district)]

  if (!is.null(data)) {
    vals <- .SfExtract(data, district, value, info$district)
    geom$value <- vals$values[match(geom$district, info$district)]
  }
  geom
}

## ------------------------------------------------------------------ input ---

## Pull a value per district out of whatever the user passed, returning a
## numeric vector aligned with 'ids' plus a label for the legend.
.SfExtract <- function(data, district, value, ids) {
  n <- length(ids)
  if (is.null(data)) return(list(values = rep(NA_real_, n), label = NULL))

  if (is.data.frame(data)) {
    if (!nrow(data)) stop("'data' has no rows", call. = FALSE)
    dcol <- .SfFindDistrict(data, district)
    vcol <- .SfFindValue(data, value, dcol)
    keys <- .SfNormDistrict(data[[dcol]])
    vals <- .SfAsNumeric(data[[vcol]], vcol)
    label <- vcol
  } else if (is.atomic(data) && !is.null(names(data))) {
    keys <- .SfNormDistrict(names(data))
    vals <- .SfAsNumeric(unname(data), "data")
    label <- if (!is.null(value)) value else NULL
  } else if (is.atomic(data) && length(data) == n) {
    ## Unnamed and exactly one value per district: assume ascending order.
    return(list(values = .SfAsNumeric(data, "data"),
                label = if (!is.null(value)) value else NULL))
  } else {
    stop("'data' must be a data frame, a named numeric vector, or a numeric ",
         "vector with one element per district (", n, ")", call. = FALSE)
  }

  bad <- is.na(keys) | !keys %in% ids
  if (any(bad)) {
    shown <- unique(as.character(if (is.data.frame(data)) data[[dcol]][bad]
                                 else names(data)[bad]))
    warning("ignoring value(s) for unrecognised district(s): ",
            paste(shown, collapse = ", "),
            ". Expected identifiers 1-", max(ids), ".", call. = FALSE)
    keys <- keys[!bad]; vals <- vals[!bad]
  }
  dup <- duplicated(keys)
  if (any(dup))
    stop("more than one value supplied for district(s): ",
         paste(unique(keys[dup]), collapse = ", "),
         ". Aggregate to one row per district first.", call. = FALSE)

  out <- rep(NA_real_, n)
  out[match(keys, ids)] <- vals
  list(values = out, label = label)
}

## Candidate names for the district column, compared with punctuation and case
## stripped ("Sup. District" -> "supdistrict").
.sf.dist.names <- c("district", "districts", "dist", "supdist", "supdistrict",
                    "supervisordistrict", "supervisorialdistrict",
                    "supdistnum", "sd", "districtnumber", "districtnum")

.SfSquash <- function(x) gsub("[^a-z0-9]", "", tolower(x))

.SfFindDistrict <- function(data, district) {
  if (!is.null(district)) {
    if (!district %in% names(data))
      stop("column '", district, "' not found in 'data'. Available: ",
           paste(names(data), collapse = ", "), call. = FALSE)
    return(district)
  }
  hit <- which(.SfSquash(names(data)) %in% .sf.dist.names)
  if (length(hit)) return(names(data)[hit[1L]])

  ## Nothing named like a district: fall back to any column that looks like a
  ## set of distinct district numbers.
  ids <- sf.district.info$district
  plausible <- vapply(data, function(x) {
    k <- .SfNormDistrict(x)
    !anyNA(k) && !any(duplicated(k)) && all(k %in% ids)
  }, logical(1L))
  if (sum(plausible) == 1L) return(names(data)[which(plausible)])
  stop("cannot tell which column holds the district identifiers; ",
       "name it with district = \"<column>\"", call. = FALSE)
}

.SfFindValue <- function(data, value, dcol) {
  if (!is.null(value)) {
    if (!value %in% names(data))
      stop("column '", value, "' not found in 'data'. Available: ",
           paste(names(data), collapse = ", "), call. = FALSE)
    if (identical(value, dcol))
      stop("'value' and 'district' refer to the same column ('", value, "')",
           call. = FALSE)
    return(value)
  }
  cand <- setdiff(names(data)[vapply(data, is.numeric, logical(1L))], dcol)
  if (!length(cand))
    stop("no numeric column to map; name one with value = \"<column>\"",
         call. = FALSE)
  if (length(cand) > 1L)
    message("Briones: mapping column '", cand[1L],
            "'; use value = \"<column>\" to choose another.")
  cand[1L]
}

## District identifiers may arrive as numbers, factors or strings such as
## "District 1" or "01".
.SfNormDistrict <- function(x) {
  if (is.factor(x)) x <- as.character(x)
  if (is.character(x)) x <- suppressWarnings(as.numeric(gsub("[^0-9.]", "", x)))
  x <- suppressWarnings(as.numeric(x))
  x[!is.finite(x)] <- NA_real_
  as.integer(round(x))
}

.SfAsNumeric <- function(x, what) {
  if (is.factor(x)) x <- as.character(x)
  if (is.character(x)) {
    num <- suppressWarnings(as.numeric(x))
    if (any(is.na(num) & !is.na(x)))
      stop("'", what, "' is not numeric and cannot be coerced to numeric",
           call. = FALSE)
    x <- num
  }
  if (is.logical(x)) x <- as.numeric(x)
  if (!is.numeric(x)) stop("'", what, "' must be numeric", call. = FALSE)
  as.numeric(x)
}

## ----------------------------------------------------------------- labels ---

.SfLabelKeys <- function(labels) {
  if (is.null(labels) || isFALSE(labels)) return(character(0))
  if (isTRUE(labels)) return("district")
  keys <- as.character(labels)
  ok <- c("district", "supervisor", "value")
  bad <- setdiff(keys, ok)
  if (length(bad))
    stop("unknown 'labels' entry: ", paste(bad, collapse = ", "),
         ". Choose from ", paste(ok, collapse = ", "), ".", call. = FALSE)
  keys
}

.SfLabelText <- function(keys, info, values, digits) {
  parts <- lapply(keys, function(k) switch(k,
    district   = as.character(info$district),
    supervisor = info$supervisor,
    value      = .SfFmt(values, digits)
  ))
  txt <- do.call(paste, c(parts, list(sep = "\n")))
  ## Drop blank lines left by missing values so labels stay vertically centred.
  txt <- gsub("\n+", "\n", txt)
  trimws(txt, whitespace = "[\n]")
}

.SfFmt <- function(v, digits = NULL) {
  if (is.null(digits)) {
    fin <- v[is.finite(v)]
    digits <- if (!length(fin) || all(fin == round(fin))) 0L else 1L
  }
  out <- formatC(v, format = "f", digits = digits, big.mark = ",")
  out[!is.finite(v)] <- ""
  out
}
