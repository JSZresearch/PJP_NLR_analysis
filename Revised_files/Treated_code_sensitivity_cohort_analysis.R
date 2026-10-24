# R version 4.3.1
# Package versions:
# readxl     : 1.4.3
# survival   : 3.5-7
# broom      : 1.0.5
if (!require("readxl"))   install.packages("readxl")
if (!require("survival")) install.packages("survival")
if (!require("broom"))    install.packages("broom")
library(readxl)
library(survival)
library(broom)

df <- read_excel("sensitivity_analysis.xlsx")
df <- df[!is.na(df$database), ]
cat("Total treatment cohort valid n =", nrow(df), "\n")
# MIMIC set as reference, consistent with Table2
df$database             <- factor(df$database, levels = c("MIMIC", "eICU"))
df$hosp_dead            <- as.integer(df$hosp_dead)
df$ICU28_day_dead       <- as.integer(df$ICU28_day_dead)
df$ICU28_day_dead_time  <- as.numeric(df$ICU28_day_dead_time)
df$Age                  <- as.numeric(df$Age)
df$Gender               <- as.numeric(df$Gender)
df$Malignant_neoplasms  <- as.numeric(df$Malignant_neoplasms)
df$SOFA_score           <- as.numeric(df$SOFA_score)
df$NLR                  <- as.numeric(df$NLR)

cat("\n================ Pooled Logistic Model1 (no interaction, n=50, outcome:hosp_dead) ================\n")
logit_mod1_pool <- glm(hosp_dead ~ NLR + database,
                       data = df,
                       family = binomial(link = "logit"))
tidy_logit1_pool <- tidy(logit_mod1_pool, exponentiate = TRUE, conf.int = TRUE)
res_logit1_pool <- tidy_logit1_pool[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_logit1_pool, row.names = FALSE)

cat("\n================ Pooled Logistic Model2 (no interaction, n=50, outcome:hosp_dead) ================\n")
logit_mod2_pool <- glm(hosp_dead ~ NLR + Age + Gender + database,
                       data = df,
                       family = binomial(link = "logit"))
tidy_logit2_pool <- tidy(logit_mod2_pool, exponentiate = TRUE, conf.int = TRUE)
res_logit2_pool <- tidy_logit2_pool[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_logit2_pool, row.names = FALSE)

cat("\n================ Pooled Logistic Model3 (no interaction, n=50, outcome:hosp_dead) ================\n")
logit_mod3_pool <- glm(hosp_dead ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score + database,
                       data = df,
                       family = binomial(link = "logit"))
tidy_logit3_pool <- tidy(logit_mod3_pool, exponentiate = TRUE, conf.int = TRUE)
res_logit3_pool <- tidy_logit3_pool[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_logit3_pool, row.names = FALSE)

write.csv(res_logit1_pool, "treatment_Logistic_Model1_pooled_noInteraction.csv", row.names = FALSE)
write.csv(res_logit2_pool, "treatment_Logistic_Model2_pooled_noInteraction.csv", row.names = FALSE)
write.csv(res_logit3_pool, "treatment_Logistic_Model3_pooled_noInteraction.csv", row.names = FALSE)

#============= Logistic Interaction Models (only for effect modification test, Supplementary) =============
cat("\n================ Logistic Interaction Model1 (n=50, outcome:hosp_dead) ================\n")
logit_mod1_int <- glm(hosp_dead ~ NLR + database + NLR:database,
                      data = df,
                      family = binomial(link = "logit"))
tidy_logit1_int <- tidy(logit_mod1_int, exponentiate = TRUE, conf.int = TRUE)
res_logit1_int <- tidy_logit1_int[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_logit1_int, row.names = FALSE)

cat("\n================ Logistic Interaction Model2 (n=50, outcome:hosp_dead) ================\n")
logit_mod2_int <- glm(hosp_dead ~ NLR + Age + Gender + database + NLR:database,
                      data = df,
                      family = binomial(link = "logit"))
tidy_logit2_int <- tidy(logit_mod2_int, exponentiate = TRUE, conf.int = TRUE)
res_logit2_int <- tidy_logit2_int[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_logit2_int, row.names = FALSE)

cat("\n================ Logistic Interaction Model3 (n=50, outcome:hosp_dead) ================\n")
logit_mod3_int <- glm(hosp_dead ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score + database + NLR:database,
                      data = df,
                      family = binomial(link = "logit"))
tidy_logit3_int <- tidy(logit_mod3_int, exponentiate = TRUE, conf.int = TRUE)
res_logit3_int <- tidy_logit3_int[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_logit3_int, row.names = FALSE)

write.csv(res_logit1_int, "treatment_Logistic_Model1_interaction.csv", row.names = FALSE)
write.csv(res_logit2_int, "treatment_Logistic_Model2_interaction.csv", row.names = FALSE)
write.csv(res_logit3_int, "treatment_Logistic_Model3_interaction.csv", row.names = FALSE)

#============= Cox regression models, restricted to MIMIC subset (n=40), outcome: ICU28_day_dead =============
df_mimic <- subset(df, database == "MIMIC")
str(df_mimic[,c("ICU28_day_dead_time","ICU28_day_dead")])

cat("\n================ Cox Model1 (MIMIC n=40, outcome:ICU28_day_dead) ================\n")
cox_mod1 <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR,
                  data = df_mimic)
tidy_cox1 <- tidy(cox_mod1, exponentiate = TRUE, conf.int = TRUE)
res_cox1 <- tidy_cox1[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_cox1, row.names = FALSE)

cat("\n================ Cox Model2 (MIMIC n=40, outcome:ICU28_day_dead) ================\n")
cox_mod2 <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender,
                  data = df_mimic)
tidy_cox2 <- tidy(cox_mod2, exponentiate = TRUE, conf.int = TRUE)
res_cox2 <- tidy_cox2[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_cox2, row.names = FALSE)

cat("\n================ Cox Model3 (MIMIC n=40, outcome:ICU28_day_dead) ================\n")
cox_mod3 <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score,
                  data = df_mimic)
tidy_cox3 <- tidy(cox_mod3, exponentiate = TRUE, conf.int = TRUE)
res_cox3 <- tidy_cox3[, c("term", "estimate", "conf.low", "conf.high", "p.value")]
print(res_cox3, row.names = FALSE)

write.csv(res_cox1, "treatment_Cox_Model1_MIMIC_ICU28.csv", row.names = FALSE)
write.csv(res_cox2, "treatment_Cox_Model2_MIMIC_ICU28.csv", row.names = FALSE)
write.csv(res_cox3, "treatment_Cox_Model3_MIMIC_ICU28.csv", row.names = FALSE)

#============= PH assumption test & Schoenfeld residual plots =============
ph_test1 <- cox.zph(cox_mod1)
ph_test2 <- cox.zph(cox_mod2)
ph_test3 <- cox.zph(cox_mod3)
cat("\n============ Cox Model1 Proportional‑hazards assumption test ============\n")
print(ph_test1)
cat("\n============ Cox Model2 Proportional‑hazards assumption test ============\n")
print(ph_test2)
cat("\n============ Cox Model3 Proportional‑hazards assumption test ============\n")
print(ph_test3)

ph_df1 <- as.data.frame(ph_test1$table)
ph_df2 <- as.data.frame(ph_test2$table)
ph_df3 <- as.data.frame(ph_test3$table)
write.csv(ph_df1, "treatment_Cox_PHtest_Model1.csv", row.names = TRUE)
write.csv(ph_df2, "treatment_Cox_PHtest_Model2.csv", row.names = TRUE)
write.csv(ph_df3, "treatment_Cox_PHtest_Model3.csv", row.names = TRUE)

# Schoenfeld residual plots
par(mfrow = c(2,2))
plot(ph_test1)
par(mfrow = c(1,1))
par(mfrow = c(2,3))
plot(ph_test2)
par(mfrow = c(1,1))
par(mfrow = c(3,3))
plot(ph_test3)
par(mfrow = c(1,1))

#============= Format OR/HR (95%CI) + p-value table for manuscript (consistent function) =============
format_tab <- function(df){
  df$est_ci <- paste0(sprintf("%.2f", df$estimate),
                      "(", sprintf("%.2f", df$conf.low), "‑", sprintf("%.2f", df$conf.high), ")")
  df$p_fmt <- ifelse(df$p.value < 0.001, "<0.001", sprintf("%.3f", df$p.value))
  return(df[, c("term", "est_ci", "p_fmt")])
}

logit1_pool_fmt <- format_tab(res_logit1_pool)
logit2_pool_fmt <- format_tab(res_logit2_pool)
logit3_pool_fmt <- format_tab(res_logit3_pool)

logit1_int_fmt <- format_tab(res_logit1_int)
logit2_int_fmt <- format_tab(res_logit2_int)
logit3_int_fmt <- format_tab(res_logit3_int)

cox1_fmt  <- format_tab(res_cox1)
cox2_fmt  <- format_tab(res_cox2)
cox3_fmt  <- format_tab(res_cox3)

write.csv(logit1_pool_fmt, "treatment_Logit1_pooled_formatted.csv", row.names = FALSE)
write.csv(logit2_pool_fmt, "treatment_Logit2_pooled_formatted.csv", row.names = FALSE)
write.csv(logit3_pool_fmt, "treatment_Logit3_pooled_formatted.csv", row.names = FALSE)

write.csv(logit1_int_fmt, "treatment_Logit1_interaction_formatted.csv", row.names = FALSE)
write.csv(logit2_int_fmt, "treatment_Logit2_interaction_formatted.csv", row.names = FALSE)
write.csv(logit3_int_fmt, "treatment_Logit3_interaction_formatted.csv", row.names = FALSE)

write.csv(cox1_fmt,  "treatment_Cox1_formatted.csv", row.names = FALSE)
write.csv(cox2_fmt,  "treatment_Cox2_formatted.csv", row.names = FALSE)
write.csv(cox3_fmt,  "treatment_Cox3_formatted.csv", row.names = FALSE)
