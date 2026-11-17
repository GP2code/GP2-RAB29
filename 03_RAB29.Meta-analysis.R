library(dplyr)
library(tibble)
library(meta)
library(logistf)
library(ggplot2)

# Output directory
out_dir <- "~"

# Overview of cohorts and carriers
dat <- tribble(
  ~cohort,          ~group,        ~pd_carriers, ~pd_total, ~nonPD_carriers, ~nonPD_total,
  "GP2",           "GP2",                16,     52375,              2,       18857,
  "UK Biobank",    "Biobanks",            0,      3875,              4,      269207,
  "Tübingen",      "Biobanks",            1,       454,             12,       39344,
  "Centogene",     "Biobanks",            1,      6290,              4,       36007,
  "Genentech",     "Biobanks",            2,      2710,              3,        8562,
  "McGill",        "Clinical cohorts",    4,      5823,              1,        5335,
  "IRCCS Bologna", "Clinical cohorts",    0,       573,              1,        2093,
  "IRCCS Pavia",   "Clinical cohorts",    0,       248,              0,         804,
  "Lübeck",        "Clinical cohorts",    0,       569,              0,         264
)


# Validate the input
stopifnot(
  all(dat$pd_carriers >= 0),
  all(dat$nonPD_carriers >= 0),
  all(dat$pd_carriers <= dat$pd_total),
  all(dat$nonPD_carriers <= dat$nonPD_total),
  all(dat$pd_total > 0),
  all(dat$nonPD_total > 0)
)

dat <- dat %>%
  mutate(
    pd_noncarriers = pd_total - pd_carriers,
    ctrl_noncarriers = nonPD_total - nonPD_carriers
  )

print(dat)


## Individual study group analysis (Fisher's Exact Test)

individual_results <- bind_rows(lapply(seq_len(nrow(dat)), function(i) {
  
  d <- dat[i, ]
  
  # No carrier in either group
  if (d$pd_carriers == 0 && d$nonPD_carriers == 0) {
    return(tibble(
      cohort = d$cohort,
      pd_carriers = d$pd_carriers,
      pd_total = d$pd_total,
      nonPD_carriers = d$nonPD_carriers,
      nonPD_total = d$nonPD_total,
      OR = NA_real_,
      CI_lower = NA_real_,
      CI_upper = NA_real_,
      p_value = NA_real_,
      status = "No carriers in either group"
    ))
  }
  
  tab <- matrix(
    c(d$pd_carriers, d$pd_noncarriers,
      d$nonPD_carriers, d$ctrl_noncarriers),
    nrow = 2, byrow = TRUE
  )
  
  ft <- fisher.test(tab)
  
  tibble(
    cohort = d$cohort,
    pd_carriers = d$pd_carriers,
    pd_total = d$pd_total,
    nonPD_carriers = d$nonPD_carriers,
    nonPD_total = d$nonPD_total,
    OR = unname(ft$estimate),
    CI_lower = unname(ft$conf.int[1]),
    CI_upper = unname(ft$conf.int[2]),
    p_value = ft$p.value,
    status = "Analyzed"
  )
}))

print(individual_results, n = Inf)


# Forest plot of individual study groups
d <- individual_results

d$y <- rev(seq_len(nrow(d)))

# Forest axis range, on a log10 scale
or_min <- 0.01
or_max <- 200
n <- nrow(d)

# Map OR values onto the forest's horizontal plotting area
forest_left <- 6.0
forest_right <- 9.1

map_or <- function(x) {
  forest_left +
    (log10(x) - log10(or_min)) /
    (log10(or_max) - log10(or_min)) *
    (forest_right - forest_left)
}

# Keep estimable, positive effect estimates and CIs
valid <- with(
  d,
  is.finite(OR) & OR > 0 &
    is.finite(CI_lower) & CI_lower > 0 &
    is.finite(CI_upper) & CI_upper > 0
)

plot_effects <- d[valid, ]

plot_effects$x_or <- map_or(plot_effects$OR)
plot_effects$x_low <- map_or(pmax(plot_effects$CI_lower, or_min))
plot_effects$x_high <- map_or(pmin(plot_effects$CI_upper, or_max))

# Format the reported ORs, CIs, and p-values for display
d$or_label <- ifelse(
  is.finite(d$OR),
  sprintf("%.2f", d$OR),
  ifelse(is.na(d$OR), "NA", as.character(d$OR))
)

d$ci_label <- ifelse(
  is.finite(d$CI_lower) & is.finite(d$CI_upper),
  paste0(
    format(d$CI_lower, trim = TRUE, scientific = FALSE),
    "–",
    format(d$CI_upper, trim = TRUE, scientific = FALSE)
  ),
  "NA"
)

d$p_label <- ifelse(
  is.na(d$p_value), "NA",
  format.pval(d$p_value, digits = 3, eps = 0.001)
)

# Axis tick positions and labels
ticks <- c(0.01, 0.1, 1, 10, 100)

tick_data <- data.frame(
  x = map_or(ticks),
  label = as.character(ticks)
)

# Column positions
x_study <- 0.55
x_pd_carriers <- 2.65
x_pd_total <- 3.55
x_nonPD_carriers <- 4.55
x_nonPD_total <- 5.45

x_or_text <- 9.55
x_ci_text <- 10.55
x_p_text <- 12.75

# Plot
p <- ggplot() +
  
  # Reference line at OR = 1
  geom_segment(
    aes(x = map_or(1), xend = map_or(1), 
        y = 0.85, yend = 9.65),
    linetype = "dashed",
    colour = "grey50",
    linewidth = 0.5
  ) +

  # Confidence intervals
  geom_segment(
    data = plot_effects,
    aes(x = x_low, xend = x_high,
        y = y, yend = y),
    colour = "black",
    linewidth = 0.35
  ) +
  
  # Blue squares for individual cohorts
  geom_point(
    data = plot_effects,
    aes(x = x_or,
        y = y,
        size = pd_total + nonPD_total),
    shape = 15,
    colour = "#2485AC"
  ) +
  scale_size_area(
    max_size = 6,
    name = "Total cohort size"
  ) +
  guides(size = "none") +
  
  # Cohort names and carrier counts
  geom_text(data = d, aes(x = x_study, y = y, label = cohort), hjust = 0, size = 3.2) +
  geom_text(data = d, aes(x = x_pd_carriers, y = y, label = pd_carriers), size = 3.2) +
  geom_text(data = d, aes(x = x_pd_total, y = y, label = pd_total), size = 3.2) +
  geom_text(data = d, aes(x = x_nonPD_carriers, y = y, label = nonPD_carriers), size = 3.2) +
  geom_text(data = d, aes(x = x_nonPD_total, y = y, label = nonPD_total), size = 3.2) +
  
  # Effect estimates
  geom_text(data = d, aes(x = x_or_text, y = y, label = or_label), size = 3.2) +
  geom_text(data = d, aes(x = x_ci_text, y = y, label = ci_label), hjust = 0, size = 3.2) +
  geom_text(data = d, aes(x = x_p_text, y = y, label = p_label), size = 3.2) +
  
  # Column headings
  annotate("text", x = x_study, y = 10.15, label = "Study group", hjust = 0, fontface = "bold", size = 3.4) +
  annotate("text", x = x_pd_carriers, y = 10.15, label = "PD\ncarriers", fontface = "bold", size = 3.4) +
  annotate("text", x = x_pd_total, y = 10.15, label = "PD\ntotal", fontface = "bold", size = 3.4) +
  annotate("text", x = x_nonPD_carriers, y = 10.15, label = "Non-PD\ncarriers", fontface = "bold", size = 3.4) +
  annotate("text", x = x_nonPD_total, y = 10.15,label = "Non-PD\ntotal", fontface = "bold", size = 3.4) +
  annotate("text", x = (forest_left + forest_right) / 2, y = 10.15, label = "Odds Ratio", fontface = "bold", size = 3.4) +
  annotate("text", x = x_or_text, y = 10.15, label = "OR", fontface = "bold", size = 3.4) +
  annotate("text", x = x_ci_text, y = 10.15, label = "95%-CI", hjust = 0, fontface = "bold", size = 3.4) +
  annotate("text", x = x_p_text, y = 10.15, label = "p-value", fontface = "bold", size = 3.4) +
  
  # Horizontal axis and tick labels
  geom_segment(
    aes(x = forest_left, xend = forest_right,
        y = 0.75, yend = 0.75),
    colour = "black", linewidth = 0.4) +
  geom_segment(
    data = tick_data,
    aes(x = x, xend = x, y = 0.75, yend = 0.87),
    linewidth = 0.4) +
  geom_text(
    data = tick_data,
    aes(x = x, y = 0.52, label = label),
    size = 3.0) +
  
  scale_x_continuous(
    limits = c(0.35, 13.4),
    expand = c(0, 0)) +
  scale_y_continuous(
    limits = c(0.3, 10.65),
    breaks = NULL,
    expand = c(0, 0)) +

  labs(x = NULL, y = NULL) +
  
  theme_void(base_size = 10) +
  theme(
    plot.margin = margin(15, 18, 15, 12),
    plot.background = element_rect(
      fill = "white", colour = NA)
  )

ggsave(
      filename = file.path(out_dir, "RAB29_forest_individual.tiff"),
      plot = p,
      width = 11,
      height = 3.4,
      units = "in",
      dpi = 600,
      compression = "lzw"
 )



### Firth logistic regression adjusted for study site

# Expand cohort counts into grouped binomial data
agg <- bind_rows(
  dat %>% transmute(
    study_site = cohort, PD_status = 1L,
    carrier = 1L, COUNT = pd_carriers
  ),
  dat %>% transmute(
    study_site = cohort, PD_status = 1L,
    carrier = 0L, COUNT = pd_noncarriers
  ),
  dat %>% transmute(
    study_site = cohort, PD_status = 0L,
    carrier = 1L, COUNT = nonPD_carriers
  ),
  dat %>% transmute(
    study_site = cohort, PD_status = 0L,
    carrier = 0L, COUNT = ctrl_noncarriers
  )
) %>%
  filter(COUNT > 0) %>%
  mutate(study_site = factor(study_site))

# Fit Firth-corrected logistic regression
fit <- logistf(
  PD_status ~ carrier + study_site,
  data = agg,
  weights = COUNT,
  firth = TRUE,
  pl = TRUE
)


# Extract the carrier effect
results <- data.frame(
  Analysis = "Firth logistic regression adjusted for study site",
  OR = exp(coef(fit)["carrier"]),
  CI_lower = exp(fit$ci.lower["carrier"]),
  CI_upper = exp(fit$ci.upper["carrier"]),
  P_value = fit$prob["carrier"],
  row.names = NULL
)

print(results)

## Aggregate the data into the three groups
group_dat <- dat %>%
  group_by(group) %>%
  summarise(
    PD_carriers = sum(pd_carriers),
    PD_noncarriers = sum(pd_noncarriers),
    nonPD_carriers = sum(nonPD_carriers),
    ctrl_noncarriers = sum(ctrl_noncarriers),
    PD_total = sum(pd_total),
    nonPD_total = sum(nonPD_total),
    .groups = "drop"
  ) %>%
  mutate(
    group = factor(
      group,
      levels = c("GP2", "Biobanks", "Clinical cohorts")
    )
  ) %>%
  arrange(group)


# Verify totals
stopifnot(
  sum(group_dat$PD_total) == sum(dat$pd_total),
  sum(group_dat$nonPD_total) == sum(dat$nonPD_total),
  all(group_dat$PD_carriers <= group_dat$PD_total),
  all(group_dat$nonPD_carriers <= group_dat$nonPD_total)
)

print(group_dat)


## Fixed-effect and random-effects meta-analysis of the three groups
# REML random-effects model
m_groups <- metabin(
  event.e = PD_carriers,
  n.e = PD_total,
  event.c = nonPD_carriers,
  n.c = nonPD_total,
  studlab = group,
  data = group_dat,
  sm = "OR",
  method = "MH",
  common = FALSE,
  random = TRUE,
  method.random = "REML",
  method.random.ci = "HK",
  incr = 0.5,
  method.incr = "only0",
  prediction = FALSE,
  label.e = "PD",
  label.c = "Non-PD"
)

# View pooled estimates, confidence intervals, p-values, and I2
summary(m_groups)

# Forest plot showing the three group estimates and pooled effects
tiff(file.path(out_dir, "RAB29_forest_grouped.tiff"), width = 10, height = 3, units = "in", res = 600,)
meta::forest(
  m_groups,
  common = FALSE,
  random = TRUE,
  prediction = FALSE,
  test.overall.random = TRUE,
  label.test.overall.random = "REML p-value: ",
  print.stat = FALSE,
  overall.hetstat = FALSE,
  text.addline1 = paste0(
    "Heterogeneity: I\u00b2 = ", round(m_groups$I2, 1),
    "%; Q-test p = ", format.pval(m_groups$pval.Q, digits = 3)),
  col.diamond = "#8550A1",
  col.square = "#2485AC",
  lwd.square = 0,
  lwd.diamond = 0,
  xlim = c(0.1, 20),
  leftcols = c("studlab", "event.e", "n.e", "event.c", "n.c"),
  leftlabs = c("Study group", "PD\ncarriers", "PD\ntotal", "Non-PD\ncarriers", "Non-PD\ntotal"),
  fs.study = 9,
  fs.heading = 9,
  fs.axis = 9,
  fs.smlab = 9,
  fs.random.labels = 9,
  fs.random = 9,
  fs.test.overall = 9,
  fs.hetstat = 9,
  just = "center",
  plotwidth = "7.5cm",
  colgap.left = "5mm"
)
dev.off()

# Extract REML results
meta_results <- data.frame(
  Model = "Random-effects (REML)",
  OR = exp(m_groups$TE.random),
  CI_lower = exp(m_groups$lower.random),
  CI_upper = exp(m_groups$upper.random),
  p_value = m_groups$pval.random,
  I2_percent = m_groups$I2,
  tau2 = m_groups$tau2
)
  

print(meta_results, digits = 3)
