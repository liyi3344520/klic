#' Kernel k-means
#'
#' Perform the training step of kernel k-means
#' @param K kernel matrix
#' @param parameters list of parameters
#' @author Mehmet Gonen
#' @references Gönen, M. and Margolin, A.A., 2014. Localized data fusion for kernel k-means clustering with application to cancer biology. In Advances in Neural Information Processing Systems (pp. 1305-1313).
#' @examples
#' # Load one dataset with 300 observations, 2 variables, 6 clusters
#' data <- as.matrix(read.csv(system.file("extdata", "dataset1.csv", package = "klic"), row.names = 1))
#' # Compute consensus clustering with K=6 clusters
#' cm <- coca::consensusCluster(data, 6)
#' # Shift eigenvalues of the matrix by a constant: (min eigenvalue) * (coeff)
#' km <- spectrumShift(cm, coeff = 1.05)
#' # Initalize the parameters of the algorithm
#' parameters <- list()
#' # Set the number of clusters
#' parameters$cluster_count <- 6
#' #perform training
#' state <- kkmeans(km, parameters)
#' # Display the clustering
#' print(state$clustering)
#' @export
#'
kkmeans <- function(K, parameters) {
  state <- list()
  state$time <- system.time({
    H <- eigen(K, symmetric = TRUE)$vectors[, 1:parameters$cluster_count]
    objective <- sum(diag(t(H) %*% K %*% H)) - sum(diag(K))
    H_normalized <- H / matrix(sqrt(rowSums(H^2, 2)), nrow(H),
                               parameters$cluster_count, byrow = FALSE)
    H_normalized[sqrt(rowSums(H^2, 2))==0,] <- 0 # Trying to fix bug by replacing values that have been divided by zero

    set.seed(NULL)
    state$clustering <- stats::kmeans(H_normalized, centers = parameters$cluster_count,
                               iter.max = 1000, nstart = 10)$cluster
    state$objective <- objective
    state$parameters <- parameters
  })
  state
}
