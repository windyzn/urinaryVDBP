
rename_table_rows <- function(x) {
  gsub('Age', 'Age (years)', x) %>% 
  gsub('Waist', 'Waist Circumference (cm)', .) %>% 
  gsub('eGFR', 'Estimated GFR (ml/min/1.73m^2)', .) %>% 
  gsub('ACR', 'Urinary Albumin-to-Creatinine Ratio (mg/mmol)', .) %>% 
  gsub('MicroalbCreatRatio', 'Microalbumin:Creatinine', .) %>%
  gsub('UrineCreatinine', 'Urinary Creatinine (mmol/L)', .) %>% 
  gsub('UrineMicroalbumin', 'Urinary Microalbumin (mg/L)', .) %>% 
  gsub('VitaminD', 'Serum 25(OH)D (nmol/L)', .) %>% 
  gsub('UDBP', 'Urinary VDBP (ng/mL)', .) %>% 
  gsub('Diastolic', 'Diastolic Blood Pressure (mmHg)', .) %>% 
  gsub('MeanArtPressure', 'Mean Arterial Pressure (mmHg)', .) %>% 
  gsub('Systolic', 'Systolic Blood Pressure (mmHg)', .) %>% 
  gsub('PTH', 'Parathyroid Hormone (pmol/L)', .) %>% 
  gsub('ALT', 'Serum ALT (U/L)', .) %>% 
  gsub('Glucose0', 'Fasting', .) %>% 
  gsub('Glucose120', '2h OGTT', .) %>% 
  gsub('dm_status', 'Diabetic Status', .) %>% 
  gsub('DM', 'Diabetes', .) %>% 
  gsub('NGT', 'Normal', .)
}

# Subject Characterization ======================================================================

## This function does not take ordered variables. Make sure all variables are
## factors and unordered.

table_subChar <- function(data) {
  data %>%
    mutate(
      Ethnicity = factor(Ethnicity, ordered = FALSE),
      acr_status = factor(acr_status, ordered = FALSE),
      eGFR_status = factor(eGFR_status, ordered = FALSE),
      dm_status = factor(dm_status, ordered = FALSE),
      UDBP_status = factor(UDBP_status, ordered = FALSE)
    ) %>%
    carpenter::outline_table("fVN") %>%
    carpenter::add_rows(c('Age'),
                        carpenter::stat_meanSD) %>%
    carpenter::add_rows(c('Sex', "Ethnicity"),
                        carpenter::stat_nPct) %>% 
    carpenter::add_rows(c('BMI', 'Waist'),
                        carpenter::stat_meanSD) %>%
    carpenter::add_rows(
      c(
        'eGFR',
        'ACR',
        'UrineCreatinine',
        'UrineMicroalbumin',
        'UDBP'
      ),
      carpenter::stat_meanSD,
      digits = 1
    ) %>%
    carpenter::add_rows(c('Creatinine', 'VitaminD', "PTH", "ALT"),
                        carpenter::stat_meanSD,
                        digits = 1) %>%
    carpenter::add_rows(c('Systolic', 'Diastolic', 'MeanArtPressure'),
                        carpenter::stat_meanSD,
                        digits = 1) %>%
    carpenter::add_rows(c('Glucose0', 'Glucose120'),
                        carpenter::stat_meanSD,
                        digits = 1) %>%
    carpenter::add_rows(c('dm_status'),
                        carpenter::stat_nPct, digits = 1) %>% 
    carpenter::renaming("rows", rename_table_rows) %>%
    carpenter::build_table()
}

# Plots =========================================================================================

## Scatterplot ##
scatter_plot = function(data, xvar, yvar, xlab='', ylab='') {
  ggplot(data, aes_string(x=xvar, y=yvar)) +
    geom_point(colour = "#0db7c4", size = 1) + #mapping=aes(color=mcr_status)
    theme_minimal() + 
    theme(panel.grid.major.x = element_blank(), 
          axis.line.y = element_blank(),
          axis.text.y = element_text(colour = "grey"),
          axis.ticks.y = element_line(colour = "grey"),
          axis.text.x = element_text(colour = "grey50"), #angle = 45
          axis.title = element_text(size = 10)) +
    xlab(xlab) +
    ylab(ylab)
}

# EXAMPLE:
# scatter_plot(ds$VitaminD_ln, ds$UDBP_cr_ln,
#              'log Serum 25(OH)D', 'log UDBP:Creatinine')
# 
# With line of best fit - 
# scatter_plot(ds$VitaminD_ln, ds$UDBP_cr_ln,
#              'log Serum 25(OH)D', 'log UDBP:Creatinine') + 
# geom_smooth(method=lm, se=FALSE, colour='black')


## Boxplot ##
box_plot <- function(data, xvar, yvar, xlab="", ylab="") {
  ggplot(data, aes_string(x = xvar, y = yvar)) +
    geom_boxplot(aes_string(colour = xvar, fill = xvar)) +
    stat_summary(geom = "crossbar", width = 0.65, fatten = 0, color = "white",
                 fun.data = function(x){
                   return(c(y = median(x), ymin = median(x), ymax = median(x)))
                 }) +
    theme_minimal() +
    theme(legend.position = "none",
          panel.grid.major.x = element_blank(), 
          axis.line.y = element_blank(),
          axis.text.y = element_text(colour = "grey"),
          axis.ticks.y = element_line(colour = "grey"),
          axis.text.x = element_text(colour = "grey 30"), #angle = 45
          axis.title = element_text(size = 10)) +
    xlab(xlab) +
    ylab(ylab)
}

# scale_x_discrete(labels = paste(levels(ds_base$xvar), 
#                                 "\n(N=", table(ds_base$xvar), ")", sep = "")) +



# box_plot = function(data, xvar, yvar, xlab='', ylab='') {
#   ggplot(data, aes(x=xvar, y=yvar)) +
#     geom_boxplot() +
#     # scale_x_discrete(limits=xcat) +
#     xlab(xlab) +
#     ylab(ylab) +
#     theme_bw()
# }

## Bargraph ##
bar_plot = function(data, xvar, yvar, xlab='', ylab='') {
  ggplot(data, aes(x=xvar, y=yvar)) +
    geom_bar(stat='identity') +
    xlab(xlab) +
    ylab(ylab) +
    theme_minimal()
}

# EXAMPLE:
# box_plot(ds$eGFR_status, ds$UDBP_cr_ln,
#          c('normal','mild','moderate'),
#          'Estimated GFR','log UDBP:Creatinine')

## Histogram ##
histo_plot = function(data, variable, bin, xlab='') {
  ggplot(data, aes_string(x=variable)) +
    geom_histogram(binwidth=bin,
                   colour='#0db7c4', fill='#0db7c4') +
    xlab(xlab) +
    theme_minimal() +
    theme(panel.grid.major.x = element_blank(), 
          axis.line.y = element_blank(),
          axis.text.y = element_text(colour = "grey"),
          axis.ticks.y = element_line(colour = "grey"),
          axis.text.x = element_text(colour = "grey 30"), #angle = 45
          axis.title = element_text(size = 10)) 
}

# EXAMPLE:
# histo_plot(ds$VitaminD, 2, 'Serum 25(OH)D')

# GEE ========================================================================================
trim_ws <- function (x) {
  gsub("^\\s+|\\s+$", "", x)
}

format_rounding <- function(x, digits = 2) {
  trim_ws(format(round(x, digits = digits), nsmall = digits))
}

format_p <- function(x) {
  format.pval(x, digits = 2, eps = 0.001)
}

graph_theme <- function(base.plot, ticks = TRUE, minor.grid.lines = FALSE, legend.pos = 'bottom') {
  graph.theme <-
    ggplot2::"%+replace%"(
      ggthemes::theme_tufte(base_size = 10, base_family = 'sans'),
      ggplot2::theme(
        axis.line = ggplot2::element_line('black'),
        axis.line.x = ggplot2::element_line('black'),
        axis.line.y = ggplot2::element_line('black'),
        legend.key.width = grid::unit(0.7, "line"),
        legend.key.height = grid::unit(0.7, "line"),
        strip.background = ggplot2::element_blank(),
        plot.margin = grid::unit(c(0, 0, 0.5, 0), "cm"),
        legend.position = legend.pos
      )
    )
  
  if (!ticks) {
    graph.theme <- ggplot2::"%+replace%"(graph.theme,
                                         ggplot2::theme(axis.ticks.y = ggplot2::element_blank()))
  }
  
  if (minor.grid.lines) {
    graph.theme <- ggplot2::"%+replace%"(
      graph.theme,
      ggplot2::theme(
        panel.grid = ggplot2::element_line(),
        panel.grid.minor = ggplot2::element_blank()
      )
    )
  }
  
  return(graph.theme)
}

# Conversion --------------------------------------------------------------------------------------
get_dysglycemia_data <- function(data) {
  dysgly.data <-
    dplyr::left_join(
      data %>%
        dplyr::filter(VN == 1),
      data %>%
        dplyr::filter(!is.na(UDBP)) %>%
        dplyr::mutate_each(dplyr::funs(ifelse(is.na(.), 0, .)), IFG, IGT) %>%
        dplyr::mutate(PreDM = as.numeric(rowSums(.[c('IFG', 'IGT')], na.rm = TRUE))) %>%
        dplyr::mutate(FactorDysgly = ifelse(
          PreDM == 1, 'PreDM',
          ifelse(DM == 1, 'DM',
                 'NGT')
        )) %>%
        dplyr::select(SID, VN, FactorDysgly) %>%
        tidyr::spread(VN, FactorDysgly) %>%
        dplyr::mutate(
          DetailedConvert = as.factor(paste0(`0`, '-', `1`, '-', `2`)),
          ConvertDysgly = as.numeric(!grepl('NGT$|NGT-NA$|NGT-NGT-NA$|NGT-NA-NA$',
                                            DetailedConvert)),
          ConvertDM = as.numeric(grepl('-DM$|-DM-DM$|-DM-NA$|-DM-NGT$',
                                       DetailedConvert)),
          ConvertPreDM = as.numeric(grepl('-PreDM$|-PreDM-PreDM$|-PreDM-NA$',
                                          DetailedConvert))
        )
    ) %>%
    dplyr::filter(!is.na(UDBP))
  
  return(dysgly.data)
}