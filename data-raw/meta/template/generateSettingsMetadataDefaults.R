
generateSettingsMetadataDefaults <- function(){
    return(
        tribble(~text_key, ~default,
          "id_col", NULL,
           "seq_col",NULL,
          "stdy_col",NULL,
           "endy_col",NULL,
           "term_col",NULL,
           "filters",NULL,
           "details",NULL,
        )
    )
}


