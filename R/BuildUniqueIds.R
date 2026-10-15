BuildUniqueIds <- function(mvf, info.fields = c(
  "szNameFirst",
  "szNameMiddle",
  "szNameLast",
  "szEmailAddress",
  "sBirthPlace")) {
  ## Args:
  ##   mvf:  A data frame containin the master voter file.
  ##   info.fields:  Names of variables present in the voter file.  
  ##
  ## Returns:
  ##   A character vector is returned, equal in length to the number of rows in
  ##   'mvf'.  Each entry concatenates the requested information fields for each user.
  stopifnot(is.data.frame(mvf))
  missing.fields <- !(info.fields %in% names(mvf))
  
  if (any(missing.fields)) {
    missing.fields <- info.fields[missing.fields]
    stop(paste(c("The following expected fields were missing from the voter file: ", missing.fields)))
  }
  
  personal.info <- mvf[, info.fields]
  ans <- apply(personal.info, 1, paste, collapse="-")
  return(ans)
}
