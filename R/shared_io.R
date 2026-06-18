# ============================================================================
# SHARED I/O MODULE FOR INTERFACE ANALYSIS PIPELINE
# ============================================================================
# Purpose:
#   Centralized helpers for reading, parsing, transforming, and exporting data
#   across three parallel interface analysis workflows (Ab117, Ab321, ACE2).
#
# Main workflows supported:
#   1. PISA interface analysis: XML parsing → PyMOL scripts → BSA tables/plots
#   2. Arpeggio interaction analysis: CSV parsing → feature aggregation → plots
#   3. PyMOL selection/focus management: text selection files → structured data
#
# Dependencies: tidyverse family (dplyr, tidyr, purrr), xml2, DT, htmlwidgets,
#   plotly, ggplot2, readr, stringr, vroom
# ============================================================================

# ---- DIRECTORY & FILE MANAGEMENT ----

#' Ensure Directory Exists
#' Creates a directory recursively if it does not exist.
ensure_dir <- function(path) {
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  invisible(path)
}

ensure_obj_column <- function(df) {
  if ("obj" %in% names(df)) {
    return(df)
  }

  if (all(c("obj.x", "obj.y") %in% names(df))) {
    return(dplyr::mutate(df, obj = dplyr::coalesce(obj.x, obj.y)))
  }

  if ("obj.x" %in% names(df)) {
    return(dplyr::rename(df, obj = obj.x))
  }

  if ("obj.y" %in% names(df)) {
    return(dplyr::rename(df, obj = obj.y))
  }

  if ("obj_arpeggio" %in% names(df)) {
    return(
      df %>%
        tidyr::separate(obj_arpeggio, into = c("obj", "arpeggio_tmp"), sep = "_", remove = FALSE) %>%
        dplyr::select(!c("arpeggio_tmp"))
    )
  }

  stop("Column `obj` is not found and could not be reconstructed.")
}

# ---- PYMOL SELECTION & FOCUS FILE LOADERS ----

#' Read PyMOL Selection Files
#' Loads custom PyMOL selection files (.txt) from directory, parses chain/residue
#' format, and returns structured tibble suitable for Arpeggio input.
read_pymol_selection_files <- function(selection_dir = "./pisarp_selections/") {
  pisasel_filelist <- list.files(path = selection_dir, pattern = "*.txt")
  pisasel_filelist.dat <- data.frame(
    folder = c(rep(selection_dir, length(pisasel_filelist))),
    files = pisasel_filelist
  )
  pisasel_filelist.dat$read <- paste(pisasel_filelist.dat$folder, pisasel_filelist.dat$files, sep = "")
  pisasel_filelist.tib <- tibble::as_tibble(pisasel_filelist.dat)

  pisasel_filelist.tib %>%
    dplyr::select(files, read) %>%
    dplyr::mutate(data = purrr::map(read, ~readr::read_delim(., skip = 1, delim = " ", col_names = c("selection")))) %>%
    dplyr::mutate(data = purrr::map(data, ~tidyr::separate(., selection, into = c("pysel", "chain", "resaa", "resid"), sep = "\\\\"))) %>%
    dplyr::mutate(data = purrr::map(data, ~dplyr::mutate(., resid = as.numeric(resid)))) %>%
    tidyr::separate(files, into = c("listselection", "obj", "pisaseltxt"), sep = "_") %>%
    tidyr::separate(pisaseltxt, into = c("arpisa_sel", "txt"), sep = "\\.") %>%
    dplyr::select(., !c("listselection", "txt", "read"))
}

#' Build Arpeggio Selection Command Files
#' Converts parsed selection data into commands suitable for Arpeggio analysis.
#' Returns tibble, nested selection commands, and unnested join-ready format.
build_arpeggio_selections <- function(pisasel_filelist.tib, output_dir = "./arp_selections/") {
  arpeggio_selections.tib <- pisasel_filelist.tib %>%
    dplyr::mutate(., cmd = purrr::map(data, ~tidyr::unite(., cmd, c("chain", "resid"), sep = "/"))) %>%
    dplyr::mutate(., cmd = purrr::map(cmd, ~dplyr::mutate(., before = "/", after = "/"))) %>%
    dplyr::mutate(., cmd = purrr::map(cmd, ~tidyr::unite(., cmd, c("before", "cmd", "after"), sep = ""))) %>%
    dplyr::mutate(., cmd = purrr::map(cmd, ~dplyr::select(., cmd))) %>%
    dplyr::mutate(., filename = paste(output_dir, obj, "_", arpisa_sel, ".txt", sep = ""))

  arpeggio_selections.sel <- arpeggio_selections.tib %>%
    dplyr::select(., obj, arpeggio = arpisa_sel, cmd)

  arpeggio_selections_join <- arpeggio_selections.sel %>% tidyr::unnest(., cmd)

  list(
    arpeggio_selections.tib = arpeggio_selections.tib,
    arpeggio_selections.sel = arpeggio_selections.sel,
    arpeggio_selections_join = arpeggio_selections_join
  )
}

#' Write Arpeggio Selection Files to Disk
#' Exports selection commands as CSV files for downstream Arpeggio server input.
write_arpeggio_selection_files <- function(arpeggio_selections.tib) {
  purrr::pwalk(
    list(arpeggio_selections.tib$cmd, arpeggio_selections.tib$filename),
    ~readr::write_csv(x = ..1, file = ..2, col_names = FALSE, quote = "none")
  )
}

#' Read PyMOL Focus Files (PISA-specific regions)
#' Loads focus group definitions (CDR, FR, etc.) from PyMOL selection exports.
#' Returns tibble with obj, domain, region, and parsed residue data.
read_pymol_focus_files <- function(focus_dir = "./pisarp_focus/") {
  pisafocus_filelist <- list.files(path = focus_dir, pattern = "*.txt")
  pisafocus_filelist.dat <- data.frame(
    folder = c(rep(focus_dir, length(pisafocus_filelist))),
    files = pisafocus_filelist
  )
  pisafocus_filelist.dat$read <- paste(pisafocus_filelist.dat$folder, pisafocus_filelist.dat$files, sep = "")
  pisafocus_filelist.tib <- tibble::as_tibble(pisafocus_filelist.dat)

  pisafocus_filelist.tib %>%
    dplyr::select(files, read) %>%
    tidyr::separate(files, into = c("listselection", "obj", "pisafocustxt"), sep = "_") %>%
    tidyr::separate(pisafocustxt, into = c("arpisa_focus", "txt"), sep = "\\.") %>%
    dplyr::select(., !c("listselection", "txt")) %>%
    dplyr::mutate(data = purrr::map(read, ~readr::read_delim(., skip = 1, delim = " ", col_names = c("selection")))) %>%
    dplyr::mutate(data = purrr::map(data, ~tidyr::separate(., selection, into = c("pysel", "chain", "resaa", "resid"), sep = "\\\\"))) %>%
    dplyr::mutate(data = purrr::map(data, ~dplyr::mutate(., resid = as.numeric(resid))))
}

#' Build Focus Selection Command Files
#' Converts focus data into nested command format and unnested join-ready tibble.
#' Separates domain/region into distinct columns for downstream merging.
build_focus_selections <- function(pisafocus_filelist.tib, output_dir = "./arpisa_focus/") {
  pisafocus_selections.tib <- pisafocus_filelist.tib %>%
    dplyr::mutate(., cmd = purrr::map(data, ~tidyr::unite(., cmd, c("chain", "resid"), sep = "/"))) %>%
    dplyr::mutate(., cmd = purrr::map(cmd, ~dplyr::mutate(., before = "/", after = "/"))) %>%
    dplyr::mutate(., cmd = purrr::map(cmd, ~tidyr::unite(., cmd, c("before", "cmd", "after"), sep = ""))) %>%
    dplyr::mutate(., cmd = purrr::map(cmd, ~dplyr::select(., cmd))) %>%
    dplyr::mutate(., filename = paste(output_dir, obj, "_", arpisa_focus, ".txt", sep = ""))

  pisafocus_selections.sel <- pisafocus_selections.tib %>%
    dplyr::select(., obj, pisafocus = arpisa_focus, cmd)

  pisafocus_selections_join <- pisafocus_selections.sel %>%
    tidyr::unnest(., cmd) %>%
    tidyr::separate(., pisafocus, into = c("domain", "region"))

  list(
    pisafocus_selections.tib = pisafocus_selections.tib,
    pisafocus_selections.sel = pisafocus_selections.sel,
    pisafocus_selections_join = pisafocus_selections_join
  )
}

# ---- PISA DATA PARSING ----

#' Extract Data from PISA XML
#' Generic XML navigation and text extraction helper for nested PISA structures.
pisa_xml_extract <- function(df, children1, children2, children3) {
  if (children3 == "NONE") {
    df_out <- df %>%
      xml2::xml_find_all(children1) %>%
      xml2::xml_find_all(children2) %>%
      xml2::xml_text(trim = TRUE) %>%
      tibble::as_tibble()
  } else {
    df_out <- df %>%
      xml2::xml_find_all(children1) %>%
      xml2::xml_find_all(children2) %>%
      xml2::xml_find_all(children3) %>%
      xml2::xml_text(trim = TRUE) %>%
      tibble::as_tibble()
  }

  df_out
}

#' Get PISA XML Schema Mapping
#' Returns tribble describing which XML elements contain residue BSA/ASA data.
#' Used by read_pisa_interface_data to extract hydrogenbonds, residues, saltbridges.
get_pisa_xml_schema <- function() {
  tibble::tribble(
    ~heading, ~children1, ~children2, ~children3,
    "HYDROGENBONDS", list("STRUCTURE"), list("STRUCTURE1", "DISTANCE", "STRUCTURE2"), list("NONE"),
    "RESIDUES", list("RESIDUE1", "RESIDUE2"), list("RESIDUE"), list("STRUCTURE", "BURIEDSURFACEAREA"),
    "RESIDUES", list("RESIDUE1", "RESIDUE2"), list("RESIDUE"), list("SOLVENTACCESSIBLEAREA"),
    "SALTBRIDGES", list("STRUCTURE"), list("STRUCTURE1", "DISTANCE", "STRUCTURE2"), list("NONE")
  ) %>%
    tidyr::unnest(children1) %>%
    tidyr::unchop(children1) %>%
    tidyr::unnest(children2) %>%
    tidyr::unchop(children2) %>%
    tidyr::unnest(children3) %>%
    tidyr::unchop(children3)
}

#' Read and Parse PISA Interface Data from XML
#' Main PISA parser: reads XML → extracts residue BSA/ASA → joins with Arpeggio
#' selections → returns long-form residue-level interface data with PyMOL commands.
read_pisa_interface_data <- function(pisa_dir = "./data_pisa", arpeggio_selections_join) {
  pisa_xml_tribble <- get_pisa_xml_schema()

  pisa_filelist <- list.files(
    path = pisa_dir,
    pattern = "*",
    recursive = TRUE,
    include.dirs = TRUE,
    full.names = TRUE
  )

  pisa_filelist.tib <- tibble::as_tibble(pisa_filelist) %>%
    dplyr::mutate(data = purrr::map(value, ~xml2::read_xml(.))) %>%
    dplyr::mutate(pisatype = "interface") %>%
    dplyr::mutate(
      heading = dplyr::case_when(
        pisatype == "hbonds" ~ "HYDROGENBONDS",
        pisatype == "interface" ~ "RESIDUES",
        pisatype == "sbridge" ~ "SALTBRIDGES",
        TRUE ~ "NONE"
      )
    ) %>%
    dplyr::left_join(pisa_xml_tribble, by = "heading") %>%
    dplyr::mutate(xml_xtract = purrr::pmap(list(data, children1, children2, children3), pisa_xml_extract))

  pisa_filelist_long <- pisa_filelist.tib %>%
    tidyr::separate(value, c("dot", "folder", "filename"), sep = "/") %>%
    dplyr::select(!c("dot", "folder")) %>%
    tidyr::separate(filename, c("obj", "pair", "rm"), sep = "_") %>%
    dplyr::select(!c("rm")) %>%
    dplyr::select(obj, pair, pisatype, heading, children1, children2, children3, xml_xtract) %>%
    dplyr::group_by(obj, pair, pisatype, heading, children1) %>%
    tidyr::nest() %>%
    dplyr::mutate(data_wide = purrr::map(data, ~tidyr::pivot_wider(., names_from = c(children2, children3), values_from = xml_xtract, names_sep = "_"))) %>%
    dplyr::mutate(data_wide_unnested = purrr::map(data_wide, ~tidyr::unchop(., cols = c(1:ncol(.))))) %>%
    dplyr::select(-data, -data_wide) %>%
    dplyr::mutate(data_unnested = purrr::map(data_wide_unnested, ~tidyr::unnest(.))) %>%
    dplyr::mutate(data_unnested = purrr::map(data_unnested, ~dplyr::select(., resid = value, bsa = value1, asa = value2))) %>%
    dplyr::select(-data_wide_unnested) %>%
    tidyr::unnest(data_unnested) %>%
    tidyr::separate(resid, into = c("chain", "resid"), sep = ":") %>%
    dplyr::mutate(resno = stringr::str_extract(resid, "[:digit:]{1,3}"), resaa = stringr::str_extract(resid, "[:alpha:]{1,3}")) %>%
    dplyr::mutate(bsa = as.numeric(bsa), asa = as.numeric(asa), resno = as.numeric(resno)) %>%
    dplyr::mutate(bsa_perc = (bsa / asa) * 100) %>%
    dplyr::mutate(bsa_perc = round(bsa_perc, 0)) %>%
    tidyr::replace_na(list(bsa_perc = 0)) %>%
    dplyr::ungroup() %>%
    dplyr::select(!c(heading, children1, pisatype)) %>%
    dplyr::select(obj, pair, chain, resno, resaa, asa, bsa, bsa_perc) %>%
    dplyr::group_by(obj, pair) %>%
    tidyr::nest() %>%
    dplyr::select(obj, pair, pisa = data) %>%
    tidyr::unnest(pisa) %>%
    dplyr::ungroup() %>%
    dplyr::group_by(obj, chain, resno, resaa) %>%
    tidyr::nest() %>%
    dplyr::mutate(data_sum = purrr::map(data, ~dplyr::summarize(., asa_mean = mean(asa), bsa_sum = sum(bsa), bsa_perc_sum = sum(bsa_perc)))) %>%
    tidyr::unnest(data_sum) %>%
    dplyr::mutate(cmd = paste("/", chain, "/", resno, "/", sep = ""))

  pisa_filelist_long %>%
    dplyr::left_join(arpeggio_selections_join) %>%
    dplyr::filter(bsa_sum > 0)
}

#' Build PISA PyMOL Scripts
#' Generates PyMOL alter-B-factor commands using template renderer.
#' One script per obj/arpeggio pair, writes .pml files to disk.
build_pisa_pymol_scripts <- function(pisa_filelist_long_pymol,
                                     template_path = "../pml_templates/alter_b_line.pmltpl",
                                     output_dir = "./pyscripts/") {
  ensure_dir(output_dir)

  pisa_filelist_long_sel.pymol <- pisa_filelist_long_pymol %>%
    dplyr::select(!c("data")) %>%
    dplyr::mutate(obj_pisa = paste(obj, "_PISA_", arpeggio, sep = "")) %>%
    dplyr::group_by(obj, arpeggio) %>%
    tidyr::nest() %>%
    dplyr::mutate(
      pymol_cmd = purrr::map(
        data,
        ~purrr::pmap_chr(
          list(
            obj_pisa = .x$obj_pisa,
            chain = .x$chain,
            resno = .x$resno,
            bsa_perc_sum = .x$bsa_perc_sum
          ),
          function(obj_pisa, chain, resno, bsa_perc_sum) {
            render_alter_b_line(
              template_path = template_path,
              obj_name = obj_pisa,
              chain = chain,
              resid = resno,
              b_value = bsa_perc_sum
            )
          }
        )
      )
    ) %>%
    dplyr::mutate(pathname = paste(output_dir, "pisa_bsa_", obj, "_", arpeggio, ".pml", sep = ""))

  writer <- if (exists("write_pml_lines", mode = "function")) {
    write_pml_lines
  } else {
    function(lines, pathname) {
      readr::write_lines(lines, file = pathname)
    }
  }

  purrr::pwalk(
    list(pisa_filelist_long_sel.pymol$pymol_cmd, pisa_filelist_long_sel.pymol$pathname),
    writer
  )

  pisa_filelist_long_sel.pymol
}

#' Export PISA Interface Data as Interactive HTML Table
#' Converts long-form PISA residue data to DT::datatable widget and saves as HTML.
write_pisa_interface_table <- function(pisa_filelist_long_pymol,
                                       output_file = "table_pisa.html",
                                       filter = "top",
                                       selfcontained = TRUE) {
  pisa_filelist_long.tab <- pisa_filelist_long_pymol %>%
    dplyr::select(!c("data"))

  table_widget <- DT::datatable(pisa_filelist_long.tab, filter = filter)
  htmlwidgets::saveWidget(table_widget, file = output_file, selfcontained = selfcontained)

  table_widget
}

# ---- PISA REGION MERGING & SUMMARIZATION ----

#' Split Values into Unit Chunks
#' Utility function for creating stacked bar plots: splits large BSA values
#' into fixed-size units (e.g., 50 Ångström blocks) for visualization.
split_value_f <- function(value, unit) {
  if (value == 0) {
    return(tibble::tibble(unit_value = 0, part = 1))
  }

  if (value < unit) {
    return(tibble::tibble(unit_value = value, part = 1))
  }

  full_units <- value %/% unit
  remainder <- value %% unit

  units_df <- tibble::tibble(
    unit_value = rep(unit, full_units),
    part = seq_len(full_units)
  )

  if (remainder > 0) {
    units_df <- dplyr::bind_rows(
      units_df,
      tibble::tibble(unit_value = remainder, part = full_units + 1)
    )
  }

  units_df
}

#' Read Reference PISA Focus Selections
#' Loads pre-computed focus selections (e.g., ACE2 reference) for comparison/overlay.
read_reference_pisafocus_selections <- function(path = "../",
                                                pattern = "ref_pisafocus_selections_join.rds") {
  ref_pisafocus_list <- list.files(
    path = path,
    pattern = pattern,
    recursive = TRUE,
    include.dirs = TRUE,
    full.names = TRUE
  )

  ref_pisafocus_list.tib <- tibble::as_tibble(ref_pisafocus_list) %>%
    tidyr::separate(value, into = c("dot", "empty", "foldername", "plotname"), sep = "\\/", remove = FALSE) %>%
    dplyr::select(!c("dot", "empty")) %>%
    tidyr::separate(foldername, into = c("NBIS", "pre", "Name", "Date", "sample"), sep = "_") %>%
    dplyr::select(value, sample, plotname) %>%
    dplyr::mutate(plottype = stringr::str_remove(plotname, "\\.rds")) %>%
    dplyr::select(!c("plotname")) %>%
    dplyr::mutate(data = purrr::map(value, ~readRDS(.))) %>%
    dplyr::select(!c("value"))

  ref_pisafocus_list.tib %>%
    tidyr::unnest(data) %>%
    dplyr::select(!c("sample", "plottype"))
}

#' Merge PISA Data with Focus Region Definitions
#' Joins residue-level PISA BSA with domain/region labels (CDR, FR, etc).
#' Supports two modes: default (coalesce domains) and ace2 (reference-based).
merge_pisa_focus_regions <- function(pisa_filelist_long_pymol,
                                     ref_pisafocus_selections_join,
                                     pisafocus_selections_join,
                                     mode = c("default", "ace2")) {
  mode <- match.arg(mode)

  noref_pisafocus_selections_join <- pisafocus_selections_join %>%
    dplyr::filter(obj != "OBJ00")

  pisa_filelist_long_sel <- pisa_filelist_long_pymol %>%
    dplyr::left_join(ref_pisafocus_selections_join) %>%
    dplyr::left_join(noref_pisafocus_selections_join, by = c("obj", "cmd")) %>%
    dplyr::mutate(domain = dplyr::coalesce(domain.x, domain.y), region = dplyr::coalesce(region.x, region.y)) %>%
    dplyr::select(!c("domain.x", "domain.y", "region.x", "region.y"))

  if (mode == "ace2") {
    return(
      pisa_filelist_long_sel %>%
        tidyr::replace_na(list(domain = "other", region = "other")) %>%
        dplyr::select(!c("domain")) %>%
        dplyr::mutate(region_col = dplyr::case_when((region == "other" & arpeggio == "AB1") ~ "FR", TRUE ~ region))
    )
  }

  pisa_filelist_long_sel %>%
    dplyr::mutate(domain_mod = dplyr::coalesce(domain, arpeggio)) %>%
    dplyr::mutate(region_col = dplyr::coalesce(region, domain_mod)) %>%
    dplyr::select(!c("domain", "domain_mod"))
}

#' Summarize PISA BSA by Region
#' Aggregates residue-level BSA into region (domain/CDR/FR) totals per chain.
#' Applies chain_adjustements config for consistent naming across object types.
summarize_pisa_regions <- function(pisa_filelist_long_sel, chain_adjustements) {
  pisa_filelist_long_sel %>%
    dplyr::group_by(obj, arpeggio, chain, region_col) %>%
    dplyr::summarize(bsa_sum = sum(bsa_sum), .groups = "drop") %>%
    dplyr::left_join(chain_adjustements, by = c("obj", "arpeggio", "chain")) %>%
    dplyr::mutate(chain_adj = dplyr::coalesce(chain_adj, chain)) %>%
    dplyr::select(obj, arpeggio, chain = chain_adj, region_col, bsa_sum)
}

#' Compute PISA Region Statistics
#' Calculates percentages: BSA per chain, per region of total arpeggio BSA.
#' Returns hierarchically aggregated statistics for tabular export.
compute_pisa_region_stats <- function(pisa_filelist_long_sel_regionsum) {
  pisa_filelist_long_sel_resP_chain.stats <- pisa_filelist_long_sel_regionsum %>%
    dplyr::ungroup() %>%
    dplyr::group_by(obj, arpeggio, chain, region_col) %>%
    dplyr::summarize(bsa_region_chain = sum(bsa_sum), .groups = "drop") %>%
    dplyr::group_by(obj, arpeggio, chain) %>%
    dplyr::mutate(bsa_arpeggio = sum(bsa_region_chain)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(bsa_perc_chain = round((bsa_region_chain / bsa_arpeggio) * 100, 1))

  pisa_filelist_long_sel_resP_chain.stats %>%
    dplyr::group_by(obj, arpeggio, region_col) %>%
    dplyr::summarize(bsa_arp_chain = sum(bsa_arpeggio), .groups = "drop") %>%
    dplyr::right_join(
      pisa_filelist_long_sel_resP_chain.stats,
      by = c("obj", "arpeggio", "region_col")
    ) %>%
    dplyr::mutate(bsa_perc_region = round((bsa_region_chain / bsa_arp_chain) * 100, 1)) %>%
    dplyr::arrange(obj, arpeggio, chain, region_col)
}

#' Export PISA Region Statistics as HTML Table
#' Exports computed region stats to interactive DT::datatable widget and saves HTML.
write_pisa_stats_table <- function(pisa_filelist_long_sel_resP.stats,
                                   output_file = "table_pisastats.html",
                                   filter = "top",
                                   selfcontained = TRUE) {
  table_widget <- DT::datatable(pisa_filelist_long_sel_resP.stats, filter = filter)
  htmlwidgets::saveWidget(table_widget, file = output_file, selfcontained = selfcontained)
  table_widget
}

# ---- GENERIC EXPORT HELPERS ----

#' Export Data Frame as Interactive HTML DataTable
#' Generic wrapper for DT::datatable with htmlwidgets export to self-contained HTML.
write_datatable_html <- function(data,
                                 output_file,
                                 filter = "top",
                                 selfcontained = TRUE) {
  table_widget <- DT::datatable(data, filter = filter)
  htmlwidgets::saveWidget(table_widget, file = output_file, selfcontained = selfcontained)
  table_widget
}

#' Export ggplot as Interactive HTML Plotly Widget
#' Converts ggplot2 object to interactive plotly widget and saves as HTML.
write_ggplotly_html <- function(plot_obj,
                                output_file,
                                selfcontained = TRUE) {
  plotly_widget <- plotly::ggplotly(plot_obj)
  htmlwidgets::saveWidget(plotly_widget, file = output_file, selfcontained = selfcontained)
  plotly_widget
}

# ---- ARPEGGIO DATA PROCESSING ----

#' Build Arpeggio PyMOL Export Scripts
#' Processes atom-level Arpeggio contact data into two PyMOL scripts:
#'   - .pml: main contacts (excluding Proximal interactions)
#'   - _tune.pml: refined/selected interactions via tune_contacts_fn callback
#' Supports custom contact filtering via generate_contacts_fn parameter.
build_arpeggio_pymol_exports <- function(pdbsum_filelist_atomlevel.tib,
                                         generate_contacts_fn,
                                         tune_contacts_fn,
                                         output_dir = "./pyscripts/") {
  ensure_dir(output_dir)

  pdbsum_filelist_atomlevel_pre.pyscript <- pdbsum_filelist_atomlevel.tib %>%
    tidyr::separate(obj_arpeggio, into = c("obj", "arpeggio"), sep = "_", remove = FALSE) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(selection1 = paste(obj, " and ", id1, sep = ""), selection2 = paste(obj, " and ", id2, sep = "")) %>%
    dplyr::mutate(arpeggio_sel = arpeggio) %>%
    dplyr::group_by(obj, arpeggio_sel) %>%
    tidyr::nest() %>%
    dplyr::mutate(arp_sorted = purrr::pmap(list(data, arpeggio_sel), generate_contacts_fn))

  pdbsum_filelist_atomlevel.pyscript <- pdbsum_filelist_atomlevel_pre.pyscript %>%
    dplyr::mutate(filename = paste(output_dir, obj, "_", arpeggio_sel, ".pml", sep = "")) %>%
    dplyr::mutate(arp_filtered = purrr::map(arp_sorted, ~dplyr::filter(., name != "Proximal"))) %>%
    dplyr::mutate(cmd_sel = purrr::map(arp_filtered, ~dplyr::select(., cmd)))

  writer <- if (exists("write_csv_pymol_f", mode = "function")) {
    write_csv_pymol_f
  } else {
    function(data, pathname) {
      readr::write_csv(x = data, file = pathname, col_names = FALSE, quote = "none")
    }
  }

  purrr::pwalk(
    list(pdbsum_filelist_atomlevel.pyscript$cmd_sel, pdbsum_filelist_atomlevel.pyscript$filename),
    writer
  )

  pdbsum_filelist_tune.pyscript <- pdbsum_filelist_atomlevel.pyscript %>%
    dplyr::select(!c("filename", "cmd_sel")) %>%
    dplyr::mutate(cmd_sel = purrr::map(arp_filtered, tune_contacts_fn)) %>%
    dplyr::mutate(filename = paste(output_dir, obj, "_", arpeggio_sel, "_tune.pml", sep = ""))

  purrr::pwalk(
    list(pdbsum_filelist_tune.pyscript$cmd_sel, pdbsum_filelist_tune.pyscript$filename),
    writer
  )

  list(
    pdbsum_filelist_atomlevel_pre.pyscript = pdbsum_filelist_atomlevel_pre.pyscript,
    pdbsum_filelist_atomlevel.pyscript = pdbsum_filelist_atomlevel.pyscript,
    pdbsum_filelist_tune.pyscript = pdbsum_filelist_tune.pyscript
  )
}

#' Save Plot as Both JPEG and PostScript
#' Exports ggplot2 object as dual-format (JPEG + PS) for archival and printing.
save_plot_jpeg_ps <- function(plot_obj,
                              file_stem,
                              width,
                              height,
                              units = "mm") {
  ggplot2::ggsave(
    file = paste0(file_stem, ".jpeg"),
    plot = plot_obj,
    device = "jpeg",
    width = width,
    height = height,
    units = units
  )

  ggplot2::ggsave(
    file = paste0(file_stem, ".ps"),
    plot = plot_obj,
    device = "ps",
    width = width,
    height = height,
    units = units
  )
}

#' Process Full Arpeggio Data Transformation Pipeline
#' Central aggregation helper: transforms raw Arpeggio contact data into seven
#' output tibbles:
#'   - levels: base summary used by downstream transformations
#'   - atomlevel: per-atom contact aggregation
#'   - reslevel: per-residue contact summary
#'   - liglevel: per-ligand averaged summary
#'   - feature_contacts*: chain/residue/contact-level frequency tables
#' Requires helper functions arpeggio_atomlevel_f, arpeggio_reslevel_f, liglevel_f.
process_arpeggio_pipeline <- function(pdbsum_filelist.tib,
                                      PDBsum_sort_tribble,
                                      arpfeature_tib,
                                      arpeggio_chain_filter) {
  pdbsum_filelist_levels.tib <- pdbsum_filelist.tib %>%
    dplyr::select(obj, arpeggio, data_boxplot) %>%
    tidyr::unite(obj_arpeggio, c("obj", "arpeggio")) %>%
    dplyr::mutate(data_atomlevel = purrr::map(data_boxplot, ~arpeggio_atomlevel_f(.))) %>%
    dplyr::mutate(data_reslevel = purrr::map(data_atomlevel, ~arpeggio_reslevel_f(.))) %>%
    dplyr::mutate(data_liglevel = purrr::map(data_reslevel, ~arpeggio_liglevel_f(.)))

  pdbsum_filelist_atomlevel.tib <- pdbsum_filelist_levels.tib %>%
    dplyr::select(obj_arpeggio, data_atomlevel) %>%
    tidyr::unnest(c("data_atomlevel"))

  pdbsum_filelist_reslevel.tib <- pdbsum_filelist_levels.tib %>%
    dplyr::select(obj_arpeggio, data_reslevel) %>%
    tidyr::unnest(c("data_reslevel"))

  pdbsum_filelist_liglevel.tib <- pdbsum_filelist_levels.tib %>%
    dplyr::select(obj_arpeggio, data_liglevel) %>%
    tidyr::unnest(c("data_liglevel"))

  feature_contacts.tib <- pdbsum_filelist.tib %>%
    dplyr::select(obj, arpeggio, filetype, data_long2) %>%
    tidyr::unnest(data_long2) %>%
    dplyr::select(!data_ranked) %>%
    tidyr::unnest(data) %>%
    dplyr::group_by(obj, arpeggio, chain1, ranktype, name) %>%
    dplyr::tally(name = "sumcount") %>%
    dplyr::left_join(arpfeature_tib, by = c("ranktype", "name")) %>%
    tidyr::replace_na(list(arpclass = "strong"))

  feature_contacts_residue.tib <- pdbsum_filelist.tib %>%
    dplyr::select(obj, arpeggio, filetype, data_long2) %>%
    tidyr::unnest(data_long2) %>%
    dplyr::select(!data_ranked) %>%
    tidyr::unnest(data) %>%
    dplyr::group_by(obj, arpeggio, chain1, number1, ranktype, name) %>%
    dplyr::tally(name = "sumcount") %>%
    dplyr::left_join(arpfeature_tib, by = c("ranktype", "name")) %>%
    tidyr::replace_na(list(arpclass = "strong"))

  feature_contacts_contact.map <- pdbsum_filelist.tib %>%
    dplyr::select(obj, arpeggio, filetype, data_long2) %>%
    tidyr::unnest(data_long2) %>%
    dplyr::select(!data_ranked) %>%
    tidyr::unnest(data) %>%
    dplyr::left_join(arpeggio_chain_filter, by = c("obj", "chain1")) %>%
    ensure_obj_column() %>%
    dplyr::filter(!is.na(keep)) %>%
    dplyr::select(!c("keep")) %>%
    dplyr::group_by(obj, arpeggio, chain1, number1, chain2, number2, ranktype, name) %>%
    dplyr::tally(name = "sumcount") %>%
    dplyr::left_join(arpfeature_tib, by = c("ranktype", "name")) %>%
    tidyr::replace_na(list(arpclass = "strong"))

  list(
    pdbsum_filelist_levels.tib = pdbsum_filelist_levels.tib,
    pdbsum_filelist_atomlevel.tib = pdbsum_filelist_atomlevel.tib,
    pdbsum_filelist_reslevel.tib = pdbsum_filelist_reslevel.tib,
    pdbsum_filelist_liglevel.tib = pdbsum_filelist_liglevel.tib,
    feature_contacts.tib = feature_contacts.tib,
    feature_contacts_residue.tib = feature_contacts_residue.tib,
    feature_contacts_contact.map = feature_contacts_contact.map
  )
}
