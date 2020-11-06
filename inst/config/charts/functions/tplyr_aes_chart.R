tplyr_aes_chart<-function(data,settings){

    print("tplyr ae chart called")
    dm_sub <- safetyGraphics::dm %>% select(USUBJID, ARM)
    anly <- dm_sub %>% left_join(safetyGraphics::aes)
    
    
    t <- tplyr_table(anly, ARM) %>% 
        set_pop_data(dm_sub) %>% 
        set_pop_treat_var(ARM) %>% 
        build() %>%
        kable() 
    #%>% 
        # add_layer(
        #     group_count(vars(AEBODSYS, AEDECOD)) %>% 
        #     set_distinct_by(USUBJID) %>% 
        #     set_format_strings(
        #     n_counts = f_str("xx (xx.x%) [x]", distinct, distinct_pct, n)
        # ) %>% 
        # set_nest_count(TRUE) %>% 
        # set_order_count_method('bycount') %>% 
        # set_result_order_var(distinct_n) %>%
        # set_ordering_cols('Xanomeline High Dose') %>% 
        # add_risk_diff(
        #     c('Xanomeline High Dose', 'Placebo'), 
        #     c('Xanomeline Low Dose', 'Placebo')
        # )
    #)
    
    # t2<- suppressWarnings(build(t)) %>% 
    #     select(starts_with('row'), starts_with('var'), starts_with('rdiff'), starts_with('ord')) %>% 
    #     kable() %>% 
    #     kable_styling() %>%
    #     scroll_box(width = "100%", height = "500px")
    
    return(t)
}