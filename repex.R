# https://forum.posit.co/t/error-while-using-predict-on-a-tidymodels-workflow/65341

# I would like to follow up with the closed discussion Error while using `predict` on a tidymodels workflow since the proposed solution does fix the problem on the predict() call as intended but at the same time creates a new problem on a fit_resamples() call that didn't exist before the fix. I have 2 independent datasets, one that I use for training and the other one that I use for testing. I consider 2 versions of the recipes: my original one and the one proposed in the aforementioned closed discussion using skip = TRUE in the recipe step involving the outcome. As said above, introducing skip = TRUE in the recipe does fix the problem in the predict() call but also creates a new problem in the fit_resamples() call I have before. Below is a reproducible example that works whatever the seed you choose:

library(tibble)
library(dplyr)
library(rsample)
library(recipes)
library(themis)
library(parsnip)
library(workflows)
library(yardstick)
library(tune)

# We have 2 independent datasets: one that we will use for training and one that we
# will use for testing:

n1 <- 565
dataset1 <- tibble(
  culture        = sample(rep(c(FALSE, TRUE), c(531, 34))),
  sex            = sample(rep(factor(c("female", "male")), c(256, 309))),
  age            = runif(n1, 0, 89),
  cough          = sample(rep(c(FALSE, TRUE), c(300, 265))),
  diarrhea       = sample(rep(c(FALSE, TRUE), c(412, 153))),
  vomiting       = sample(rep(c(FALSE, TRUE), c(313, 252))),
  abdominal_pain = sample(rep(c(FALSE, TRUE), c(397, 168))),
  constipation   = sample(rep(c(FALSE, TRUE), c(508,  57))),
  headache       = sample(rep(c(FALSE, TRUE), c(395, 170))),
  pulse          = as.integer(sample(60:214, n1, TRUE)),
  temperature    = sample((364:420) / 10, n1, TRUE)
)

n2 <- 601
dataset2 <- tibble(
  culture        = sample(rep(c(FALSE, TRUE), c(427, 174))),
  sex            = sample(rep(factor(c("female", "male")), c(200, 401))),
  age            = runif(n2, 2, 57),
  cough          = sample(rep(c(FALSE, TRUE), c(345, 256))),
  diarrhea       = sample(rep(c(FALSE, TRUE), c(456, 145))),
  vomiting       = sample(rep(c(FALSE, TRUE), c(433, 168))),
  abdominal_pain = sample(rep(c(FALSE, TRUE), c(408, 193))),
  constipation   = sample(rep(c(FALSE, TRUE), c(524, 77))),
  headache       = sample(rep(c(FALSE, TRUE), c(82, 519))),
  pulse          = as.integer(sample(60:160, n2, TRUE)),
  temperature    = sample((3556:4100) / 100, n2, TRUE)
)

splits <- make_splits(list(analysis   = 1:n1, assessment = (n1 + 1):(n1 + n2)),
                      bind_rows(dataset1, dataset2))

training_data <- training(splits)
testing_data <- testing(splits)

# Cross-validation folds:

cv_folds <- vfold_cv(training_data, repeats = 50)

# We consider 2 different recipes (differences are for the lines ending with ###):

recipe1 <- recipe(culture ~ ., training_data) |> 
  step_bin2factor(all_logical()) |>              ### option 1 for recipe 1
  step_dummy(all_factor_predictors()) |> 
  step_smotenc(culture)

recipe2 <- recipe(culture ~ ., training_data) |> 
  step_bin2factor(all_logical_predictors()) |>   ### option 2 for recipe 2
  step_bin2factor(culture, skip = TRUE) |>       ### option 2 for recipe 2
  step_dummy(all_factor_predictors()) |> 
  step_smotenc(culture)

# The model and the workflows corresponding to the 2 recipes:

lr_classification <- logistic_reg("classification") |> 
  set_engine("glm")

workflow1 <- workflow(recipe1) |> 
  add_model(lr_classification)

workflow2 <- workflow(recipe2) |> 
  add_model(lr_classification)

# The metric of interest:

the_metric <- metric_set(roc_auc)

# Fitting by resampling on the training set: works for workflow1 but not for workflow2:

workflow1 |>
  fit_resamples(cv_folds, metrics = the_metric,
                control = control_resamples(save_pred = TRUE)) |> 
  collect_metrics()

workflow2 |>
  fit_resamples(cv_folds, metrics = the_metric,
                control = control_resamples(save_pred = TRUE)) |> 
  collect_metrics()

# Fitting on the training set and assessing on the testing set: this time it works for
# workflow2 but not for workflow1:

fitted_model1 <- fit(workflow1, training_data)
fitted_model2 <- fit(workflow2, training_data)

predict(fitted_model1, testing_data)
predict(fitted_model2, testing_data)
