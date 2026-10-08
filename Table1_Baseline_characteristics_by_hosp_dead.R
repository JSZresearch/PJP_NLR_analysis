# ============================================================================
# Table 1. Baseline characteristics of survivors and non-survivors


library(readxl)


df <- read_excel("111 cases.xlsx", sheet = "111")


for (cc in colnames(df)) {
  if (is.character(df[[cc]])) {
    df[[cc]][df[[cc]] == "NA"] <- NA_character_
  }
}

g0 <- df$hosp_dead == 0    
g1 <- df$hosp_dead == 1    
n_whole <- nrow(df)
n_sur   <- sum(g0)
n_dead  <- sum(g1)


fmt_msd <- function(x) {
  x <- x[!is.na(x)]
  sprintf("%.1f \u00b1 %.1f", mean(x), sd(x))
}

fmt_miq <- function(x) {
  x <- x[!is.na(x)]
  q <- quantile(x, c(0.25, 0.5, 0.75), names = FALSE, type = 6)
  sprintf("%.1f (%.1f - %.1f)", q[2], q[1], q[3])
}

fmt_np <- function(x, denom) {
  k <- sum(x == 1, na.rm = TRUE)
  sprintf("%d (%.1f%%)", k, 100 * k / denom)
}

race_np <- function(level, mask, denom) {
  k <- sum(df$Race[mask] == level, na.rm = TRUE)
  sprintf("%d (%.1f%%)", k, 100 * k / denom)
}

fmt_p <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) return("<0.001")
  sprintf("%.3f", p)
}

p_welch <- function(var) {
  t.test(df[[var]][g0], df[[var]][g1])$p.value
}

p_chisq_bin <- function(var) {
  tab <- rbind(c(sum(df[[var]][g0] == 1, na.rm = TRUE),
                 sum(df[[var]][g0] == 0, na.rm = TRUE)),
               c(sum(df[[var]][g1] == 1, na.rm = TRUE),
                 sum(df[[var]][g1] == 0, na.rm = TRUE)))
  chisq.test(tab, correct = FALSE)$p.value
}

T1 <- data.frame(Variable = character(), Whole = character(),
                 Survivor = character(), NonSurvivors = character(),
                 P = character(), stringsAsFactors = FALSE)

put <- function(var, whole, sur, dead, p = "") {
  T1 <<- rbind(T1, data.frame(Variable = var, Whole = whole,
                              Survivor = sur, NonSurvivors = dead,
                              P = fmt_p(p), stringsAsFactors = FALSE))
}

# Age（mean ± SD，Welch t）
put("Age, mean \u00b1 SD, year",
    fmt_msd(df$Age), fmt_msd(df$Age[g0]), fmt_msd(df$Age[g1]),
    p_welch("Age"))

# Male（Gender == 1）
put("Male, n (%)",
    fmt_np(df$Gender, n_whole), fmt_np(df$Gender[g0], n_sur),
    fmt_np(df$Gender[g1], n_dead), p_chisq_bin("Gender"))


race_tab <- table(df$Race, df$hosp_dead)
race_p   <- chisq.test(race_tab, correct = FALSE)$p.value
put("Race, n (%)", "", "", "", race_p)
race_lab <- c(WHITE = "White", BLACK = "Black", ASIAN = "Asian",
              HISPANIC = "Hispanic", OTHER = "Other")
for (lv in c("WHITE", "BLACK", "ASIAN", "HISPANIC", "OTHER")) {
  put(paste0("  ", race_lab[[lv]]),
      race_np(lv, rep(TRUE, n_whole), n_whole),
      race_np(lv, g0, n_sur), race_np(lv, g1, n_dead))
}

put("Comorbidities, n (%)", "", "", "")
for (v in c("Hypertension", "Diabetes", "MACE", "Liver_disease",
            "Renal_disease", "Chronic_pulmonary_disease",
            "Malignant_neoplasms", "Organ_transplant",
            "HIV_infection", "CMV_infection")) {
  lab <- switch(v,
                Hypertension              = "Hypertension",
                Diabetes                  = "Diabetes",
                MACE                      = "MACE",
                Liver_disease             = "Liver disease",
                Renal_disease             = "Renal disease",
                Chronic_pulmonary_disease = "Chronic pulmonary disease",
                Malignant_neoplasms       = "Malignant neoplasms",
                Organ_transplant          = "Organ transplant",
                HIV_infection             = "HIV infection",
                CMV_infection             = "CMV infection")
  put(paste0("  ", lab),
      fmt_np(df[[v]], n_whole), fmt_np(df[[v]][g0], n_sur),
      fmt_np(df[[v]][g1], n_dead), p_chisq_bin(v))
}

put("Laboratory results, median (IQR)", "", "", "")
lab_list <- list(
  c("Creatinine",       "Creatinine, mg/dL"),
  c("WBC",             "WBC, 10^9/L"),
  c("RBC",             "RBC, 10^12/L"),
  c("Platelet",        "Platelet, 10^9/L"),
  c("Hemoglobin",      "Hemoglobin, g/dL"),
  c("Lymphocyte_count","Lymphocyte count, 10^9/L"),
  c("Neutrophil_count","Neutrophil count, 10^9/L"),
  c("Monocyte_count",  "Monocyte count, 10^9/L"),
  c("NLR",             "NLR")
)
for (item in lab_list) {
  v <- item[1]; lab <- item[2]
  put(paste0("  ", lab),
      fmt_miq(df[[v]]), fmt_miq(df[[v]][g0]), fmt_miq(df[[v]][g1]),
      p_welch(v))
}

put("Treatment, n (%)", "", "", "")
trt_list <- list(
  c("Glucocorticoids",  "Glucocorticoids"),
  c("Vasopressor",      "Vasopressor"),
  c("Ventilation",      "Ventilation"),
  c("Kidney_dialysis",  "Kidney dialysis")
)
for (item in trt_list) {
  v <- item[1]; lab <- item[2]
  put(paste0("  ", lab),
      fmt_np(df[[v]], n_whole), fmt_np(df[[v]][g0], n_sur),
      fmt_np(df[[v]][g1], n_dead), p_chisq_bin(v))
}

put("Severity evaluation, median (IQR)", "", "", "")
put("  SAPSII score",
    fmt_miq(df$SAPSII_score), fmt_miq(df$SAPSII_score[g0]),
    fmt_miq(df$SAPSII_score[g1]), p_welch("SAPSII_score"))
put("  SOFA score",
    fmt_miq(df$SOFA_score), fmt_miq(df$SOFA_score[g0]),
    fmt_miq(df$SOFA_score[g1]), p_welch("SOFA_score"))

names(T1) <- c("Variable",
               sprintf("Whole cohort (n=%d)", n_whole),
               sprintf("Survivor (n=%d)", n_sur),
               sprintf("Non-survivors (n=%d)", n_dead),
               "P")

print(T1, right = FALSE, row.names = FALSE)
write.csv(T1, "Table1_baseline_by_hosp_dead.csv", row.names = FALSE, fileEncoding = "UTF-8")
cat("\n已保存: Table1_baseline_by_hosp_dead.csv\n")
