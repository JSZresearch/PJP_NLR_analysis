if (!require("readxl")) install.packages("readxl")
if (!require("rms")) install.packages("rms")
if (!require("ggplot2")) install.packages("ggplot2")
library(readxl)
library(rms)
library(ggplot2)

df <- read_excel("111 cases.xlsx")
df$database <- factor(df$database, levels = c("MIMIC", "eICU"))

model_vars <- c("hosp_dead","NLR","Age","Gender","database","Malignant_neoplasms","SOFA_score")
df_rcs <- df[complete.cases(df[, model_vars]), ]

knot_pos <- quantile(df_rcs$NLR, probs = c(0.10, 0.50, 0.90), na.rm = TRUE)
ref_NLR <- knot_pos[2]

cat("\n==================== RCS Model Key Parameters ====================\n")
cat("Number of knots: 3\n")
cat("Knot quantiles: 10%, 50%, 90%\n")
cat("Knot positions(NLR): ", round(knot_pos,4), "\n")
cat("Reference knot: 2nd knot(P50, median); Reference NLR =", round(ref_NLR,4), "\n")
cat("Model setting: Relative OR = 1 at reference NLR(median) (ref.zero=TRUE)\n")

dd <- datadist(df_rcs)
options(datadist = "dd")

rcs_fit <- lrm(hosp_dead ~ rcs(NLR, knots = knot_pos, ref = 2) + Age + Gender + database + Malignant_neoplasms + SOFA_score,
               data = df_rcs,
               x = TRUE,
               y = TRUE)

rcs_anova <- anova(rcs_fit)
cat("\n==================== ANOVA Test Results ====================\n")
print(rcs_anova)
anova_df <- as.data.frame(rcs_anova)
p_overall   <- anova_df[1, "P"]
p_nonlinear <- anova_df[2, "P"]
cat(sprintf("\nP‑overall = %.3f; P‑nonlinear = %.3f\n", p_overall, p_nonlinear))

ref_check <- rms::Predict(rcs_fit, NLR = ref_NLR, fun = exp, ref.zero = TRUE)
cat(sprintf("【Validation】Reference NLR=%.2f , relative OR at this point = %.4f\n", ref_check$NLR, ref_check$yhat))

nlr_pred_seq <- seq(min(df_rcs$NLR), max(df_rcs$NLR), length.out = 200)
pred_result <- rms::Predict(rcs_fit, NLR = nlr_pred_seq, fun = exp, ref.zero = TRUE)

knot_pred <- rms::Predict(rcs_fit, NLR = knot_pos, fun = exp, ref.zero = TRUE)

p_rcs <- ggplot() +
  geom_ribbon(data = pred_result, aes(x = NLR, ymin = lower, ymax = upper), alpha = 0.2, fill = "#8ecae6") +
  geom_line(data = pred_result, aes(x = NLR, y = yhat), linewidth = 1, colour = "#947c5b") +
  geom_hline(yintercept = 1, linetype = "solid", colour = "black", linewidth = 0.8) +
  geom_vline(xintercept = ref_NLR, linetype = "dotted", colour = "#c82480", linewidth = 1) +
  geom_point(data = knot_pred, aes(x = NLR, y = yhat), color = "#0033cc", size = 2.2) +
  annotate("text", x = 2, y = 20,
           label = sprintf("P for Overall = %.3f\nP for Nonlinear = %.3f", p_overall, p_nonlinear),
           hjust = 0, size = 3.8) +
  annotate("text", x = ref_NLR, y = 1.4,
           label = sprintf("Ref NLR=%.2f\nOR=1", ref_NLR),
           colour = "#c82480", hjust = 0.5, size = 3.5) +
  labs(x = "NLR",
       y = "Odds Ratio (95% CI)",
       title = "Restricted Cubic Spline Prediction Plot") +
  scale_y_continuous(limits = c(0, 22), breaks = c(0,5,10,15,20)) +
  scale_x_continuous(limits = c(0, 45), breaks = c(0,10,20,30,40)) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title = element_text(size = 13),
        axis.text = element_text(size = 11))
print(p_rcs)
ggsave("RCS_NLR_hosp_dead.png", plot = p_rcs, width = 8, height = 8, dpi = 300)

write.csv(pred_result, "RCS_NLR_pred_table.csv", row.names = FALSE)
write.csv(as.data.frame(knot_pos), "RCS_knot_positions.csv", row.names = TRUE)
write.csv(anova_df, "RCS_ANOVA_result.csv", row.names = TRUE)

options(datadist = NULL)

if (!require("readxl")) install.packages("readxl")
if (!require("rms")) install.packages("rms")
if (!require("survival")) install.packages("survival")
if (!require("ggplot2")) install.packages("ggplot2")
library(readxl)
library(rms)
library(survival)
library(ggplot2)

df <- read_excel("111 cases.xlsx")
df$database <- factor(df$database, levels = c("MIMIC", "eICU"))

df_mimic <- subset(df, database == "MIMIC")

model_vars_cox <- c("ICU28_day_dead_time","ICU28_day_dead","NLR","Age","Gender","database","Malignant_neoplasms","SOFA_score")

df_rcs_cox <- df_mimic[!is.na(df_mimic$ICU28_day_dead_time) & !is.na(df_mimic$ICU28_day_dead) & !is.na(df_mimic$NLR), ]

cat("\n==================== Cox‑RCS Sample Information ====================\n")
cat("Valid sample size of MIMIC subset n =", nrow(df_rcs_cox), "\n")

knot_pos_cox <- quantile(df_rcs_cox$NLR, probs = c(0.10, 0.50, 0.90), na.rm = TRUE)
ref_NLR_cox <- knot_pos_cox[2]

cat("Number of knots: 3\n")
cat("Knot quantiles: 10%, 50%, 90%\n")
cat("Knot positions(NLR): ", round(knot_pos_cox,4), "\n")
cat("Reference knot: 2nd knot(P50, median); Reference NLR =", round(ref_NLR_cox,4), "\n")
cat("Model setting: Relative HR = 1 at reference NLR (ref.zero=TRUE)\n")

dd_cox <- datadist(df_rcs_cox)
options(datadist = "dd_cox")

rcs_cox_fit <- cph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~
                     rcs(NLR, knots = knot_pos_cox, ref = 2) + Age + Gender + database + Malignant_neoplasms + SOFA_score,
                   data = df_rcs_cox,
                   x = TRUE,
                   y = TRUE,
                   na.action = na.delete)

rcs_cox_anova <- anova(rcs_cox_fit)
cat("\n==================== ANOVA Test Results (Cox‑RCS) ====================\n")
print(rcs_cox_anova)
anova_cox_df <- as.data.frame(rcs_cox_anova)
p_overall_cox   <- anova_cox_df[1, "P"]
p_nonlinear_cox <- anova_cox_df[2, "P"]
cat(sprintf("\nP‑overall = %.3f; P‑nonlinear = %.3f\n", p_overall_cox, p_nonlinear_cox))

ref_check_cox <- rms::Predict(rcs_cox_fit, NLR = ref_NLR_cox, fun = exp, ref.zero = TRUE)
cat(sprintf("【Validation】Reference NLR=%.2f , relative HR at this point = %.4f\n", ref_check_cox$NLR, ref_check_cox$yhat))

nlr_seq_cox <- seq(min(df_rcs_cox$NLR), max(df_rcs_cox$NLR), length.out = 200)
pred_cox <- rms::Predict(rcs_cox_fit, NLR = nlr_seq_cox, fun = exp, ref.zero = TRUE)

knot_pred_cox <- rms::Predict(rcs_cox_fit, NLR = knot_pos_cox, fun = exp, ref.zero = TRUE)

p_cox_rcs <- ggplot() +
  geom_ribbon(data = pred_cox, aes(x = NLR, ymin = lower, ymax = upper), alpha = 0.2, fill = "#8ecae6") +
  geom_line(data = pred_cox, aes(x = NLR, y = yhat), linewidth = 1, colour = "#947c5b") +
  geom_hline(yintercept = 1, linetype = "solid", colour = "black", linewidth = 0.8) +
  geom_vline(xintercept = ref_NLR_cox, linetype = "dotted", colour = "#c82480", linewidth = 1) +
  geom_point(data = knot_pred_cox, aes(x = NLR, y = yhat), color = "#0033cc", size = 2.2) +
  annotate("text", x = 2, y = 20,
           label = sprintf("P for Overall = %.3f\nP for Nonlinear = %.3f", p_overall_cox, p_nonlinear_cox),
           hjust = 0, size = 3.8) +
  annotate("text", x = ref_NLR_cox, y = 1.4,
           label = sprintf("Ref NLR=%.2f\nHR=1", ref_NLR_cox),
           colour = "#c82480", hjust = 0.5, size = 3.5) +
  labs(x = "NLR",
       y = "Hazard Ratio (95% CI)",
       title = "Cox‑RCS Prediction Plot (MIMIC n=83)") +
  scale_y_continuous(limits = c(0, 22), breaks = c(0,5,10,15,20)) +
  scale_x_continuous(limits = c(0, 45), breaks = c(0,10,20,30,40)) +
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
        axis.title = element_text(size = 13),
        axis.text = element_text(size = 11))
print(p_cox_rcs)
ggsave("Cox_RCS_MIMIC_NLR.png", plot = p_cox_rcs, width = 8, height = 8, dpi = 300)

write.csv(pred_cox, "Cox_RCS_pred_table.csv", row.names = FALSE)
write.csv(as.data.frame(knot_pos_cox), "Cox_RCS_knot_positions.csv", row.names = TRUE)
write.csv(anova_cox_df, "Cox_RCS_ANOVA_result.csv", row.names = TRUE)

options(datadist = NULL)
