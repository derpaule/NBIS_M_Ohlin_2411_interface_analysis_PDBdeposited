render_pml_template <- function(template_path, values) {
  if (!file.exists(template_path)) {
    stop(paste0("Template not found: ", template_path))
  }

  template <- paste(readLines(template_path, warn = FALSE), collapse = "\n")
  required_keys <- unique(gsub("\\{\\{|\\}\\}", "", regmatches(template, gregexpr("\\{\\{[A-Za-z0-9_]+\\}\\}", template))[[1]]))

  missing_keys <- setdiff(required_keys, names(values))
  if (length(missing_keys) > 0) {
    stop(paste0("Missing template values: ", paste(missing_keys, collapse = ", ")))
  }

  rendered <- template
  for (key in names(values)) {
    rendered <- gsub(
      pattern = paste0("\\{\\{", key, "\\}\\}"),
      replacement = as.character(values[[key]]),
      x = rendered,
      fixed = FALSE
    )
  }

  rendered
}

write_csv_pymol_f <- function(data, pathname) {
  readr::write_csv(x = data, file = pathname, col_names = FALSE, quote = "none")
}

write_pml_lines <- function(lines, pathname) {
  readr::write_lines(lines, file = pathname)
}

render_distance_selection_line <- function(template_path,
                                           distance_name,
                                           selection1,
                                           selection2) {
  n <- max(length(distance_name), length(selection1), length(selection2))

  if (!all(length(distance_name) %in% c(1, n),
           length(selection1) %in% c(1, n),
           length(selection2) %in% c(1, n))) {
    stop("distance_name, selection1, and selection2 must be length 1 or same length")
  }

  distance_name <- rep_len(distance_name, n)
  selection1 <- rep_len(selection1, n)
  selection2 <- rep_len(selection2, n)

  invalid <- is.na(selection1) | is.na(selection2) | selection1 == "" | selection2 == ""
  if (any(invalid)) {
    stop("selection1 and selection2 must be non-empty")
  }

  purrr::map2_chr(
    .x = seq_len(n),
    .y = distance_name,
    .f = function(i, dn) {
      render_pml_template(
        template_path = template_path,
        values = list(
          distance_name = dn,
          selection1 = selection1[[i]],
          selection2 = selection2[[i]]
        )
      )
    }
  )
}

render_distance_line <- function(template_path,
                                 distance_name,
                                 obj_left,
                                 chain_left,
                                 resid_left,
                                 atom_left,
                                 obj_right,
                                 chain_right,
                                 resid_right,
                                 atom_right) {
  render_pml_template(
    template_path = template_path,
    values = list(
      distance_name = distance_name,
      obj_left = obj_left,
      chain_left = chain_left,
      resid_left = resid_left,
      atom_left = atom_left,
      obj_right = obj_right,
      chain_right = chain_right,
      resid_right = resid_right,
      atom_right = atom_right
    )
  )
}

render_alter_b_line <- function(template_path,
                                obj_name,
                                chain,
                                resid,
                                b_value) {
  b_num <- as.numeric(b_value)
  if (is.na(b_num)) {
    stop("b_value must be numeric")
  }

  render_pml_template(
    template_path = template_path,
    values = list(
      obj_name = obj_name,
      chain = chain,
      resid = resid,
      b_value = format(b_num, trim = TRUE, scientific = FALSE)
    )
  )
}
