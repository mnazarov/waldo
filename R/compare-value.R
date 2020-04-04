compare_value <- function(x, y, path = "x", tolerance = .Machine$double.eps^0.5) {
  attributes(x) <- NULL
  attributes(y) <- NULL

  if (is.numeric(x)) {
    if (num_equal(x, y, tolerance)) {
      return(new_compare())
    }

    x_cmp <- num_format(x)
    y_cmp <- num_format(y)
  } else if (is.character(x)) {
    x_cmp <- encodeString(x, quote = "'")
    y_cmp <- encodeString(y, quote = "'")
  } else {
    x_cmp <- x
    y_cmp <- y
  }

  diff <- ses(x_cmp, y_cmp)
  if (nrow(diff) == 0) {
    if (is.numeric(x)) {
      xi <- seq_along(x)
      diff <- ses_df(xi, xi, "c", xi, xi)[x != y, , drop = FALSE]
      x_cmp <- num_format(y - x)
      y_cmp <- rep(0, length(x))
      path <- glue("\u0394{path}")
    } else {
      return(new_compare())
    }
  }

  chunks <- diff_split(diff, length(x))
  out <- map_chr(chunks, diff_render, x = x_cmp, y = y_cmp, path = path,
    diff_a = function(x) cli::col_blue("+", x),
    diff_d = function(x) cli::col_yellow("-", x),
    diff_c = function(x, y) paste0(cli::col_yellow(x), "/", cli::col_blue(y)),
    path_context = function(path, start, end) glue("{path}[{start}:{end}]"),
    combine = function(path, diff) paste0(path, ": ", paste0(diff, collapse = " "))
  )
  new_compare(out)
}