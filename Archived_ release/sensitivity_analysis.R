if (!require("readxl"))   install.packages("readxl")
if (!require("survival")) install.packages("survival")
if (!require("broom"))    install.packages("broom")
library(readxl)
library(survival)
library(broom)

df <- read_excel("sensitivity_analysis.xlsx")
df <- df[!is.na(df$database), ]
cat("Total cohort valid n =", nrow(df), "\n")

df$database             <- factor(df$database)
df$hosp_dead            <- as.integer(df$hosp_dead)
df$ICU28_day_dead       <- as.integer(df$ICU28_day_dead)
df$ICU28_day_dead_time  <- as.numeric(df$ICU28_day_dead_time)
df$Age                  <- as.numeric(df$Age)
df$Gender               <- as.numeric(df$Gender)
df$Malignant_neoplasms  <- as.numeric(df$Malignant_neoplasms)
df$SOFA_score           <- as.numeric(df$SOFA_score)
df$NLR                  <- as.numeric(df$NLR)

cat("\n======== Part1 Logistic (n=50, hosp_dead) ========\n")
cat("hosp_dead event count =", sum(df$hosp_dead), "/", nrow(df), "\n")

models_logit <- list(
  "Model1" = "hosp_dead ~ NLR + database",
  "Model2" = "hosp_dead ~ NLR + Age + Gender + database",
  "Model3" = "hosp_dead ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score + database"
)
res_logit_all <- data.frame()
for (m in names(models_logit)) {
  fit <- glm(as.formula(models_logit[[m]]), data = df, family = binomial)
  t <- tidy(fit, exponentiate = TRUE, conf.int = TRUE)
  t$Model <- m
  res_logit_all <- rbind(res_logit_all, t)
}

cat("\n----- Logistic all‑variables OR(95%CI) -----\n")
print(res_logit_all[, c("Model","term","estimate","conf.low","conf.high","p.value")],
      digits = 4, row.names = FALSE)

inter_logit <- data.frame()
for (m in names(models_logit)) {
  base_terms <- switch(m,
    "Model1" = "hosp_dead ~ NLR + database",
    "Model2" = "hosp_dead ~ NLR + database + Age + Gender",
    "Model3" = "hosp_dead ~ NLR + database + Age + Gender + Malignant_neoplasms + SOFA_score")
  fit_int <- glm(as.formula(paste0(base_terms, " + NLR:database")),
                 data = df, family = binomial)
  t <- tidy(fit_int, exponentiate = TRUE, conf.int = TRUE)
  term <- grep("NLR:database", t$term, value = TRUE)[1]
  ti <- t[t$term == term, ]
  inter_logit <- rbind(inter_logit, data.frame(
    Model = m,
    term = term,
    OR_interaction = round(ti$estimate, 3),
    CI = paste0(round(ti$conf.low, 3), "–", round(ti$conf.high, 3)),
    P_interaction = round(ti$p.value, 3)
  ))
}

cat("\n----- NLR × database interaction term OR(95%CI) -----\n")
print(inter_logit, row.names = FALSE)

df_mimic <- subset(df, database == "MIMIC")
cat("\n======== Part2 Cox (MIMIC n=40, 28‑day mortality) ========\n")
cat("ICU28_day_dead event count =", sum(df_mimic$ICU28_day_dead), "/", nrow(df_mimic), "\n")

models_cox <- list(
  "Model1" = "Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR",
  "Model2" = "Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender",
  "Model3" = "Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score"
)
res_cox_all <- data.frame()
for (m in names(models_cox)) {
  fit <- coxph(as.formula(models_cox[[m]]), data = df_mimic)
  t <- tidy(fit, exponentiate = TRUE, conf.int = TRUE)
  t$Model <- m
  res_cox_all <- rbind(res_cox_all, t)
}

cat("\n----- Cox all‑variables HR(95%CI) -----\n")
print(res_cox_all[, c("Model","term","estimate","conf.low","conf.high","p.value")],
      digits = 4, row.names = FALSE)

write.csv(res_logit_all, "sensitivity_logistic_all_vars.csv", row.names = FALSE)
write.csv(inter_logit,   "sensitivity_logistic_interaction.csv", row.names = FALSE)
write.csv(res_cox_all,   "sensitivity_cox_all_vars.csv", row.names = FALSE)
cat("\n==== Results exported as sensitivity_*.csv ====\n")
