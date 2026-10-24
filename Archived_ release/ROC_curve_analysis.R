if (!require("readxl")) install.packages("readxl")
if (!require("pROC")) install.packages("pROC")
if (!require("tableone")) install.packages("tableone")

library(readxl)
library(pROC)
library(tableone)

df <- read_excel("111 cases.xlsx")
df_complete <- df[!is.na(df$NLR) & !is.na(df$hosp_dead) &
                    !is.na(df$SAPSII_score) & !is.na(df$SOFA_score), ]

# NLR
fit_nlr <- glm(hosp_dead ~ NLR, data = df_complete, family = binomial(link = "logit"))
prob_nlr <- predict(fit_nlr, type = "response")
# SAPSII_score
fit_saps <- glm(hosp_dead ~ SAPSII_score, data = df_complete, family = binomial(link = "logit"))
prob_saps <- predict(fit_saps, type = "response")
# SOFA_score
fit_sofa <- glm(hosp_dead ~ SOFA_score, data = df_complete, family = binomial(link = "logit"))
prob_sofa <- predict(fit_sofa, type = "response")

roc_nlr <- roc(df_complete$hosp_dead, prob_nlr)
roc_saps <- roc(df_complete$hosp_dead, prob_saps)
roc_sofa <- roc(df_complete$hosp_dead, prob_sofa)

cat("==================== ROC AUC results ====================\n")
cat(sprintf("NLR: AUC = %.3f (95%%CI: %.3f‑%.3f)\n",
            auc(roc_nlr), ci(roc_nlr)[1], ci(roc_nlr)[3]))
cat(sprintf("SAPSII_score: AUC = %.3f (95%%CI: %.3f‑%.3f)\n",
            auc(roc_saps), ci(roc_saps)[1], ci(roc_saps)[3]))
cat(sprintf("SOFA_score: AUC = %.3f (95%%CI: %.3f‑%.3f)\n",
            auc(roc_sofa), ci(roc_sofa)[1], ci(roc_sofa)[3]))

delong_nlr_saps <- roc.test(roc_nlr, roc_saps, method = "delong")
delong_nlr_sofa <- roc.test(roc_nlr, roc_sofa, method = "delong")

cat("\n==================== DeLong test for paired ROC curves ====================\n")
cat("----- NLR vs SAPSII_score -----\n")
print(delong_nlr_saps)
cat("\n----- NLR vs SOFA_score -----\n")
print(delong_nlr_sofa)

auc_res <- data.frame(
  Variable = c("NLR","SAPSII_score","SOFA_score"),
  AUC = c(as.numeric(auc(roc_nlr)), as.numeric(auc(roc_saps)), as.numeric(auc(roc_sofa))),
  CI_lower = c(ci(roc_nlr)[1], ci(roc_saps)[1], ci(roc_sofa)[1]),
  CI_upper = c(ci(roc_nlr)[3], ci(roc_saps)[3], ci(roc_sofa)[3])
)

delong_res <- data.frame(
  Comparison = c("NLR vs SAPSII_score","NLR vs SOFA_score"),
  Z_statistic = c(delong_nlr_saps$statistic, delong_nlr_sofa$statistic),
  P_value = c(delong_nlr_saps$p.value, delong_nlr_sofa$p.value)
)

write.csv(auc_res, "ROC_AUC_results.csv", row.names = FALSE)
write.csv(delong_res, "DeLong_test_results.csv", row.names = FALSE)

png("ROC_curve.png", width = 800, height = 800)
plot(roc_nlr, col="#E74C3C", lwd=2, main="ROC curves for predicting in‑hospital mortality(hosp_dead)")
plot(roc_saps, col="#3498DB", lwd=2, add=TRUE)
plot(roc_sofa, col="#27AE60", lwd=2, add=TRUE)
legend("bottomright",
       legend=c(paste0("NLR(AUC=",sprintf("%.3f",auc(roc_nlr)),")"),
                paste0("SAPSII_score(AUC=",sprintf("%.3f",auc(roc_saps)),")"),
                paste0("SOFA_score(AUC=",sprintf("%.3f",auc(roc_sofa)),")")),
       col=c("#E74C3C","#3498DB","#27AE60"), lwd=2)
dev.off()

roc_nlr_raw <- roc(df_complete$hosp_dead, df_complete$NLR)
youden_obj <- coords(roc_nlr_raw, x = "best", best.method = "youden",
                     ret = c("threshold","sensitivity","specificity","youden",
                             "tp","tn","fp","fn"))

opt_cutoff <- youden_obj$threshold
sens <- youden_obj$sensitivity
spec <- youden_obj$specificity
youden_val <- youden_obj$youden

tp <- youden_obj$tp
fn <- youden_obj$fn
tn <- youden_obj$tn
fp <- youden_obj$fp

ci_sens <- binom.test(tp, tp+fn)$conf.int
ci_spec <- binom.test(tn, tn+fp)$conf.int

cat("\n============ NLR optimal cut‑off value by Youden index ============\n")
print(youden_obj)
cat(sprintf("\nOptimal NLR cut‑off = %.2f\n", opt_cutoff))
cat(sprintf("Sensitivity = %.3f (95%%CI: %.3f‑%.3f)\n", sens, ci_sens[1], ci_sens[2]))
cat(sprintf("Specificity = %.3f (95%%CI: %.3f‑%.3f)\n", spec, ci_spec[1], ci_spec[2]))
cat(sprintf("Youden index = %.3f\n", youden_val))

youden_res <- data.frame(
  Variable = "NLR",
  Optimal_cutoff = opt_cutoff,
  Sensitivity = sens,
  Sens_CI_lower = ci_sens[1],
  Sens_CI_upper = ci_sens[2],
  Specificity = spec,
  Spec_CI_lower = ci_spec[1],
  Spec_CI_upper = ci_spec[2],
  Youden_index = youden_val,
  TP=tp, TN=tn, FP=fp, FN=fn
)
write.csv(youden_res, "NLR_Youden_cutoff.csv", row.names = FALSE)

df_complete$NLR_high <- ifelse(df_complete$NLR >= opt_cutoff, 1, 0)


df <- read_excel("111 cases.xlsx")
df$NLR_group <- ifelse(df$NLR > opt_cutoff, paste0("NLR > ",sprintf("%.2f",opt_cutoff)),
                       paste0("NLR ≤ ",sprintf("%.2f",opt_cutoff)))
df$NLR_group <- factor(df$NLR_group, levels = c(paste0("NLR ≤ ",sprintf("%.2f",opt_cutoff)),
                                                 paste0("NLR > ",sprintf("%.2f",opt_cutoff))))

cont_vars <- c("Age","Weight","LDH","Creatinine","WBC","RBC","Platelet",
               "Hemoglobin","Albumin","Lymphocyte_count","Neutrophil_count",
               "Monocyte_count","NLR","SAPSII_score","SOFA_score")

cat_vars <- c("Gender","Hypertension","Diabetes","MACE","Liver_disease",
              "Renal_disease","Chronic_pulmonary_disease","Malignant_neoplasms",
              "Organ_transplant","HIV_infection","CMV_infection",
              "Glucocorticoids","Vasopressor","Ventilation","Kidney_dialysis","hosp_dead")

all_vars <- c(cont_vars, cat_vars)

table1_obj <- CreateTableOne(
  vars = all_vars,
  factorVars = cat_vars,
  strata = "NLR_group",
  data = df,
  test = TRUE,
  addOverall = TRUE
)

cat("\n============== Baseline characteristics stratified by NLR optimal cut‑off ==============\n")
print(table1_obj, showAllLevels = FALSE, nonnormal = cont_vars)

table1_csv <- print(table1_obj, showAllLevels = FALSE, nonnormal = cont_vars, output = "csv")
writeLines(table1_csv, "Table1_NLRcut.csv")
