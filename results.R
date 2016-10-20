library(tidyverse)

load("data/processed.RData")
load("data/features.RData")

zero_results <- queries %>%
  group_by(features) %>%
  summarize(queries = n(),
            Cirrus = sum(zero_result_enwiki),
            Google = NA,
            `Google +site:en.wikipedia.org` = NA,
            Yahoo = NA,
            Bing = NA) %>%
  ungroup %>%
  left_join(features[, c("features", "proportion_total", "proportion_interested")], by = "features")

zero_results %>%
  gather(engine, zr, -c(1:2, 8:9)) %>%
  mutate(zrr = sprintf("%.0f%%", 100 * zr/queries)) %>%
  select(-zr) %>%
  spread(engine, zrr) %>%
  arrange(desc(proportion_total)) %>%
  mutate(proportion_total = sprintf("%.6f%%", 100 * proportion_total),
         proportion_interested = sprintf("%.6f%%", 100 * proportion_interested)) %>%
  rename(`Proportion of all enwiki searches from US` = proportion_total,
         `Proportion within this group` = proportion_interested,
         `Sample queries` = queries,
         `Combination of features` = features) %>%
  select(-`Proportion within this group`) %>%
  knitr::kable(format = "markdown", align = c("l", "r", rep("r", 8))) %>%
  gsub("NA%", "", ., fixed = TRUE)

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
