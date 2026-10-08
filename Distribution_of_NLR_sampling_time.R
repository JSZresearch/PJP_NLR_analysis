# install.packages(c("tidyverse"))
library(tidyverse)

df <- read_csv("nlr_timing.csv")
df$icu_intime <- as.POSIXct(df$icu_intime, tz = "UTC")

x <- df$nlr_offset_from_intime_h
desc <- tibble(
  n        = length(x),
  median   = median(x),
  q25      = quantile(x, 0.25),
  q75      = quantile(x, 0.75),
  min      = min(x),
  max      = max(x),
  n_within_24h  = sum(x <= 24),
  pct_within_24h= mean(x <= 24) * 100,
  n_within_48h  = sum(x <= 48),
  pct_within_48h= mean(x <= 48) * 100
)
print(desc)
write_csv(desc, "nlr_timing_summary.csv")

med <- median(x)
p1 <- ggplot(df, aes(x = nlr_offset_from_intime_h)) +
  geom_histogram(bins = 25, fill = "#3474A7", alpha = 0.75,
                 color = "black", linewidth = 0.2) +
  geom_vline(xintercept = med, color = "red", linetype = "dashed", linewidth = 0.8) +
  annotate("text", x = med, y = Inf, vjust = 2, hjust = -0.05, color = "red",
           label = paste0("Median = ", round(med, 1), " h")) +
  labs(x = "Time from ICU admission to NLR measurement (hours)",
       y = "Number of measurements",
       title = "A. Histogram") +
  theme_bw(base_size = 12)

p2 <- ggplot(df, aes(x = nlr_offset_from_intime_h)) +
  geom_density(fill = "#3474A7", alpha = 0.5) +
  geom_vline(xintercept = med, color = "red", linetype = "dashed", linewidth = 0.8) +
  labs(x = "Time from ICU admission to NLR measurement (hours)",
       y = "Density",
       title = "B. Density") +
  theme_bw(base_size = 12)

library(patchwork)
combined <- p1 | p2
ggsave("nlr_timing_distribution_R.png", combined,
       width = 12, height = 5.5, dpi = 300)
