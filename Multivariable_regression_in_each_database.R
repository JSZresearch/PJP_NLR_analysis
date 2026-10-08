if (!require("readxl")) install.packages("readxl")
if (!require("broom")) install.packages("broom")
library(readxl)
library(broom)

df <- read_excel("111 cases.xlsx")
df$database <- factor(df$database, levels = c("MIMIC","eICU"))

df_mimic <- subset(df, database == "MIMIC")
df_eicu  <- subset(df, database == "eICU")

run_logistic_three_models <- function(dat, cohort_name){
  cat(sprintf("\n========== %s cohort logistic regression (outcome: hosp_dead) ==========\n", cohort_name))
  
  mod1 <- glm(hosp_dead ~ NLR,
              data = dat,
              family = binomial(link = "logit"))
  
  mod2 <- glm(hosp_dead ~ NLR + Age + Gender,
              data = dat,
              family = binomial(link = "logit"))
  
  mod3 <- glm(hosp_dead ~ NLR + Age + Gender + Malignant_neoplasms + SOFA_score,
              data = dat,
              family = binomial(link = "logit"))
  
  res1 <- tidy(mod1, exponentiate = TRUE, conf.int = TRUE)
  res1 <- res1[, c("term","estimate","conf.low","conf.high","p.value")]
  res2 <- tidy(mod2, exponentiate = TRUE, conf.int = TRUE)
  res2 <- res2[, c("term","estimate","conf.low","conf.high","p.value")]
  res3 <- tidy(mod3, exponentiate = TRUE, conf.int = TRUE)
  res3 <- res3[, c("term","estimate","conf.low","conf.high","p.value")]

  cat("----- Model 1: NLR -----\n")
  print(res1, row.names = FALSE)
  cat("----- Model 2: NLR + Age + Gender -----\n")
  print(res2, row.names = FALSE)
  cat("----- Model 3: NLR + Age + Gender + Malignant_neoplasms + SOFA_score -----\n")
  print(res3, row.names = FALSE)
  
  return(list(model1 = mod1, res1 = res1,
              model2 = mod2, res2 = res2,
              model3 = mod3, res3 = res3))
}

res_mimic <- run_logistic_three_models(df_mimic, "MIMIC")
res_eicu  <- run_logistic_three_models(df_eicu,  "eICU")

write.csv(res_mimic$res1, "MIMIC_Model1_logistic.csv", row.names = FALSE)
write.csv(res_mimic$res2, "MIMIC_Model2_logistic.csv", row.names = FALSE)
write.csv(res_mimic$res3, "MIMIC_Model3_logistic.csv", row.names = FALSE)
write.csv(res_eicu$res1, "eICU_Model1_logistic.csv", row.names = FALSE)
write.csv(res_eicu$res2, "eICU_Model2_logistic.csv", row.names = FALSE)
write.csv(res_eicu$res3, "eICU_Model3_logistic.csv", row.names = FALSE)

format_logit_tab <- function(df){
  df$or_ci <- paste0(sprintf("%.2f", df$estimate),
                     "(", sprintf("%.2f", df$conf.low), "‑", sprintf("%.2f", df$conf.high), ")")
  df$p_fmt <- ifelse(df$p.value < 0.001, "<0.001", sprintf("%.3f", df$p.value))
  return(df[,c("term","or_ci","p_fmt")])
}

mimic1_fmt <- format_logit_tab(res_mimic$res1)
mimic2_fmt <- format_logit_tab(res_mimic$res2)
mimic3_fmt <- format_logit_tab(res_mimic$res3)
eicu1_fmt  <- format_logit_tab(res_eicu$res1)
eicu2_fmt  <- format_logit_tab(res_eicu$res2)
eicu3_fmt  <- format_logit_tab(res_eicu$res3)

write.csv(mimic1_fmt, "MIMIC_Model1_formatted.csv", row.names = FALSE)
write.csv(mimic2_fmt, "MIMIC_Model2_formatted.csv", row.names = FALSE)
write.csv(mimic3_fmt, "MIMIC_Model3_formatted.csv", row.names = FALSE)
write.csv(eicu1_fmt,  "eICU_Model1_formatted.csv", row.names = FALSE)
write.csv(eicu2_fmt,  "eICU_Model2_formatted.csv", row.names = FALSE)
write.csv(eicu3_fmt,  "eICU_Model3_formatted.csv", row.names = FALSE)
