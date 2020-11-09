get_param_table <- function(site_service_url) {
  sample_ <- dataRetrieval::importRDB1(site_service_url)
  
  sample_$stat_cd[is.na(sample_$stat_cd)] <- "00000"
  
  param <- dplyr::group_by(dplyr::select(sample_, parm_cd, stat_cd, count_nu), parm_cd, stat_cd)
  
  param <- dplyr::summarise(param, count_nu = sum(count_nu), .groups = "drop")
  
  get_label <- function(cd, type) {
    base <- list(p = "https://waterdata.usgs.gov/nwisweb/rdf?parmCd=",
                 s = "https://waterdata.usgs.gov/nwisweb/rdf?statCd=")
    
    url <- paste0(base[type], cd)
    
    x <- xml2::as_list(xml2::read_xml(url))
    
    x$RDF$Description$value[[1]]
  }
  
  lookup_parm_cd <- sapply(unique(param$parm_cd), get_label, type = "p")
  
  lookup_stat_cd <- sapply(unique(param$stat_cd), get_label, type = "s")
  
  param$id <- paste0("s", param$stat_cd, "_p", param$parm_cd)
  
  param$parm_label <- lookup_parm_cd[param$parm_cd]
  
  param$stat_label <- lookup_stat_cd[param$stat_cd]
  
  param$label <- paste(param$stat_label, param$parm_label)
  
  param_units <- strsplit(param$label, split = ", ")
  
  param$units <- sapply(param_units, function(x) x[length(x)])
  
  param
  
}

make_parameter <- function(description, units, obervedProperty, OP_label, 
                           measurementType, MT_label, MT_period) {
  
  list(type = "Parameter", 
       description = list(en = description,
                          sp = "todo"),
       unit = list(label = list(en = units,
                                sp = "todo"),
                   symbol = list(value = "units",
                                 type = "https://todo")),
       observedProperty = list(id = paste0("https://waterdata.usgs.gov/nwisweb/rdf?parmCd=", obervedProperty),
                               label = list(en = OP_label,
                                            sp = "todo")),
       measurementType = list(id = paste0("https://waterdata.usgs.gov/nwisweb/rdf?statCd=", measurementType),
                              method = MT_label,
                              period = MT_period))
}

apply_fun <- function(x, param, period) {
  make_parameter(param$label[x], param$units[x], param$parm_cd[x], param$parm_label[x], 
                 param$stat_cd[x], param$stat_label[x], period)
}

make_link <- function(href, rel, type, title = NA, hreflang = "en") {
  out <- list(href = href,
              hreflang = hreflang,
              rel = rel,
              type = type)
  
  if(!is.na(title)) {
    c(out, list(title = title))
  } else {
    out
  }
}

make_collection_link <- function(coll_url, service_doc, license_doc, query_types) {
  out <- list(make_link(service_doc, "service-doc", "text/html", "service documentation"),
              make_link(license_doc, "license", "text/html", "license"))
  
  out <- c(out,
           lapply(query_types, function(x) {
             make_link(paste0(coll_url, x), "data", x, x)
           }))
  
}
