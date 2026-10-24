if (!require("readxl")) install.packages("readxl")
if (!require("survival")) install.packages("survival")
if (!require("broom")) install.packages("broom")
library(readxl)
library(survival)
library(broom)

df <- read_excel("111 cases.xlsx")

df$ICU28_day_dead_time <- as.numeric(df$ICU28_day_dead_time)
df$ICU28_day_dead <- as.numeric(df$ICU28_day_dead)

df$database <- factor(df$database, levels = c("MIMIC", "eICU"))

df_mimic <- subset(df, database == "MIMIC")

str(df_mimic[,c("ICU28_day_dead_time","ICU28_day_dead")])

logit_mod1 <- glm(hosp_dead ~ NLR + database + NLR:database,
                  data = df,
                  family = binomial(link = "logit"))

logit_mod2 <- glm(hosp_dead ~ NLR + Age + Gender + database + NLR:database,
                  data = df,
                  family = binomial(link = "logit"))

logit_mod3 <- glm(hosp_dead ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score + database + NLR:database,
                  data = df,
                  family = binomial(link = "logit"))

tidy_logit1 <- tidy(logit_mod1, exponentiate = TRUE, conf.int = TRUE)
res_logit1 <- tidy_logit1[, c("term", "estimate", "conf.low", "conf.high", "p.value")]

tidy_logit2 <- tidy(logit_mod2, exponentiate = TRUE, conf.int = TRUE)
res_logit2 <- tidy_logit2[, c("term", "estimate", "conf.low", "conf.high", "p.value")]

tidy_logit3 <- tidy(logit_mod3, exponentiate = TRUE, conf.int = TRUE)
res_logit3 <- tidy_logit3[, c("term", "estimate", "conf.low", "conf.high", "p.value")]

cat("================ Logistic Model1 (n=111, outcome:hosp_dead) ================\n")
print(res_logit1, row.names = FALSE)
cat("\n================ Logistic Model2 (n=111, outcome:hosp_dead) ================\n")
print(res_logit2, row.names = FALSE)
cat("\n================ Logistic Model3 (n=111, outcome:hosp_dead) ================\n")
print(res_logit3, row.names = FALSE)

write.csv(res_logit1, "Logistic_Model1_interaction.csv", row.names = FALSE)
write.csv(res_logit2, "Logistic_Model2_interaction.csv", row.names = FALSE)
write.csv(res_logit3, "Logistic_Model3_interaction.csv", row.names = FALSE)


cox_mod1 <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR,
                  data = df_mimic)

cox_mod2 <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender,
                  data = df_mimic)

cox_mod3 <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score,
                  data = df_mimic)

tidy_cox1 <- tidy(cox_mod1, exponentiate = TRUE, conf.int = TRUE)
res_cox1 <- tidy_cox1[, c("term", "estimate", "conf.low", "conf.high", "p.value")]

tidy_cox2 <- tidy(cox_mod2, exponentiate = TRUE, conf.int = TRUE)
res_cox2 <- tidy_cox2[, c("term", "estimate", "conf.low", "conf.high", "p.value")]

tidy_cox3 <- tidy(cox_mod3, exponentiate = TRUE, conf.int = TRUE)
res_cox3 <- tidy_cox3[, c("term", "estimate", "conf.low", "conf.high", "p.value")]

cat("\n================ Cox Model1 (MIMIC n=83, outcome:ICU28_day_dead) ================\n")
print(res_cox1, row.names = FALSE)
cat("\n================ Cox Model2 (MIMIC n=83, outcome:ICU28_day_dead) ================\n")
print(res_cox2, row.names = FALSE)
cat("\n================ Cox Model3 (MIMIC n=83, outcome:ICU28_day_dead) ================\n")
print(res_cox3, row.names = FALSE)

write.csv(res_cox1, "Cox_Model1_MIMIC_ICU28.csv", row.names = FALSE)
write.csv(res_cox2, "Cox_Model2_MIMIC_ICU28.csv", row.names = FALSE)
write.csv(res_cox3, "Cox_Model3_MIMIC_ICU28.csv", row.names = FALSE)

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
write.csv(ph_df1, "Cox_PHtest_Model1.csv", row.names = TRUE)
write.csv(ph_df2, "Cox_PHtest_Model2.csv", row.names = TRUE)
write.csv(ph_df3, "Cox_PHtest_Model3.csv", row.names = TRUE)

par(mfrow = c(2,2))
plot(ph_test1)
par(mfrow = c(1,1))

par(mfrow = c(2,3))
plot(ph_test2)
par(mfrow = c(1,1))

par(mfrow = c(3,3))
plot(ph_test3)
par(mfrow = c(1,1))

format_tab <- function(df){
  df$est_ci <- paste0(sprintf("%.2f", df$estimate),
                      "(", sprintf("%.2f", df$conf.low), "‑", sprintf("%.2f", df$conf.high), ")")
  df$p_fmt <- ifelse(df$p.value < 0.001, "<0.001", sprintf("%.3f", df$p.value))
  return(df[, c("term", "est_ci", "p_fmt")])
}

logit1_fmt <- format_tab(res_logit1)
logit2_fmt <- format_tab(res_logit2)
logit3_fmt <- format_tab(res_logit3)

cox1_fmt  <- format_tab(res_cox1)
cox2_fmt  <- format_tab(res_cox2)
cox3_fmt  <- format_tab(res_cox3)

write.csv(logit1_fmt, "Logit1_formatted.csv", row.names = FALSE)
write.csv(logit2_fmt, "Logit2_formatted.csv", row.names = FALSE)
write.csv(logit3_fmt, "Logit3_formatted.csv", row.names = FALSE)

write.csv(cox1_fmt,  "Cox1_formatted.csv", row.names = FALSE)
write.csv(cox2_fmt,  "Cox2_formatted.csv", row.names = FALSE)
write.csv(cox3_fmt,  "Cox3_formatted.csv", row.names = FALSE)
