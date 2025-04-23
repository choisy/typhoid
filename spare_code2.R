megalies <- c("splenomegaly", "hepatomegaly")
labs <- c("WBC", "platelets", "ALT")

set0  <- c("age", "cough", "diarrhea", "vomiting", "abdominal_pain", "constipation",
           "headache", "pulse", "temperature")
set1  <- c(set0, "CRP")
set2  <- c(set0, "IgM")
set3  <- c(set1, "IgM")

set4  <- c(set0, megalies)
set5  <- c(set1, megalies)
set6  <- c(set2, megalies)
set7  <- c(set3, megalies)

set8  <- c(set0, labs)
set9  <- c(set1, labs)
set10 <- c(set2, labs)
set11 <- c(set3, labs)

set12 <- c(set4, labs)
set13 <- c(set5, labs)
set14 <- c(set6, labs)
set15 <- c(set7, labs)


make_splits3 <- function(train, test, variables) {
  make_splits2(na.exclude(train[, c("culture", variables)]),
               na.exclude(test[, c("culture", variables)]))
}
