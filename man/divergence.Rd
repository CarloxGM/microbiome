% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/divergence.R
\name{divergence}
\alias{divergence}
\title{Diversity within a Sample Group}
\usage{
divergence(x, method = "anticorrelation")
}
\arguments{
\item{x}{phyloseq object}

\item{method}{dissimilarity method ("anticorrelation" or any method available via the vetan::vegdist function)}
}
\value{
Vector with dissimilarities; one for each sample, quantifying the
dissimilarity of the sample from the group-level mean.
}
\description{
Quantify microbiota divergence (heterogeneity) within a given sample set.
}
\details{
Microbiota divergence (heterogeneity / spread) within a given sample
set can be quantified by the average sample dissimilarity or beta
diversity. Taking average over
all pairwise dissimilarities is sensitive to sample size and heavily biased
as the similarity values are not independent. To reduce this bias, the
dissimilarity of each sample against the group mean is calculated. This
generates one value per sample. These can be compared between groups in
order to compare differences in group homogeneity. 

Note that this measure is still affected by sample size.
Subsampling or bootstrapping can be applied to equalize sample sizes
between comparisons.

The anticorrelation mode is a simple indicator that returns
average spearman correlation between samples of the input data and
the overall group-wise average. The inverse of this measure
(ie cor instead of 1-cor as in here) was used in Salonen et al. (2014)
to quantify group homogeneity.
}
\examples{
  \dontrun{
    # Assess beta diversity among the African samples
    # in a diet swap study (see \\code{help(dietswap)} for references)
    data(dietswap)
    b <- divergence(subset_samples(dietswap, nationality == "AFR"))
  }
}
\references{
The inter- and intra-individual homogeneity measures used in
Salonen et al. ISME J. 8:2218-30, 2014 were obtained as
1 - beta where beta is the group diversity as quantified by the
anticorrelation method.

To cite this R package, see citation('microbiome')
}
\seealso{
the vegdist function from the \pkg{vegan} package provides many
standard beta diversity measures
}
\author{
Contact: Leo Lahti \email{microbiome-admin@googlegroups.com}
}
\keyword{utilities}
