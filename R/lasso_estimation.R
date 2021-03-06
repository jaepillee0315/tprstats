#' LASSO
#'
#' Performs LASSO regression analysis.
#'
#' @param datafile Used for estimating model.
#' @param predDat Used for prediction.
#' @return List of results.
#' @export

goLASSO <- function(datafile, predDat) {
  # library(glmnet)
  vars <- datafile
  xpred <- predDat

  names(vars)[1] <- "y"
  varnames <- colnames(vars)
  vars <- stats::na.omit(vars)
  numrows <- nrow(vars)
  numcoef <- ncol(vars)
  # Following two commands put data into x matrix and y vector.
  x <- stats::model.matrix(y ~ ., vars)[, -1]
  y <- vars$y
  # Select training sample and test sample
  set.seed(1)
  train <- sample(nrow(x), nrow(x) / 2)
  test <- -train
  y.test <- y[test]
  # LASSO Use cross-validation to choose the best lambda using lasso
  set.seed(1)
  cvlass_out <- glmnet::cv.glmnet(x[train, ], y[train], alpha = 1)
  graphics::plot(cvlass_out)
  bestlamlass <- cvlass_out$lambda.min
  # Obtain Lasso prediction and MSE for test sample
  lasso_pred <- stats::predict(cvlass_out, s = bestlamlass, newx = x[test, ])
  # mean((lasso_pred-y[test])^2) Now use bestlam on full sample to obtain
  # coefficients and predicted values.
  outlass <- glmnet::glmnet(x, y)
  # Calculate predicted values from full sample
  lasso_pred <- stats::predict(outlass, s = bestlamlass, newx = x)
  # Recover LASSO coefficients
  lasso_coef <- stats::predict(outlass, type = "coefficients", s = bestlamlass)[1:NCOL(x), ]
  lasso_coef <- round(lasso_coef, digits = 4)

  lasso_nonzero_coef <- subset(lasso_coef, abs(lasso_coef) > 0)

  # print results
  cat("LASSO Best Lambda:", bestlamlass, "\nLASSO NonZero Coefficients:\n", lasso_nonzero_coef, "\n")

  lasso_output <- list(
    cvlass_out = cvlass_out,
    outlass = outlass,
    bestlamlass = bestlamlass,
    lasso_coef = lasso_coef,
    lasso_nonzero_coef = lasso_nonzero_coef
  )
  return(lasso_output)
}
