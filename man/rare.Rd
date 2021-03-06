% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rare.R
\name{rare}
\alias{rare}
\title{Select Rare Taxa}
\usage{
rare(x, detection, prevalence, include.lowest = FALSE)
}
\arguments{
\item{x}{\code{\link{phyloseq-class}} object}

\item{detection}{Detection threshold for absence/presence (strictly greater by default).}

\item{prevalence}{Prevalence threshold (in [0, 1]; strictly greater by default)}

\item{include.lowest}{Include the lower boundary of the detection and prevalence cutoffs. FALSE by default.}
}
\value{
Filtered phyloseq object including only rare taxa
}
\description{
Filter the phyloseq object to include only rare taxa.
}
\examples{
  data(peerj32)
  pseq <- rare(peerj32$phyloseq, 200, 20/100)
}
\references{
To cite the microbiome R package, see citation('microbiome')
}
\author{
Contact: Leo Lahti \email{microbiome-admin@googlegroups.com}
}
\keyword{utilities}
