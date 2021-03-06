library(nloptr)

## 1. M = 2, s = 1
# model specification
set.seed(123456)
n <- 50
p12 <- 0.6
p21 <- 0.7
transition.probs <- matrix(c(0.4,0.7,0.6,0.3), ncol = 2)
mu = c(-2,2)
beta = 0.5
sigma = c(1,2)
M <- 2
s <- 1


M <- ncol(theta$transition.probs)
s <- nrow(as.matrix(theta$beta))
is.beta.switching <- (ncol(as.matrix(theta$beta)) > 1)
is.sigma.switching <- (length(theta$sigma) > 1)
p.dep <- 0
p.indep <- 0
if (!is.null(theta$gamma.dependent))
  p.dep <- nrow(theta$gamma.dependent)
if (!is.null(theta$gamma.independent))
  p.dep <- nrow(theta$gamma.independent)

# generates data
theta <- list(beta = beta, mu = mu, sigma = sigma, 
              transition.probs = transition.probs, 
              initial.dist = c(0.2, 0.8))

y <- GenerateSample(theta = theta, n = n, initial.y.set = rnorm(length(theta$beta)), 
                    initial.state = 1)$sample
lagged.and.sample <- GetLaggedAndSample(y, s)
y.lagged <- lagged.and.sample$y.lagged 
y.sample <- lagged.and.sample$y.sample
z.dependent <- as.matrix(rep(0,n))
z.independent <- as.matrix(rep(0,n))

theta.vectorized <- ThetaToColumn(theta)
theta.vectorized

MaximizeLongStep(list(theta), y = y.sample, y.lagged = y.lagged, 
                 z.dependent = z.dependent, z.independent = z.independent)

## 2. M = 2, s = 2, beta.switching
# model specification
beta <- matrix(c(0.3,0.4,0.5,0.3), ncol = 2)
s <- 2
is.beta.switching <- TRUE

M <- ncol(theta$transition.probs)
s <- nrow(as.matrix(theta$beta))
is.beta.switching <- (ncol(as.matrix(theta$beta)) > 1)
is.sigma.switching <- (length(theta$sigma) > 1)
p.dep <- 0
p.indep <- 0
if (!is.null(theta$gamma.dependent))
  p.dep <- nrow(theta$gamma.dependent)
if (!is.null(theta$gamma.independent))
  p.dep <- nrow(theta$gamma.independent)

# generates data
theta <- list(beta = beta, mu = mu, sigma = sigma, 
              transition.probs = transition.probs, 
              initial.dist = c(0.2, 0.8))

y <- GenerateSample(theta = theta, n = n, initial.y.set = rnorm(length(theta$beta)), 
                    initial.state = 1)$sample
lagged.and.sample <- GetLaggedAndSample(y, s)
y.lagged <- lagged.and.sample$y.lagged 
y.sample <- lagged.and.sample$y.sample
z.dependent <- as.matrix(rep(0,n))
z.independent <- as.matrix(rep(0,n))

theta.vectorized <- ThetaToColumn(theta)
theta.vectorized

MaximizeLongStep(list(theta), y = y.sample, y.lagged = y.lagged, 
                 z.dependent = z.dependent, z.independent = z.independent)