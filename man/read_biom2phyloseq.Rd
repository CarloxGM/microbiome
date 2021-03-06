% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_biom2phyloseq.R
\name{read_biom2phyloseq}
\alias{read_biom2phyloseq}
\title{Read BIOM File into a Phyloseq Object}
\usage{
read_biom2phyloseq(otu.file = NULL, taxonomy.file = NULL,
  metadata.file = NULL)
}
\arguments{
\item{otu.file}{A biom file with ".biom" extension}

\item{taxonomy.file}{NULL the latest version has taxonomic information within the biom}

\item{metadata.file}{A simple metadata/mapping file with .csv extension}
}
\value{
\code{\link{phyloseq-class}} object.
}
\description{
Read biom and mapping files into a \code{\link{phyloseq-class}} object.
}
\details{
Biom file and mapping files will be converted to \code{\link{phyloseq-class}}.
}
\examples{
  \dontrun{
    # Example data
    library(microbiome)
    p0 <- read_biom2phyloseq(otu.file = "otu_table.biom", metadata.file = "mapping.csv", taxonomy.file = NULL)
  }
}
\author{
Sudarshan A. Shetty \email{sudarshanshetty9@gmail.com}
}
\keyword{utilities}
