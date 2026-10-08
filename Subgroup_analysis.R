if (!require("readxl")) install.packages("readxl")
if (!require("broom")) install.packages("broom")
library(readxl)
library(broom)

df <- read_excel("111 cases.xlsx")
colnames(df)

df$Age_cat     <- ifelse(df$Age < 65, "<65", "≥65")
df$SAPSII_cat  <- ifelse(df$SAPSII_score < 35, "<35", "≥35")
df$SOFA_cat    <- ifelse(df$SOFA_score < 5, "<5", "≥5")

subgroup_list <- list(
  c("Age_cat","Age"),
  c("Gender","Gender"),
  c("Malignant_neoplasms","Malignant neoplasms"),
  c("HIV_infection","HIV infection"),
  c("SAPSII_cat","SAPSII score"),
  c("SOFA_cat","SOFA score")
)
sub_res <- data.frame()
inter_res <- data.frame()

for (i in seq_along(subgroup_list)){
  var_raw <- subgroup_list[[i]][1]
  var_label <- subgroup_list[[i]][2]
  
  lev <- unique(df[[var_raw]])
  lev <- sort(lev)
  
  for(g in lev){
    dat_sub <- df[df[[var_raw]] == g & !is.na(df$NLR) & !is.na(df$hosp_dead), ]
    n <- nrow(dat_sub)
    if(n < 5) next
    
    fit <- glm(hosp_dead ~ NLR, data = dat_sub, family = binomial)
    t <- tidy(fit, exponentiate = TRUE, conf.int = TRUE)
    t_nlr <- t[t$term == "NLR", ]
    
    sub_res <- rbind(sub_res, data.frame(
      Variable = var_label,
      Subgroup = g,
      Count = n,
      Percent = round(n/nrow(df)*100,1),
      P_value = round(t_nlr$p.value,3),
      OR = round(t_nlr$estimate,3),
      Lower = round(t_nlr$conf.low,3),
      Upper = round(t_nlr$conf.high,3)
    ))
  }
  
  form_int <- as.formula(paste0("hosp_dead ~ NLR + ",var_raw," + NLR:",var_raw))
  fit_int <- glm(form_int, data = df, family = binomial)
  anov <- anova(fit_int, test = "LRT")
  p_inter <- anov$`Pr(>Chi)`[rownames(anov) == paste0("NLR:",var_raw)]
  
  inter_res <- rbind(inter_res, data.frame(
    Variable = var_label,
    P_for_interaction = round(p_inter,3)
  ))
}

fit_overall <- glm(hosp_dead ~ NLR, data = df, family = binomial)
t_overall <- tidy(fit_overall, exponentiate = TRUE, conf.int = TRUE)
t_nlr_overall <- t_overall[t_overall$term=="NLR", ]
overall_row <- data.frame(
  Variable="Overall",
  Subgroup="",
  Count=111,
  Percent=100,
  P_value=round(t_nlr_overall$p.value,3),
  OR=round(t_nlr_overall$estimate,3),
  Lower=round(t_nlr_overall$conf.low,3),
  Upper=round(t_nlr_overall$conf.high,3)
)
final_table <- rbind(overall_row, sub_res)
final_table <- merge(final_table, inter_res, by="Variable", all.x = TRUE)
write.csv(final_table, "NLR_subgroup_logistic_result.csv", row.names = FALSE)
cat("===== Subgroup Result Table =====\n")
print(final_table)
cat("\n==== Interaction P-values ====\n")
print(inter_res)

if (!require("readxl")) install.packages("readxl")
if (!require("survival")) install.packages("survival")
if (!require("broom")) install.packages("broom")
library(readxl)
library(survival)
library(broom)

df <- read_excel("111 cases.xlsx")
df_mimic <- subset(df, database == "MIMIC")

df_mimic$ICU28_day_dead_time <- as.numeric(df_mimic$ICU28_day_dead_time)
df_mimic$ICU28_day_dead <- as.numeric(df_mimic$ICU28_day_dead)

df_mimic$Age_cat     <- ifelse(df_mimic$Age < 65, "<65", "≥65")
df_mimic$SAPSII_cat  <- ifelse(df_mimic$SAPSII_score < 35, "<35", "≥35")
df_mimic$SOFA_cat    <- ifelse(df_mimic$SOFA_score < 5, "<5", "≥5")

subgroup_list <- list(
  c("Age_cat","Age"),
  c("Gender","Gender"),
  c("Malignant_neoplasms","Malignant neoplasms"),
  c("HIV_infection","HIV infection"),
  c("SAPSII_cat","SAPSII score"),
  c("SOFA_cat","SOFA score")
)
sub_res_cox <- data.frame()
inter_res_cox <- data.frame()

for (i in seq_along(subgroup_list)){
  var_raw <- subgroup_list[[i]][1]
  var_label <- subgroup_list[[i]][2]
  
  lev <- unique(df_mimic[[var_raw]])
  lev <- sort(lev)
  
  for(g in lev){
    dat_sub <- df_mimic[df_mimic[[var_raw]] == g & !is.na(df_mimic$NLR) & 
                          !is.na(df_mimic$ICU28_day_dead_time) & !is.na(df_mimic$ICU28_day_dead), ]
    n <- nrow(dat_sub)
    if(n < 5) next
    
    fit <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR, data = dat_sub)
    t <- tidy(fit, exponentiate = TRUE, conf.int = TRUE)
    t_nlr <- t[t$term == "NLR", ]
    
    sub_res_cox <- rbind(sub_res_cox, data.frame(
      Variable = var_label,
      Subgroup = g,
      Count = n,
      Percent = round(n/nrow(df_mimic)*100,1),
      P_value = round(t_nlr$p.value,3),
      HR = round(t_nlr$estimate,3),
      Lower = round(t_nlr$conf.low,3),
      Upper = round(t_nlr$conf.high,3)
    ))
  }
  
  form_int <- as.formula(paste0("Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + ",var_raw," + NLR:",var_raw))
  fit_int <- coxph(form_int, data = df_mimic)
  anov <- anova(fit_int, test = "LRT")
  p_inter <- anov$`Pr(>Chi)`[rownames(anov) == paste0("NLR:",var_raw)]
  
  inter_res_cox <- rbind(inter_res_cox, data.frame(
    Variable = var_label,
    P_for_interaction = round(p_inter,3)
  ))
}

fit_overall_cox <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR, data = df_mimic)
t_overall <- tidy(fit_overall_cox, exponentiate = TRUE, conf.int = TRUE)
t_nlr_overall <- t_overall[t_overall$term=="NLR", ]
overall_row_cox <- data.frame(
  Variable="Overall",
  Subgroup="",
  Count=83,
  Percent=100,
  P_value=round(t_nlr_overall$p.value,3),
  HR=round(t_nlr_overall$estimate,3),
  Lower=round(t_nlr_overall$conf.low,3),
  Upper=round(t_nlr_overall$conf.high,3)
)
final_table_cox <- rbind(overall_row_cox, sub_res_cox)
final_table_cox <- merge(final_table_cox, inter_res_cox, by="Variable", all.x = TRUE)

write.csv(final_table_cox, "MIMIC_NLR_subgroup_cox_result.csv", row.names = FALSE)
cat("===== MIMIC cohort Cox Subgroup Analysis Result Table =====\n")
print(final_table_cox)
cat("\n==== MIMIC cohort Interaction P-values =====\n")
print(inter_res_cox)
