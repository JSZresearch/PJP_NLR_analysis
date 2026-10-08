if (!require("readxl")) install.packages("readxl")
if (!require("survival")) install.packages("survival")
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("broom")) install.packages("broom")
library(readxl)
library(survival)
library(ggplot2)
library(broom)

df <- read_excel("111 cases.xlsx")
df_mimic <- subset(df, database == "MIMIC")
df_mimic$ICU28_day_dead_time <- as.numeric(df_mimic$ICU28_day_dead_time)
df_mimic$ICU28_day_dead <- as.numeric(df_mimic$ICU28_day_dead)

fit_logit <- glm(hosp_dead ~ NLR + Age + Gender,
                 data = df,
                 family = binomial(link = "logit"))
cook_dist <- cooks.distance(fit_logit)
complete_idx_logit <- as.integer(names(cook_dist))
df_logit_inf <- df[complete_idx_logit, ]
df_logit_inf$cook_d <- cook_dist
df_logit_inf$is_influential <- ifelse(df_logit_inf$cook_d > 1, 1, 0)

cat("================ Logistic regression Influential points (Cook distance>1) ================\n")
inf_points_logit <- subset(df_logit_inf, is_influential == 1)
print(inf_points_logit[, c("subject_id","NLR","Age","Gender","hosp_dead","cook_d")])

p_cook <- ggplot(df_logit_inf, aes(x = 1:nrow(df_logit_inf), y = cook_d)) +
  geom_point(aes(color = factor(is_influential)), size = 2) +
  geom_hline(yintercept = 1, linetype = "dashed", colour = "red") +
  labs(x = "Observation index", y = "Cook's distance",
       title = "Influence analysis: Logistic regression (hosp_dead)") +
  scale_color_manual(values = c("0"="black","1"="red"), labels = c("Normal","Influential")) +
  theme_bw()
print(p_cook)
ggsave("Logistic_CookDistance.png", plot = p_cook, width = 7, height = 4)

write.csv(df_logit_inf[,c("subject_id","NLR","Age","Gender","hosp_dead","cook_d","is_influential")],
          "Logistic_Influence_Result.csv", row.names = FALSE)

if(nrow(inf_points_logit) > 0){
  df_logit_noinf <- subset(df_logit_inf, is_influential == 0)
  fit_logit_noinf <- glm(hosp_dead ~ NLR + Age + Gender,
                         data = df_logit_noinf,
                         family = binomial(link = "logit"))
  cat("\n------ Logistic model results after removing influential points (OR,95%CI,P) ------\n")
  res_logit_noinf <- tidy(fit_logit_noinf, exponentiate = TRUE, conf.int = TRUE)
  print(res_logit_noinf[,c("term","estimate","conf.low","conf.high","p.value")])
  write.csv(res_logit_noinf, "Logit_after_remove_influential.csv", row.names = FALSE)
}else{
  cat("\n>>> Logistic regression: No influential samples with Cook distance > 1 detected\n")
}

fit_cox <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender, data = df_mimic)
base_hr_nlr <- exp(coef(fit_cox)["NLR"])
cat("\n>>> Original Cox model NLR HR = ", round(base_hr_nlr,3),"\n")

ok_idx <- complete.cases(df_mimic[,c("ICU28_day_dead_time","ICU28_day_dead","NLR","Age","Gender")])
dat_cox_valid <- df_mimic[ok_idx, ]
n_valid <- nrow(dat_cox_valid)

loo_result <- data.frame(
  subject_id = integer(n_valid),
  NLR = numeric(n_valid),
  hr_NLR_loo = numeric(n_valid),
  hr_abs_change = numeric(n_valid)
)

for (i in seq_len(n_valid)) {
  dat_temp <- dat_cox_valid[-i, ]
  fit_temp <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender, data = dat_temp)
  loo_result$subject_id[i] <- dat_cox_valid$subject_id[i]
  loo_result$NLR[i] <- dat_cox_valid$NLR[i]
  loo_result$hr_NLR_loo[i] <- exp(coef(fit_temp)["NLR"])
  loo_result$hr_abs_change[i] <- abs(exp(coef(fit_temp)["NLR"]) - base_hr_nlr)
}

loo_result$is_influential <- ifelse(loo_result$hr_abs_change > 0.5, 1, 0)
cat("\n================ Cox regression Leave‑one‑out sensitivity analysis ================\n")
high_inf <- subset(loo_result, is_influential ==1)
print(high_inf)
write.csv(loo_result, "Cox_LOO_sensitivity_result.csv", row.names = FALSE)

p_loo <- ggplot(loo_result, aes(x = seq_len(n_valid), y = hr_NLR_loo)) +
  geom_point(size=1.5, aes(color = factor(is_influential))) +
  geom_hline(yintercept = base_hr_nlr, linetype="dashed", color="red") +
  labs(x="Observation index", y="NLR hazard ratio after leave‑one‑out",
       title="Cox leave‑one‑out sensitivity analysis") +
  scale_color_manual(values=c("0"="black","1"="red"),labels=c("Normal","High‑influence")) +
  theme_bw()
print(p_loo)
ggsave("Cox_LOO_plot.png", width=7, height=4)

if(nrow(high_inf)>0){
  ids_remove <- high_inf$subject_id
  dat_noinf <- subset(dat_cox_valid, !(subject_id %in% ids_remove))
  fit_cox_noinf <- coxph(Surv(ICU28_day_dead_time, ICU28_day_dead) ~ NLR + Age + Gender, data = dat_noinf)
  cat("\n------ Cox model results after removing high‑influence samples (HR,95%CI,P) ------\n")
  res_cox_noinf <- tidy(fit_cox_noinf, exponentiate = TRUE, conf.int = TRUE)
  print(res_cox_noinf[,c("term","estimate","conf.low","conf.high","p.value")])
  write.csv(res_cox_noinf, "Cox_after_remove_high_influential.csv", row.names = FALSE)
}else{
  cat("\n>>> Cox leave‑one‑out sensitivity analysis: No high‑influence samples detected, small HR fluctuation, robust results\n")
}
