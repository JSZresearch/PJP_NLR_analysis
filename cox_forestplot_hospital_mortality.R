# Logistic regression forest plot for hospital mortality

library(forestplot)

# Table text layout: Variable | Univariable OR(95%CI) | P | Multivariable OR(95%CI) | P
tabletext <- rbind(
  c(NA, "OR For Univariable Analysis", "", "OR For Multivariable Analysis", ""),
  c("Variable", "Univariable OR (95% CI)", "P Value", "Multivariable OR (95% CI)", "P Value"),
  c("Age", "0.996 (0.969‑1.024)", "0.770", NA, NA),
  c("Gender", "1.004 (0.392‑2.572)", "0.994", NA, NA),
  c("BMI", "1.003 (0.931‑1.081)", "0.938", NA, NA),
  c("Smoker", "1.242 (0.365‑4.232)", "0.728", NA, NA),
  c("Hypertension", "0.860 (0.334‑2.219)", "0.756", NA, NA),
  c("Diabetes", "0.735 (0.238‑2.272)", "0.593", NA, NA),
  c("MACE", "0.907 (0.352‑2.333)", "0.839", NA, NA),
  c("Liver disease", "1.230 (0.323‑4.690)", "0.761", NA, NA),
  c("Renal disease", "1.681 (0.523‑5.401)", "0.383", NA, NA),
  c("Chronic pulmonary disease", "1.782 (0.556‑5.709)", "0.331", NA, NA),
  c("Malignant neoplasms", "2.406 (0.994‑5.828)", "0.052", NA, NA),
  c("Organ transplant", "0.712 (0.079‑6.377)", "0.761", NA, NA),
  c("HIV infection", "1.282 (0.518‑3.174)", "0.592", NA, NA),
  c("CMV infection", "2.249 (0.682‑7.414)", "0.183", NA, NA),
  c("LDH", "1.001 (1.000‑1.003)", "0.076", NA, NA),
  c("Creatinine", "0.937 (0.683‑1.285)", "0.686", NA, NA),
  c("WBC", "1.009 (0.979‑1.040)", "0.556", NA, NA),
  c("RBC", "0.907 (0.524‑1.571)", "0.728", NA, NA),
  c("Platelet", "1.000 (0.997‑1.004)", "0.794", NA, NA),
  c("Hemoglobin", "0.962 (0.779‑1.188)", "0.720", NA, NA),
  c("Albumin", "0.677 (0.292‑1.568)", "0.362", NA, NA),
  c("Lymphocyte count", "0.796 (0.503‑1.260)", "0.331", NA, NA),
  c("Neutrophil count", "1.038 (0.965‑1.116)", "0.319", NA, NA),
  c("Monocyte count", "1.260 (0.856‑1.857)", "0.242", NA, NA),
  c("NLR", "1.050 (1.021‑1.080)", "<0.001", "1.046 (1.014‑1.079)", "0.005"),
  c("Glucocorticoids", "1.211 (0.459‑3.197)", "0.699", NA, NA),
  c("Vasopressor", "5.213 (2.060‑13.194)", "<0.001", "5.025 (1.663‑15.186)", "0.004"),
  c("Kidney dialysis", "1.372 (0.398‑4.727)", "0.616", NA, NA),
  c("SAPSII score", "1.012 (0.980‑1.044)", "0.469", NA, NA),
  c("SOFA score", "1.130 (1.001‑1.276)", "0.049", "1.129 (0.967‑1.317)", "0.124"),
  c("OASIS score", "1.053 (1.001‑1.107)", "0.048", "0.976 (0.914‑1.042)", "0.469")
)

# Univariable OR and confidence interval
univ_or <- c(NA, NA,
             0.996,1.004,1.003,1.242,0.860,0.735,0.907,1.230,1.681,1.782,2.406,0.712,1.282,2.249,
             1.001,0.937,1.009,0.907,1.000,0.962,0.677,0.796,1.038,1.260,1.050,1.211,5.213,1.372,1.012,1.130,1.053)
univ_lower <- c(NA, NA,
                0.969,0.392,0.931,0.365,0.334,0.238,0.352,0.323,0.523,0.556,0.994,0.079,0.518,0.682,
                1.000,0.683,0.979,0.524,0.997,0.779,0.292,0.503,0.965,0.856,1.021,0.459,2.060,0.398,0.980,1.001,1.001)
univ_upper <- c(NA, NA,
                1.024,2.572,1.081,4.232,2.219,2.272,2.333,4.690,5.401,5.709,5.828,6.377,3.174,7.414,
                1.003,1.285,1.040,1.571,1.004,1.188,1.568,1.260,1.116,1.857,1.080,3.197,13.194,4.727,1.044,1.276,1.107)

# Multivariable OR and confidence interval
mult_or <- c(NA, NA,
             NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,
             NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,1.046,NA,5.025,NA,NA,1.129,0.976)
mult_lower <- c(NA, NA,
                NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,
                NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,1.014,NA,1.663,NA,NA,0.967,0.914)
mult_upper <- c(NA, NA,
                NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,
                NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,1.079,NA,15.186,NA,NA,1.317,1.042)

# Generate forest plot object
fp_result <- forestplot(
  labeltext = tabletext,
  mean = cbind(univ_or, mult_or),
  lower = cbind(univ_lower, mult_lower),
  upper = cbind(univ_upper, mult_upper),
  new_page = TRUE,
  is.summary = c(TRUE, TRUE, rep(FALSE, 31)),
  xlog = FALSE,
  xlim = c(0, 6),
  xticks = c(0, 1, 2, 3, 4, 5, 6),
  refline = 1,
  col = fpColors(box = "red", line = "black", zero = "darkgray"),
  boxsize = 0.35,
  title = "Univariate and multivariate logistic regression analyses for hospital mortality in PJP ICU patients",
  txt_gp = fpTxtGp(
    label = gpar(fontsize = 9),
    ticks = gpar(fontsize = 8),
    xlab = gpar(fontsize = 9),
    title = gpar(fontsize = 10)
  ),
  align = c("left", "center", "center", "center", "center"),
  verbose = FALSE
)

# Export high‑resolution TIFF figure for journal submission
tiff(
  filename = "forest_hospital_mortality.tiff",
  width = 1800,
  height = 1600,
  res = 300,
  compression = "lzw"
)
print(fp_result)
dev.off()