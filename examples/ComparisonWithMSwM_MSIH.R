###########################################################
# Compares the result with MSwM for MSIH-AR models
###########################################################
#install.packages("MswM")
#install.packages("nloptr")

library(nloptr)
library(MSwM)
library(normalregMix)
library(rMSWITCH)
library(Rcpp)
library(RcppArmadillo)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Generates exogeneous variable sample
GenerateExo <- function(n, p)
{
  return (matrix(rnorm((n*p)), ncol = p))
}

## 1. M = 2, s = 1
# model specification
set.seed(123456)
n <- 200
transition.probs <- matrix(c(0.9,0.2,0.1,0.8), ncol = 2)
beta <- 0.6
mu = c(-0.8,0.8)
sigma = c(0.6,1.4)
theta <- list(beta = beta, mu = mu, sigma = sigma,
              transition.probs = transition.probs, initial.dist = c(1,0))
M <- ncol(transition.probs)
s <- nrow(as.matrix(beta))

# generates data
sample <- GenerateSample(theta, n = n)
y <- sample$y

# comparison
set.seed(123456)
msar.model <- EstimateMSAR(y, M = M, s = s,
                           is.beta.switching = FALSE,
                           is.sigma.switching = TRUE)
msar.model$theta
msar.model$log.likelihood
DiagPlot(msar.model, y = y)
DiagPlot(sample$msar.model, y = y)

model=lm(y ~ 1)
msmFit(model, k=M, p=s, sw=c(T,F,T)) # MSwM (dependent mu, independent beta, dependent sigma)


## 2. M = 2, s = 2
# model specification
set.seed(234567)
theta$beta <- c(0.3, 0.2)
s <- 2

# generates data
sample <- GenerateSample(theta, n = n)
y <- sample$y

# comparison
msar.model <- EstimateMSAR(y, M = M, s = s,
                           is.beta.switching = FALSE,
                           is.sigma.switching = TRUE)
msar.model$theta
msar.model$log.likelihood
DiagPlot(msar.model, y = y)
DiagPlot(sample$msar.model, y = y)

model=lm(y ~ 1)
msmFit(model, k=M, p=s, sw=c(T,F,F,T)) # MSwM (dependent mu, independent beta1 beta2, dependent sigma)

## 3. M = 3, s = 1
# model specification
set.seed(654321)
n <- 800
transition.probs <- matrix(c(0.8,0.15,0.1,0.1,0.7,0.15,0.1,0.15,0.75), ncol = 3)
beta <- 0.9
mu = c(-0.5,0,0.4)
sigma = c(0.6,0.5,0.7)
theta <- list(beta = beta, mu = mu, sigma = sigma,
              transition.probs = transition.probs, initial.dist = c(1,0,0))
M <- ncol(transition.probs)
s <- nrow(as.matrix(beta))

# generates data
sample <- GenerateSample(theta, n = n)
y <- sample$y

# comparison
msar.model <- EstimateMSAR(y, M = M, s = s,
                           is.beta.switching = FALSE,
                           is.sigma.switching = TRUE)
msar.model$theta
msar.model$log.likelihood
model=lm(y ~ 1)
msar.model.mswm <- msmFit(model, k=M, p=s, sw=c(T,F,T)) # MSwM (dependent mu, independent beta1, dependent sigma)

## 4. M = 2, s = 1, p.indep = 1
# model specification
set.seed(456789)
n <- 200
transition.probs <- matrix(c(0.7,0.2,0.3,0.8), ncol = 2)
beta <- 0.6
mu = c(-0.4,0.4)
sigma = c(1,2)
gamma.independent <- 0.7
p.indep <- 1
theta <- list(beta = beta, mu = mu, sigma = sigma, gamma.independent = gamma.independent,
              transition.probs = transition.probs, initial.dist = c(1,0))
M <- ncol(transition.probs)
s <- nrow(as.matrix(beta))

# generates data
z.independent <- GenerateExo(n = (n+s), p.indep)
sample <- GenerateSample(theta, z.independent = z.independent, n = n)
y <- sample$y

# comparison
msar.model <- EstimateMSAR(y, z.independent = z.independent, M = M, s = s,
                           is.beta.switching = FALSE,
                           is.sigma.switching = TRUE)
msar.model$theta
msar.model$log.likelihood
model=lm(y ~ z.independent)
msmFit(model, k=M, p=s, sw=c(T,F,T)) # MSwM (dependent mu, independent beta1, dependent sigma)

## 5. M = 2, s = 1, p.dep = 1
# model specification
set.seed(567890)
theta$gamma.dependent <- matrix(c(0.3,0.6), ncol = 2)
theta$gamma.independent <- NULL
p.dep <- nrow(as.matrix(theta$gamma.dependent))

# generates data
z.dependent <- GenerateExo(n = (n+s), p.dep)
sample <- GenerateSample(theta, z.dependent = z.dependent, n = n)
y <- sample$y

# comparison
msar.model <- EstimateMSAR(y, z.dependent = z.dependent, M = M, s = s,
                           is.beta.switching = FALSE,
                           is.sigma.switching = TRUE)
msar.model$theta
msar.model$likelihood
model=lm(y ~ z.dependent)
msmFit(model, k=M, p=s, sw=c(T,T,F,T)) # MSwM (dependent mu, z, independent beta1, dependent sigma)

## 6. M = 3, s = 1, p.dep = 2, p.indep = 1
# model specification
set.seed(678901)
n <- 1200
theta$gamma.dependent <- matrix(c(0.3,0.6), ncol = 2)
theta$gamma.independent <- c(0.3,0.5)
theta$beta <- c(0.6)
p.dep <- nrow(as.matrix(theta$gamma.dependent))
p.indep <- nrow(as.matrix(theta$gamma.independent))
s <- nrow(as.matrix(theta$beta))

# generates data
z <- GenerateExo(n = (n+s), p=(p.dep + p.indep))
z.dependent <- z[,1:p.dep]
z.independent <- z[,(p.dep+1):(p.dep+p.indep)]
sample <- GenerateSample(theta, z.dependent = z.dependent, z.independent = z.independent, n = n)
y <- sample$y

# comparison
msar.model <- EstimateMSAR(y, z.dependent = z.dependent, z.independent = z.independent, M = M, s = s) #rMRS
msar.model$theta
msar.model$likelihood
model=lm(y ~ z.independent + z.dependent)
msmFit(model, k=M, p=s, sw=c(T,T,F,F,F,F,T)) # MSwM (dependent mu, z1, independent z2, z3, beta1, beta2, dependent sigma)
