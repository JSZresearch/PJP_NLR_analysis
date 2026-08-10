library(survminer)
library(survival)

fit <- survfit(Surv(ICU28, status) ~ NLR, data = hiv)

fit
summary(fit)

ggsurvplot(fit,
           data = hiv,
           conf.int = TRUE,
           pval = TRUE,
           surv.median.line = "hv",
           risk.table = TRUE,
           xlab = "Follow up time (Days)",
           legend = c(0.77, 1.04),
           legend.title = "",
           legend.labs = c("NLR<20.9", "NLR≥20.9"),
           break.x.by = 5,
           xlim = c(0, 30),
           pval.coord = c(2, 0.05),
           title = "       HIV-positive PJP patients (n=47)",
           font.title = c(14, "bold", "black"),
           font.x = c(14, "bold", "black"),
           font.y = c(14, "bold", "black"))