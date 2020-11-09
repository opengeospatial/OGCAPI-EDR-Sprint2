source("sourcer.R")

param_dv <- get_param_table("https://waterservices.usgs.gov/nwis/site/?format=rdb&stateCd=al&seriesCatalogOutput=true&outputDataTypeCd=dv&siteStatus=all")

knitr::kable(dplyr::arrange(dplyr::select(param_dv, parm_cd, stat_cd, count_nu, label), dplyr::desc(count_nu)))

dv_parameters <- lapply(1:nrow(param), apply_fun, param = param, period = "P1D")

names(dv_parameters) <- param$id

param_uv <- get_param_table("https://waterservices.usgs.gov/nwis/site/?format=rdb&stateCd=al&seriesCatalogOutput=true&outputDataTypeCd=uv&siteStatus=all")

knitr::kable(dplyr::arrange(dplyr::select(param_uv, parm_cd, stat_cd, count_nu, label), dplyr::desc(count_nu)))

uv_parameters <- lapply(1:nrow(param_uv), apply_fun, param = param_uv, period = "P1S")

collections <- list(list(id = "instantaneous",
                         title = "Continuous Instantaneous Observations",
                         description = "Unprocessed observational data",
                         keywords = list("keyword1", "keyword2"),
                         extent = "todo",
                         crs = "todo",
                         outputformat = "todo",
                         parameters = uv_parameters,
                         links = make_collection_link("http://www.example.org/edr/collections/daily/", 
                                                      "http://www.example.org/edr/service-doc/", 
                                                      "http://www.example.org/edr/license/", 
                                                      query_types = c("radius", "area", "location", "items"))), 
                    list(id = "daily",
                         title = "Daily Summary Observations",
                         description = "Unprocessed observational data",
                         keywords = list("keyword1", "keyword2"),
                         extent = "todo",
                         crs = "todo",
                         outputformat = "todo",
                         parameters = dv_parameters,
                         links = make_collection_link("http://www.example.org/edr/collections/daily/", 
                                                      "http://www.example.org/edr/service-doc/", 
                                                      "http://www.example.org/edr/license/", 
                                                      query_types = c("radius", "area", "location", "items"))))

links <- list(list(make_link("http://www.example.org/edr/collections/", "self", "application/json"),
                   make_link("http://www.example.org/edr/collections/", "alternate", "text/html")))

jsonlite::write_json(list(links = links, collections = collections), "mockup.json", pretty = TRUE, auto_unbox = TRUE)
