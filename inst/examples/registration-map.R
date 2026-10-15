## Worked example: percent of registered voters registered Republican, by
## San Francisco supervisor district. The figures here are illustrative --
## replace `reg` with real numbers from the Department of Elections.

library(Briones)

reg <- data.frame(
  district = 1:11,
  pct.rep  = c(9.8, 14.2, 8.1, 11.6, 5.2, 6.4, 12.9, 7.3, 5.8, 8.9, 10.4),
  pct.dem  = c(58, 49, 61, 52, 71, 68, 50, 66, 70, 63, 57)
)

## 1. The default: sequential gradient, legend, district numbers.
SfDistrictMap(reg, value = "pct.rep",
              main = "Registered Republicans by supervisor district",
              legend.title = "% of registered voters")

## 2. Print the values in the districts as well.
SfDistrictMap(reg, value = "pct.rep", labels = c("district", "value"),
              legend.title = "% Rep")

## 3. Diverging gradient around the citywide share, so the question becomes
##    "which side of the city average is this district on?". na.col is moved
##    off grey here because the gradient's own midpoint is grey.
citywide <- 9.1
SfDistrictMap(reg, value = "pct.rep", col = SfPalette("blue-red", 64),
              center = citywide, na.col = "#c3c2b7",
              labels = c("district", "value"),
              main = sprintf("Republican registration vs citywide %.1f%%",
                             citywide))

## 4. Two variables on one shared scale, with a single legend for both.
op <- par(mfrow = c(1, 2), oma = c(0, 0, 0, 4))
SfDistrictMap(reg, value = "pct.rep", zlim = c(0, 75), legend = FALSE,
              main = "Republican")
SfDistrictMap(reg, value = "pct.dem", zlim = c(0, 75), legend = FALSE,
              main = "Democrat")
s <- SfDistrictColors(c(0, 75))
SfDistrictLegend(s$breaks, s$palette, title = "%",
                 x = c(0.945, 0.965), y = c(0.32, 0.68))
par(op)

## 5. Who represents what -- a plain reference map, no data involved.
##    Treasure Island picks up a bare "6" of its own, since "district" is among
##    the labels; that is the only cue on the map that the island is District 6.
SfDistrictMap(labels = c("district", "supervisor"), legend = FALSE,
              label.cex = 0.62, na.col = "#f0efec", border = "#898781",
              main = "San Francisco supervisor districts")

## 6. Everything that was drawn, for a table that has to agree with the map.
drawn <- SfDistrictMap(reg, value = "pct.rep")
print(drawn[order(-drawn$value), ])
