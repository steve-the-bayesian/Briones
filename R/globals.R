## sf.districts, sf.district.info and sf.district.labels are lazy-loaded
## package datasets, so R CMD check cannot see where the bindings come from.
## Declare them.
utils::globalVariables(c("sf.districts", "sf.district.info",
                         "sf.district.labels"))
