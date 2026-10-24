if (!require("readxl")) install.packages("readxl")
library(readxl)

format_p <- function(p) {
  if (is.na(p)) return(NA)
  if (p < 0.001) return("<0.001")
  sprintf("%.3f", p)
}

mean_sd <- function(x) {
  m <- mean(x, na.rm = TRUE)
  s <- sd(x, na.rm = TRUE)
  paste0(sprintf("%.1f",m),"±",sprintf("%.1f",s))
}

med_iqr <- function(x){
  q <- quantile(x, probs = c(0.25,0.5,0.75), na.rm = TRUE, type = 6)
  paste0(sprintf("%.2f",q[2])," (",sprintf("%.2f",q[1]),"–",sprintf("%.2f",q[3]),")")
}

p_welch_t <- function(x,y){
  tt <- t.test(x,y, na.action = na.omit)
  tt$p.value
}

p_chisq_no_yates <- function(tab){
  ch <- chisq.test(tab, correct = FALSE)
  ch$p.value
}

cat_npct <- function(x){
  tb <- table(x, useNA = "no")
  n0 <- tb[["0"]]; n1 <- tb[["1"]]
  total <- sum(tb)
  paste0(n1," (",sprintf("%.1f",100*n1/total),"%)")
}

var_cont_mean <- c("Age")
var_cont_medi <- c("Weight","LDH","Creatinine","WBC","RBC","Platelet",
                   "Hemoglobin","Albumin","Lymphocyte_count","Neutrophil_count",
                   "Monocyte_count","NLR","SAPSII_score","SOFA_score")
var_binary <- c("Gender","Hypertension","Diabetes","MACE","Liver_disease",
                "Renal_disease","Chronic_pulmonary_disease","Malignant_neoplasms",
                "Organ_transplant","HIV_infection","CMV_infection",
                "Glucocorticoids","Vasopressor","Ventilation","Kidney_dialysis")
var_multi <- "Race"

all_vars <- c(var_cont_mean, var_cont_medi, var_binary, var_multi)

df <- read_excel("111 cases.xlsx")

df_mimic <- subset(df, database=="MIMIC")
df_eicu  <- subset(df, database=="eICU")

make_table1_hospdead <- function(df_sub){

  df_surv  <- subset(df_sub, hosp_dead == 0)
  df_nonsurv <- subset(df_sub, hosp_dead == 1)
  n_all <- nrow(df_sub)
  n_surv <- nrow(df_surv)
  n_nonsurv <- nrow(df_nonsurv)
  
  out <- data.frame(
    Variable = character(),
    Whole = character(),
    Survivor = character(),
    Non_survivor = character(),
    P = character(),
    stringsAsFactors = FALSE
  )
  
  v <- "Age"
  row <- list()
  row$Variable <- "Age, years"
  row$Whole <- mean_sd(df_sub[[v]])
  row$Survivor <- mean_sd(df_surv[[v]])
  row$Non_survivor <- mean_sd(df_nonsurv[[v]])
  row$P <- format_p(p_welch_t(df_surv[[v]], df_nonsurv[[v]]))
  out <- rbind(out, row)
  
  for(v in var_cont_medi){
    row <- list()
    row$Variable <- v
    row$Whole <- med_iqr(df_sub[[v]])
    row$Survivor <- med_iqr(df_surv[[v]])
    row$Non_survivor <- med_iqr(df_nonsurv[[v]])
    row$P <- format_p(p_welch_t(df_surv[[v]], df_nonsurv[[v]]))
    out <- rbind(out, row)
  }
  
  for(v in var_binary){
    row <- list()
    row$Variable <- v
    row$Whole <- cat_npct(df_sub[[v]])
    row$Survivor <- cat_npct(df_surv[[v]])
    row$Non_survivor <- cat_npct(df_nonsurv[[v]])
    tb2 <- table(df_sub[[v]], df_sub$hosp_dead, useNA = "no")
    row$P <- format_p(p_chisq_no_yates(tb2))
    out <- rbind(out, row)
  }
  
  v <- var_multi
  row <- list()
  row$Variable <- "Race"
  row$Whole <- "-"
  row$Survivor <- "-"
  row$Non_survivor <- "-"
  tb_race <- table(df_sub[[v]], df_sub$hosp_dead, useNA = "no")
  row$P <- format_p(p_chisq_no_yates(tb_race))
  out <- rbind(out, row)
  
  attr(out, "sample_info") <- list(n_all=n_all, n_surv=n_surv, n_nonsurv=n_nonsurv)
  return(out)
}

table1_mimic <- make_table1_hospdead(df_mimic)
table1_eicu  <- make_table1_hospdead(df_eicu)

cat("======== MIMIC cohort ========\n")
info_m <- attr(table1_mimic, "sample_info")
cat(sprintf("Whole n=%d, Survivor(hosp_dead=0) n=%d, Non‑survivor(hosp_dead=1) n=%d\n",
            info_m$n_all, info_m$n_surv, info_m$n_nonsurv))
print(table1_mimic, row.names = FALSE)

cat("\n======== eICU cohort ========\n")
info_e <- attr(table1_eicu, "sample_info")
cat(sprintf("Whole n=%d, Survivor(hosp_dead=0) n=%d, Non‑survivor(hosp_dead=1) n=%d\n",
            info_e$n_all, info_e$n_surv, info_e$n_nonsurv))
print(table1_eicu, row.names = FALSE)

write.csv(table1_mimic, "Table1_MIMIC_hospdead.csv", row.names = FALSE, fileEncoding = "UTF‑8")
write.csv(table1_eicu,  "Table1_eICU_hospdead.csv",  row.names = FALSE, fileEncoding = "UTF‑8")
