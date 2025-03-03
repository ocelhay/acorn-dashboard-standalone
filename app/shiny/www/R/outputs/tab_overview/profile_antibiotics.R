output$profile_antibiotics <- renderHighchart({
  req(redcap_f01f05_dta_filter())
  req(nrow(redcap_f01f05_dta_filter()) > 0)
  
  if(! input$antibiotics_combinations) return({
    # https://stackoverflow.com/questions/70158318/custom-colors-in-r-highcharter-barplot/
    dta <- left_join(redcap_f01f05_dta_filter() %>% 
                       select(antibiotic_j01gb06:antibiotic_other_text) %>%
                       pivot_longer(antibiotic_j01gb06:antibiotic_other_text, names_to = "antibiotic_code", values_to = "antibiotic") %>%
                       filter(antibiotic != ""), 
                     aware,
                     by = "antibiotic_code") |> 
      replace_na(list(category = "Unknown")) |> 
      group_by(antibiotic, category) |> 
      count() |> 
      arrange(desc(n)) |> 
      mutate(category = factor(category, levels = c("Access", "Watch", "Reserve", "Unknown")))%>% 
      ungroup() %>% 
      mutate(antibiotic = factor(antibiotic) %>% fct_reorder(n, .desc = TRUE)) %>% 
      mutate(cat_index = as.numeric(antibiotic))
    
    cols <- cols_aware[levels(dta$category)[levels(dta$category) %in% unique(dta$category)]]
    
    dta %>%
      hchart(type = "bar", hcaes(x = cat_index, y = n, group = category, name = antibiotic), color = cols) %>%
      hc_yAxis(title = "", stackLabels = list(enabled = TRUE)) %>% 
      hc_xAxis(title = "", type = "category", labels = list(step = 1)) %>% 
      hc_tooltip(headerFormat = "",
                 pointFormat = "{point.n} patients have taken {point.antibiotic}") %>%
      hc_plotOptions(series = list(stacking = 'normal')) %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
  
  if(input$antibiotics_combinations) return({
    redcap_f01f05_dta_filter() %>% 
      unite("antibiotic", antibiotic_j01gb06:antibiotic_other_text, na.rm = TRUE) %>%
      count(antibiotic) %>%
      mutate(antibiotic = str_replace(antibiotic, "^_+", "")) %>%
      mutate(antibiotic = str_replace(antibiotic, "_+$", "")) %>%
      mutate(antibiotic = str_replace_all(antibiotic, "_+", " + ")) %>%
      filter(antibiotic != "") %>% filter(antibiotic != " ") %>%
      arrange(desc(n)) %>%
      hchart(type = "bar", hcaes(x = "antibiotic", y = "n")) %>%
      hc_yAxis(title = "", stackLabels = list(enabled = TRUE)) %>% 
      hc_xAxis(title = "") %>%
      hc_colors("#969696") %>%
      hc_tooltip(headerFormat = "",
                 pointFormat = "{point.n} patients have taken {point.antibiotic}") %>%
      hc_plotOptions(series = list(stacking = 'normal')) %>%
      hc_exporting(enabled = TRUE, buttons = list(contextButton = list(menuItems = hc_export_kind)))
  })
})
