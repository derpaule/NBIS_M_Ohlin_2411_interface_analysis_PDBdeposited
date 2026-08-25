# Shared helper functions used across the interface analysis notebooks.
# Source this after shared_config.R and shared_io.R.

write_csv_pymol_f <- function(data, pathname) {
  df_out <- readr::write_csv(x = data, file = pathname, col_names = FALSE, quote = "none")
  return(df_out)
}

combine_plots_f <- function(data) {
  data_out <- data %>% tidyr::pivot_wider(., names_from = "sample", values_from = "plotted")
  return(data_out)
}

pisa_xml_xtract_f <- function(df, children1, children2, children3) {
  if (children3 == "NONE") {
    df_out <- df %>% xml2::xml_find_all(., children1) %>% xml2::xml_find_all(., children2) %>% xml2::xml_text(., trim = TRUE) %>% tibble::as_tibble(.)
  } else {
    df_out <- df %>% xml2::xml_find_all(., children1) %>% xml2::xml_find_all(., children2) %>% xml2::xml_find_all(., children3) %>% xml2::xml_text(., trim = TRUE) %>% tibble::as_tibble(.)
  }
  return(df_out)
}

pisa_summarize_f <- function(df) {
  df_out <- df %>% dplyr::mutate(., object = stringr::str_extract(pyname, "MHCh1|MHCh2|PEP")) %>% dplyr::group_by(object, chain, resno, resaa) %>% dplyr::summarize(., asa = max(asa), bsa = sum(bsa)) %>% dplyr::mutate(., bsa_perc = (bsa / asa) * 100) %>% dplyr::mutate(., bsa_perc = round(bsa_perc, 0))
  return(df_out)
}

# split_value_f lives in shared_io.R (PISA region merging & summarization section).

read_tsv_pdbsum_f <- function(file, col_names) {
  col_names_vec <- col_names %>% dplyr::select(., PDBres) %>% dplyr::pull()
  pdbsum_data <- vroom::vroom(file = file, col_names = col_names_vec)
  return(pdbsum_data)
}

test_ligchain_f <- function(chain1, lig_chain) {
  case_when()
}

# Arpeggio
## Tribbles
PDBsum_sort_tribble <- tribble(~no_col, ~named_col, ~filetype,
                        17, enframe( c("id1", "id2","Clash", "Covalent", "vdW_Clash", "VdW", "Proximal", "HydrogenBond","weakHydrogenBond", "HalogenBond", "Ionic", "MetalComplex", "Aromatic", "Hydrophobic", "Carbonyl", "Polar", "WeakPolar", "ENTITIES"), value = "PDBres"), "contacts"
                        )

PDBsum_rank_tribble <- PDBsum_sort_tribble %>% dplyr::select(., named_col) %>% unnest(., named_col) %>% dplyr::slice(., 3:17) %>% dplyr::select(., PDBres) %>% add_column(., rank = c(1, 2, 1, 1, 1, 3, 1, 3, 4, 3, 3, 2, 1, 2, 1)) %>% add_column(., ranktype = c("distance", "distance", "distance", "distance", "distance", "polar", "distance", "polar", "polar", "polar", "nonpolar", "nonpolar", "polar", "polar", "distance")) %>% dplyr::select(., name = PDBres, rank, ranktype)

## Functions
analyze_arpeggio_f <- function(data) {
  data_out <- data %>% dplyr::left_join(., PDBsum_rank_tribble) %>% dplyr::group_by(., id1, atom1, id2, atom2) %>% tidyr::nest() %>% dplyr::mutate(., data_ranked = purrr::map(data, ~dplyr::filter(., rank == max(rank)))) %>% dplyr::mutate(., ncolumn = purrr::map(data, ~nrow(.))) %>% tidyr::unchop(., ncolumn)
  return(data_out)
}

arpeggio_chainsort_f <- function(data, sel_chain) {
  sel_chain_letter <- sel_chain[[1]]
  data_out <- data %>% tidyr::separate(., id1, c("chain1", "number1", "atom1"), sep = "\\/", remove = FALSE) %>% tidyr::separate(., id2, c("chain2", "number2", "atom2"), sep = "\\/", remove = FALSE) %>% dplyr::mutate(., id1_corr = case_when(chain1 == sel_chain_letter ~ id1, TRUE ~ id2), id2_corr = case_when(chain2 == sel_chain_letter ~ id1, TRUE ~ id2)) %>% dplyr::select(., -id1, -chain1, -number1, -atom1, -id2, -chain2, -number2, -atom2) %>% tidyr::separate(., id1_corr, c("chain1", "number1", "atom1"), sep = "\\/", remove = FALSE) %>% tidyr::separate(., id2_corr, c("chain2", "number2", "atom2"), sep = "\\/", remove = FALSE)
  return(data_out)
}

arpeggio_id_f <- function(data) {
  data1 <- data
  data2 <- data %>% dplyr::select(., id1 = id2, id2 = id1, ENTITIES, name, value)
  data_out <- dplyr::full_join(data1, data2) %>% tidyr::separate(., id1, c("chain1", "number1", "atom1"), sep = "\\/", remove = FALSE) %>% tidyr::separate(., id2, c("chain2", "number2", "atom2"), sep = "\\/", remove = FALSE) %>% dplyr::mutate(., cmd = paste("/", chain1, "/", number1, "/", sep = ""))
  return(data_out)
}

arpeggio_sort_f <- function(data) {
  data_out <- data %>% dplyr::mutate(., nrows = purrr::map(data_ranked, ~nrow(.))) %>% tidyr::unnest(nrows) %>% dplyr::ungroup() %>% dplyr::select(., -data) %>% tidyr::unnest(data_ranked) %>% dplyr::group_by(id1, id2) %>% tidyr::nest()
  return(data_out)
}

arpeggio_sum_f <- function(data) {
  data_out <- data %>% dplyr::mutate(., data_filtered = purrr::map(data, ~dplyr::filter(., rank == max(rank), ranktype != "distance"))) %>% dplyr::mutate(., data_sum = purrr::map(data_filtered, ~dplyr::reframe(., interaction_type = unique(name))))
  return(data_out)
}

arpeggion_rescount_f <- function(data) {
  data_out <- data %>% dplyr::select(., number1, number2, data) %>% tidyr::unnest(., cols = c("data")) %>% dplyr::group_by(., lig_chain, number1, rec_chain, number2, ranktype, name) %>% dplyr::summarize(., count = n())
  return(data_out)
}

arpeggio_atomlevel_f <- function(data) {
  data_out <- data %>% dplyr::select(., !c("data_filtered", "data_sum")) %>% tidyr::unnest(., c("data")) %>% dplyr::mutate(., name_cor = case_when(name == "VdW" ~ "Proximal", name == "vdW_Clash" ~ "Proximal", TRUE ~ name)) %>% dplyr::select(., !c("name")) %>% dplyr::mutate(., name = name_cor)
  return(data_out)
}

arpeggio_reslevel_f <- function(data) {
  data_out <- data %>% dplyr::group_by(., chain1, number1, ranktype, name) %>% dplyr::summarize(., count = n())
  return(data_out)
}

arpeggio_liglevel_f <- function(data) {
  data_out <- data %>% dplyr::ungroup() %>% dplyr::group_by(., chain1, number1, name) %>% dplyr::summarize(sumcount = sum(count))
  return(data_out)
}

arpeggio_object.trib <- tibble::tribble(
  ~obj_arpeggio, ~obj_new,
  "OBJ00_AB1", "OBJ00_ARP",
  "OBJ01_AB1", "OBJ01_ARP"
)

generate_arpeggio_contacts_f <- function(data, arpeggio_sel) {
  data_in <- data %>% dplyr::filter(., arpeggio == {{arpeggio_sel}})
  data_proximal <- data_in %>% dplyr::filter(., name == "Proximal") %>% dplyr::mutate(., rowid = row_number()) %>% dplyr::mutate(., cmd = render_distance_selection_line(template_path = "../pml_templates/distance_selection_line.pmltpl", distance_name = paste(obj_arpeggio, "_ prox_", rowid, sep = ""), selection1 = selection1, selection2 = selection2))
  data_hydrophobic <- data_in %>% dplyr::filter(., name == "Aromatic" | name == "Hydrophobic") %>% dplyr::mutate(., rowid = row_number()) %>% dplyr::mutate(., rowid = row_number()) %>% dplyr::mutate(., cmd = render_distance_selection_line(template_path = "../pml_templates/distance_selection_line.pmltpl", distance_name = paste(obj_arpeggio, "_hphobic_", rowid, sep = ""), selection1 = selection1, selection2 = selection2))
  data_hb <- data_in %>% dplyr::filter(., name == "HydrogenBond" | name == "Ionic") %>% dplyr::mutate(., rowid = row_number()) %>% dplyr::mutate(., cmd = render_distance_selection_line(template_path = "../pml_templates/distance_selection_line.pmltpl", distance_name = paste(obj_arpeggio, "_hbond_", chain1, number1, chain2, number2, "_", rowid, sep = ""), selection1 = selection1, selection2 = selection2))
  data_out <- data_proximal %>% dplyr::bind_rows(., data_hydrophobic) %>% dplyr::bind_rows(., data_hb)
  return(data_out)
}

tune_arpeggio_contacts_f <- function(data) {
  data_out <- data %>% dplyr::select(., c("obj_arpeggio", "chain1", "number1", "chain2", "number2")) %>% tidyr::unite(., "chainnum1", c("chain1", "number1"), sep = "_") %>% tidyr::unite(., "chainnum2", c("chain2", "number2"), sep = "_") %>% tidyr::pivot_longer(., cols = c("chainnum1", "chainnum2")) %>% dplyr::select(., !c("name")) %>% dplyr::group_by(., obj_arpeggio) %>% dplyr::reframe(., res_sel = unique(value)) %>% tidyr::separate(., "res_sel", into = c("chain", "resi"), sep = "_") %>% dplyr::mutate(., cmd_resi = paste("(chain ", chain, " and resi ", resi, ")", sep = "")) %>% dplyr::select(., !c("chain", "resi")) %>% dplyr::reframe(., obj_arpeggio = unique(obj_arpeggio), cmd_resi = paste(cmd_resi, collapse = " or ")) %>% dplyr::left_join(., arpeggio_object.trib) %>% dplyr::mutate(., cmd = paste("select ", obj_new, "_show, ", obj_new, " and (", cmd_resi, ")", sep = "")) %>% dplyr::select(., c("cmd"))
  return(data_out)
}

