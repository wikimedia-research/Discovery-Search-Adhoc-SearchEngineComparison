library(tidyverse)

load("data/processed.RData")
load("data/features.RData")

zero_results <- queries %>%
  group_by(features) %>%
  summarize(cirrus_n = n(),
            cirrus_zr = sum(zero_result_enwiki, na.rm = TRUE),
            google_n = sum(!is.na(zero_results_google)),
            google_zr = sum(zero_results_google, na.rm = TRUE),
            enwiki_via_google_n = sum(!is.na(zero_results_enwiki_via_google)),
            enwiki_via_google_zr = sum(zero_results_enwiki_via_google, na.rm = TRUE),
            yahoo_n = sum(!is.na(zero_results_yahoo)),
            yahoo_zr = sum(zero_results_yahoo, na.rm = TRUE),
            bing_n = sum(!is.na(zero_results_bing)),
            bing_zr = sum(zero_results_bing, na.rm = TRUE),
            ddg_n = sum(!is.na(zero_results_ddg)),
            ddg_zr = sum(zero_results_ddg, na.rm = TRUE)) %>%
  ungroup %>%
  mutate(
    google_zr = ifelse(google_n == 0, NA, google_zr),
    enwiki_via_google_zr = ifelse(enwiki_via_google_n == 0, NA, enwiki_via_google_zr),
    yahoo_zr = ifelse(yahoo_n == 0, NA, yahoo_zr),
    bing_zr = ifelse(bing_n == 0, NA, bing_zr),
    ddg_zr = ifelse(ddg_n == 0, NA, ddg_zr)
  ) %>%
  left_join(features[, c("features", "proportion_total", "proportion_interested")], by = "features")

zero_results %>%
  arrange(desc(proportion_total)) %>%
  transmute(
    `Combination of features` = features,
    `Proportion of all enwiki searches from US` = sprintf("%.6f%%", 100 * proportion_total),
    `Cirrus ZRR` = sprintf("%.0f%% (%.0f/%.0f)", 100 * cirrus_zr/cirrus_n, cirrus_zr, cirrus_n),
    `Google ZRR` = sprintf("%.0f%% (%.0f/%.0f)", 100 * google_zr/google_n, google_zr, google_n),
    `Google +site:enwiki ZRR` = sprintf("%.0f%% (%.0f/%.0f)", 100 * enwiki_via_google_zr/enwiki_via_google_n, enwiki_via_google_zr, enwiki_via_google_n),
    `Yahoo ZRR` = sprintf("%.0f%% (%.0f/%.0f)", 100 * yahoo_zr/yahoo_n, yahoo_zr, yahoo_n),
    `Bing ZRR` = sprintf("%.0f%% (%.0f/%.0f)", 100 * bing_zr/bing_n, bing_zr, bing_n),
    `DDG ZRR` = sprintf("%.0f%% (%.0f/%.0f)", 100 * ddg_zr/ddg_n, ddg_zr, ddg_n)
  ) %>%
  knitr::kable(format = "markdown", align = c("l", "r", rep("r", 6))) %>%
  gsub("NA% (NA/0)", "", ., fixed = TRUE)

library(binom)

zrr <- apply(zero_results[, -(1:2)], 2, function(zero_result) {
  return(cbind(zero_results, binom.confint(zero_result, zero_results$queries, methods = "exact")))
}) %>% bind_rows(.id = "engine")
# zrr$n_features <- paste0(zrr$features, " (", zrr$queries, " queries)")

zrr_plot <- ggplot(
  zrr,
  # filter(zrr, features %in% c("[has odd double quotes]", "[has even double quotes]", "[is simple]")),
  aes(x = engine, color = engine)) +
  geom_hline(aes(yintercept = mean),
             data = filter(zrr,
                           # features %in% c("[has odd double quotes]", "[has even double quotes]", "[is simple]"),
                           engine == "Cirrus"),
             linetype = "dashed", color = RColorBrewer::brewer.pal(3, "Set1")[1]) +
  geom_pointrange(aes(ymin = lower, ymax = upper, y = mean), position = position_dodge(width = 1)) +
  scale_y_continuous(labels = scales::percent_format(), breaks = seq(0, 1, 0.1)) +
  scale_x_discrete(limits = c("Cirrus", "Google", "Google +site:en.wikipedia.org", "Yahoo", "Bing")) +
  scale_color_brewer("Search Engine", palette = "Set1",
                     limits = c("Cirrus", "Google", "Google +site:en.wikipedia.org", "Yahoo", "Bing")) +
  labs(x = "Combination of features", y = "Zero results rate",
       title = "How query features yield varying zero results rates across search engines",
       subtitle = sprintf("%.0f queries representing %.0f combinations of features", sum(zero_results$queries), nrow(zero_results))) +
  facet_wrap(~ features, ncol = 1) +
  theme_minimal(base_family = "Open Sans") +
  theme(legend.position = "bottom",
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        strip.background = element_rect(fill = "gray90"),
        panel.border = element_rect(color = "gray30", fill = NA))

if (!dir.exists("figures")) { dir.create("figures") }
ggplot2::ggsave("zrr_by_features-engine.png", plot = zrr_plot, path = "figures", width = 8, height = 80, units = "in", dpi = 72, limitsize = FALSE)
