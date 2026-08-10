# Cox regression forest plot for 28-day mortality

library(forestplot)

# Table text layout: Variable | Univariable HR(95%CI) | P | Multivariable HR(95%CI) | P
tabletext <- rbind(
  c(NA, "HR For Univariable Analysis", "", "HR For Multivariable Analysis", ""),
  c("Variable", "Univariable HR (95% CI)", "P Value", "Multivariable HR (95% CI)", "P Value"),
  c("Age", "1.013 (0.988-1.038)", "0.316", NA, NA),
  c("Gender", "0.843 (0.379-1.877)", "0.676", NA, NA),
  c("BMI", "1.058 (1.001-1.117)", "0.044", "1.041 (0.975-1.113)", "0.230"),
  c("Smoker", "1.121 (0.388-3.242)", "0.833", NA, NA),
  c("Hypertension", "0.772 (0.347-1.718)", "0.526", NA, NA),
  c("Diabetes", "1.100 (0.380-3.180)", "0.861", NA, NA),
  c("MACE", "0.782 (0.351-1.742)", "0.548", NA, NA),
  c("Liver disease", "1.155 (0.348-3.835)", "0.814", NA, NA),
  c("Renal disease", "1.628 (0.563-4.707)", "0.369", NA, NA),
  c("Chronic pulmonary disease", "1.309 (0.496-3.458)", "0.586", NA, NA),
  c("Malignant neoplasms", "2.682 (1.227-5.862)", "0.013", "0.635 (0.272-1.484)", "0.295"),
  c("Organ transplant", "0.691 (0.094-5.090)", "0.716", NA, NA),
  c("HIV infection", "1.901 (0.803-4.496)", "0.144", NA, NA),
  c("CMV infection", "1.383 (0.478-3.999)", "0.55", NA, NA),
  c("LDH", "1.001 (1.000-1.001)", "<0.001", "1.001 (1.000-1.001)", "<0.001"),
  c("Creatinine", "0.944 (0.714-1.247)", "0.684", NA, NA),
  c("WBC", "1.007 (0.987-1.028)", "0.489", NA, NA),
  c("RBC", "0.784 (0.481-1.278)", "0.33", NA, NA),
  c("Platelet", "1.001 (0.997-1.004)", "0.76", NA, NA),
  c("Hemoglobin", "0.912 (0.753-1.106)", "0.349", NA, NA),
  c("Albumin", "0.538 (0.253-1.143)", "0.107", NA, NA),
  c("Lymphocyte count", "0.858 (0.580-1.269)", "0.443", NA, NA),
  c("Neutrophil count", "1.040 (0.981-1.104)", "0.188", NA, NA),
  c("Monocyte count", "0.971 (0.647-1.458)", "0.888", NA, NA),
  c("NLR", "1.032 (1.018-1.046)", "<0.001", "1.030 (1.015-1.045)", "<0.001"),
  c("Glucocorticoids", "1.209 (0.511-2.858)", "0.666", NA, NA),
  c("Vasopressor", "2.487 (1.163-5.317)", "0.019", "0.624 (0.268-1.456)", "0.275"),
  c("Ventilation", "2.555 (0.769-8.487)", "0.126", NA, NA),
  c("Kidney dialysis", "2.126 (0.858-5.269)", "0.103", NA, NA),
  c("SAPSII score", "1.016 (0.989-1.044)", "0.247", NA, NA),
  c("SOFA score", "1.126 (1.020)", "0.019", "1.041 (0.898-1.205)", "0.596"),
  c("OASIS score", "1.052 (1.008-1.099)", "0.020", "1.017 (0.953-1.084)", "0.618")
)

# Univariable HR and confidence interval
univ_hr <- c(NA, NA,
             1.013,0.843,1.058,1.121,0.772,1.100,0.782,1.155,1.628,1.309,2.682,0.691,1.901,1.383,
             1.001,0.944,1.007,0.784,1.001,0.912,0.538,0.858,1.040,0.971,1.032,1.209,2.487,2.555,2.126,1.016,1.126,1.052)
univ_lower <- c(NA, NA,
                0.988,0.379,1.001,0.388,0.347,0.380,0.351,0.348,0.563,0.496,1.227,0.094,0.803,0.478,
                1.000,0.714,0.987,0.481,0.997,0.753,0.253,0.580,0.981,0.647,1.018,0.511,1.163,0.769,0.858,0.989,1.020,1.008)
univ_upper <- c(NA, NA,
                1.038,1.877,1.117,3.242,1.718,3.180,1.742,3.835,4.707,3.458,5.862,5.090,4.496,3.999,
                1.001,1.247,1.028,1.278,1.004,1.106,1.143,1.269,1.104,1.458,1.046,2.858,5.317,8.487,5.269,1.044,1.243,1.099)

# Multivariable HR and confidence
mult_hr <- c(NA, NA,
             NA,NA,1.041,NA,NA,NA,NA,NA,NA,NA,0.635,NA,NA,NA,
             1.001,NA,NA,NA,NA,NA,NA,NA,NA,NA,1.030,NA,0.624,NA,NA,NA,1.041,1.017)
mult_lower <- c(NA, NA,
                NA,NA,0.975,NA,NA,NA,NA,NA,NA,NA,0.272,NA,NA,
                1.000,NA,NA,NA,NA,NA,NA,NA,NA,NA,1.015,NA,0.268,NA,NA,NA,0.898,0.953)
mult_upper <- c(NA, NA,
                NA,NA,1.113,NA,NA,NA,NA,NA,NA,NA,1.484,NA,NA,NA,
                1.001,NA,NA,NA,NA,NA,NA,NA,NA,NA,1.045,NA,1.456,NA,NA,NA,1.205,1.084)

# Generate forest plot object
fp_result <- forestplot(
  labeltext = tabletext,
  mean = cbind(univ_hr, mult_hr),
  lower = cbind(univ_lower, mult_lower),
  upper = cbind(univ_upper, mult_upper),
  new_page = TRUE,
  is.summary = c(TRUE, TRUE, rep(FALSE, 32)),
  xlog = FALSE,
  xlim = c(0, 6),
  xticks = c(0, 1, 2, 3, 4, 5, 6),
  refline = 1,
  col = fpColors(box = "red", line = "black", zero = "darkgray"),
  boxsize = 0.35,
  title = "Univariate and multivariate Cox regression analyses for 28-day mortality in PJP ICU patients",
  txt_gp = fpTxtGp(
    label = gpar(fontsize = 9),
    ticks = gpar(fontsize = 8),
    xlab = gpar(fontsize = 9),
    title = gpar(fontsize = 10)
  ),
  align = c("left", "center", "center", "center", "center"),
  verbose = FALSE
)

# Export high-resolution TIFF figure for journal submission
tiff(
  filename = "forest_28day_mortality.tiff",
  width = 1800,
  height = 1600,
  res = 300,
  compression = "lzw"
)
print(fp_result)
dev.off()