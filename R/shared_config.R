get_aa_tribble <- function() {
  tibble::tribble(
    ~resaa, ~resa, ~PIC_type, ~AAcolor,
    "GLY", "G", "Hydrophobic", "NPA",
    "ALA", "A", "Hydrophobic", "NPA",
    "PRO", "P", "Hydrophobic", "NPA",
    "VAL", "V", "Hydrophobic", "NPA",
    "LEU", "L", "Hydrophobic", "NPA",
    "ILE", "I", "Hydrophobic", "NPA",
    "MET", "M", "Hydrophobic", "NPA",
    "PHE", "F", "Aromatic", "NPP",
    "TYR", "Y", "Aromatic", "NPP",
    "TRP", "W", "Aromatic", "NPP",
    "SER", "S", "HydrogenBond", "PU",
    "THR", "T", "HydrogenBond", "PU",
    "CYS", "C", "HydrogenBond", "PU",
    "ASN", "N", "HydrogenBond", "PU",
    "GLN", "Q", "HydrogenBond", "PU",
    "LYS", "K", "Ionic", "POS",
    "ARG", "R", "Ionic", "POS",
    "HIS", "H", "Ionic", "POS",
    "ASP", "D", "Ionic", "NEG",
    "GLU", "E", "Ionic", "NEG"
  )
}

get_chain_adjustements <- function() {
  tibble::tribble(
    ~obj, ~arpeggio, ~chain, ~chain_adj,
    "OBJ00", "AB1", "D", "H",
    "OBJ01", "AB1", "L", "L",
    "OBJ01", "AB1", "H", "H"
  )
}

get_base_region_colors <- function() {
  # Shared (default) color palette for Ab-based projects (ab117, ab321)
  tibble::tribble(
    ~name, ~value,
    "CDR1", "#FFFF8F",
    "CDR2", "#FBC97D",
    "CDR3", "#ECB1CD",
    "ACE", "#0035D6",
    "other", "#FFFFFF",
    "SPIKE", "#FFFFFF",
    "FR", "#96D096",
    "AB1", "#96D096"
  )
}

get_ace2_region_colors <- function() {
  # ACE2-specific palette (excludes SPIKE/AB1, uses ACEb instead of ACE)
  tibble::tribble(
    ~name, ~value,
    "CDR1", "#FFFF8F",
    "CDR2", "#FBC97D",
    "CDR3", "#ECB1CD",
    "ACEb", "#5353ffff",
    "other", "#FFFFFF",
    "FR", "#96D096"
  )
}

get_project_config <- function(project_key) {
  key <- tolower(project_key)

  # Base protein definition shared by ab117 and ab321
  configs <- list(
    ab117 = list(
      region_colors.tib = get_base_region_colors()
    ),
    ab321 = list(
      region_colors.tib = get_base_region_colors()
    ),
    ace2 = list(
      region_colors.tib = get_ace2_region_colors()
    )
  )

  if (!key %in% names(configs)) {
    stop(paste0("Unknown project key: ", project_key))
  }

  cfg <- configs[[key]]
  cfg$AA_tribble <- get_aa_tribble()
  cfg$AA_singlecode <- dplyr::select(cfg$AA_tribble, resaa, resa)
  cfg$region_colors <- stats::setNames(cfg$region_colors.tib$value, cfg$region_colors.tib$name)
  cfg$chain_adjustements <- get_chain_adjustements()
  cfg
}

# ===== Arpeggio Color Palette (YRB) =====
# Returns named list of YRB colors (yellow-red-blue scheme)
get_yrb_colors <- function() {
  list(
    yrb_yellow = rgb(245, 163, 19, maxColorValue = 255),
    yrb_lyellow = rgb(245, 201, 19, maxColorValue = 255),
    yrb_l2yellow = rgb(245, 239, 19, maxColorValue = 255),
    yrb_red = rgb(241, 98, 99, maxColorValue = 255),
    yrb_lred = rgb(247, 168, 169, maxColorValue = 255),
    yrb_blue = rgb(61, 130, 196, maxColorValue = 255),
    yrb_lblue = rgb(120, 168, 214, maxColorValue = 255),
    yrb_neutral = rgb(216, 191, 216, maxColorValue = 255),  # tan
    yrb_pisa = rgb(202, 125, 204, maxColorValue = 255)       # magenta
  )
}

# ===== Arpeggio Color Tribble =====
# Returns the primary color mapping for Arpeggio interaction types
get_arpeggio_color_tribble <- function() {
  yrb <- get_yrb_colors()
  
  tibble::tribble(
    ~PIC_type, ~PIC_gencolor, ~PIC_typecolor,
    "Hydrophobic", yrb$yrb_yellow, yrb$yrb_yellow,
    "Hydrogen", yrb$yrb_blue, yrb$yrb_blue,
    "Ionic", yrb$yrb_blue, yrb$yrb_lblue,
    "Aromatic", yrb$yrb_yellow, yrb$yrb_lyellow,
    "Cation-Pi", yrb$yrb_yellow, yrb$yrb_l2yellow,
    "Other", yrb$yrb_neutral, yrb$yrb_neutral
  )
}

# ===== Arpeggio Assignment Mapping =====
# Builds full Arpeggio interaction type lookup and priority mapping
# Returns a tibble with mapped PIC_types, colors, priorities, and faceting info
build_arpeggio_assign_color <- function() {
  arpeggio_coltribble <- get_arpeggio_color_tribble()
  
  arpeggio_coltribble %>%
    dplyr::mutate(., name = PIC_type) %>%
    dplyr::group_by(., name) %>%
    dplyr::summarize() %>%
    dplyr::mutate(.,
      PIC_type = case_when(
        name == "Carbonyl" ~ "Other",
        name == "HydrogenBond" ~ "Hydrogen",
        name == "Polar" ~ "Hydrogen",
        name == "Proximal" ~ "Other",
        name == "VdW" ~ "Other",
        name == "vdW_Clash" ~ "Other",
        name == "weakHydrogenBond" ~ "Other",
        name == "WeakPolar" ~ "Other",
        TRUE ~ name
      )
    ) %>%
    dplyr::left_join(., arpeggio_coltribble) %>%
    dplyr::mutate(.,
      priority = case_when(
        name == "Proximal" ~ "a",
        name == "Hydrophobic" ~ "b",
        name == "Aromatic" ~ "c",
        name == "HydrogenBond" ~ "d",
        name == "Ionic" ~ "e",
        name == "Polar" ~ "f",
        name == "weakHydrogenBond" ~ "g",
        name == "WeakPolar" ~ "h",
        name == "Carbonyl" ~ "i",
        name == "WeakPolar" ~ "j",
        TRUE ~ "k"
      )
    ) %>%
    tidyr::unite(., col = "name_priority", c("priority", "name"), sep = ".", remove = FALSE) %>%
    dplyr::mutate(.,
      facetPIC = case_when(
        name_priority == "c.Aromatic" ~ "b.Hydrophobic",
        name_priority == "e.Ionic" ~ "d.HydrogenBond",
        TRUE ~ name_priority
      )
    ) %>%
    dplyr::mutate(.,
      filled = case_when(
        PIC_type == "Aromatic" ~ "N",
        PIC_type == "Other" ~ "Y",
        PIC_type == "Ionic" & name == "Ionic" ~ "N",
        PIC_type == "Ionic" & name == "HydrogenBond" ~ "Y",
        PIC_type == "Hydrophobic" ~ "Y",
        PIC_type == "Hydrogen" ~ "Y"
      )
    )
}

# ===== Helper: Extract color mapping for plots =====
# Extract a named vector (name -> color) from arpeggio_assign_color for use in scale_*_manual
# key_column: which column to use as names (typically "PIC_type")
# value_column: which column to use as values (typically "PIC_typecolor")
get_arpeggio_assign_color_col <- function(arpeggio_assign_color, key_column = "PIC_type", value_column = "PIC_typecolor") {
  arpeggio_assign_color %>%
    dplyr::transmute(name = .data[[key_column]], value = .data[[value_column]]) %>%
    dplyr::distinct() %>%
    tibble::deframe()
}
