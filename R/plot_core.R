#' @title Visualize OTU Core
#' @description Core visualization (2D).
#' @param x A \code{\link{phyloseq}} object or a core matrix
#' @param prevalences a vector of prevalence percentages in [0,1]
#' @param detections a vector of intensities around the data range,
#'          or a scalar indicating the number of intervals in the data range.
#' @param plot.type Plot type ('lineplot' or 'heatmap')
#' @param colours colours for the heatmap
#' @param min.prevalence If minimum prevalence is set, then filter out those
#'    rows (taxa) and columns (detections) that never exceed this
#'    prevalence. This helps to zoom in on the actual core region
#'    of the heatmap. Only affects the plot.type = 'heatmap'.
#' @param taxa.order Ordering of the taxa.
#' @param horizontal Logical. Horizontal figure.
#' @return A list with three elements: the ggplot object and the data.
#'         The data has a different form for the lineplot and heatmap.
#'         Finally, the applied parameters are returned.
#' @examples 
#'   data(atlas1006)
#'   p <- plot_core(atlas1006, prevalences = seq(0.1, 1, .1),
#'                        detections = c(0, 10^(0:4)))
#' @export 
#' @references 
#'   A Salonen et al. The adult intestinal core microbiota is determined by 
#'   analysis depth and health status. Clinical Microbiology and Infection 
#'   18(S4):16 20, 2012. 
#'   To cite the microbiome R package, see citation('microbiome') 
#' @author Contact: Leo Lahti \email{microbiome-admin@@googlegroups.com}
#' @keywords utilities
plot_core <- function(x, 
		   prevalences = seq(,1, 1, .1), 		   
		   detections = 20,
		   plot.type = "lineplot",
		   colours = gray(seq(0,1,length=5)), 		   
		   min.prevalence = NULL,
		   taxa.order = NULL,
		   horizontal = FALSE) {

  if (length(detections) == 1) {
    detections <- 10^seq(log10(1e-3),
      log10(max(abundances(x), na.rm = T)),
      length = detections)
  }

  if (plot.type == "lineplot") {

    # Calculate the core matrix (prevalences x abundance thresholds)
    coremat <- core_matrix(x, prevalences, detections)

    res <- core_lineplot(coremat)

  } else if (plot.type == "heatmap") {

    # Here we use taxon x abundance thresholds table indicating prevalences
    res <- core_heatmap(abundances(x),
    	                detections = detections,
			colours = colours, min.prevalence = min.prevalence,
			taxa.order = taxa.order)
    
  }

  p <- res$plot + ggtitle("Core")

  if (horizontal) {
    p <- p + coord_flip() + theme(axis.text.x = element_text(angle = 90))
  }

  p

}


#' @title Core Matrix 
#' @description Creates the core matrix.
#' @param x \code{\link{phyloseq}} object or a taxa x samples abundance matrix
#' @param prevalences a vector of prevalence percentages in [0,1]
#' @param detections a vector of intensities around the data range
#' @return Estimated core microbiota
#' @examples
#'   \dontrun{
#'     # Not exported
#'     data(peerj32)
#'     core <- core_matrix(peerj32$phyloseq)
#'   }
#' @references 
#'   A Salonen et al. The adult intestinal core microbiota is determined by 
#'   analysis depth and health status. Clinical Microbiology and Infection 
#'   18(S4):16 20, 2012. 
#'   To cite the microbiome R package, see citation('microbiome') 
#' @author Contact: Jarkko Salojarvi \email{microbiome-admin@@googlegroups.com}
#' @keywords utilities
core_matrix <- function(x,  
          prevalences = seq(.1, 1, ,1), 
          detections = NULL) {

    # Pick abundances
    data <- abundances(x)

    # Convert prevalences from percentages to sample counts
    p.seq <- 0.01 * prevalences * ncol(data)

    ## Intensity vector
    if (is.null(detections)) {
      detections <- seq(min(data), max(data), length = 10)
    }
    i.seq <- detections

    coreMat <- matrix(NA, nrow = length(i.seq), ncol = length(p.seq), 
                      	  dimnames = list(i.seq, p.seq))
    
    n <- length(i.seq) * length(p.seq)
    cnt <- 0
    for (i in i.seq) {
      for (p in p.seq) { 
        # Number of OTUs above a given prevalence     
        coreMat[as.character(i), as.character(p)] <- sum(rowSums(data > i)>= p)
      }
    }
    
    # Convert Prevalences to percentages
    colnames(coreMat) <- as.numeric(colnames(coreMat))/ncol(data)
    rownames(coreMat) <- as.character(as.numeric(rownames(coreMat)))
    
    coreMat

}


#' @title Core Heatmap
#' @description Core heatmap.
#' @param data OTU matrix
#' @param detections A vector or a scalar indicating the number of intervals in (0, log10(max(data))). The detections are calculated for relative abundancies.
#' @param colours colours for the heatmap
#' @param min.prevalence If minimum prevalence is set, then filter out those rows (taxa) and columns (detections) that never exceed this prevalence. This helps to zoom in on the actual core region of the heatmap.
#' @param taxa.order Ordering of the taxa.
#' @return Used for its side effects
#' @references 
#'   A Salonen et al. The adult intestinal core microbiota is determined by 
#'   analysis depth and health status. Clinical Microbiology and Infection 
#'   18(S4):16 20, 2012. 
#'   To cite the microbiome R package, see citation('microbiome') 
#' @author Contact: Leo Lahti \email{microbiome-admin@@googlegroups.com}
#' @keywords utilities
core_heatmap <- function(data, detections = 20, colours = gray(seq(0,1,length=5)), min.prevalence = NULL, taxa.order = NULL) {

    DetectionThreshold <- Taxa <- Prevalence <- NULL
    
    # Prevalences with varying detections
    prev <- lapply(detections, function (th) {prevalence(data, detection = th)})
    prev <- do.call("cbind", prev)
    colnames(prev) <- as.character(detections)

    # Exclude rows and cols that never exceed the given prevalence
    if (!is.null(min.prevalence)) {
      prev <- prev[rowMeans(prev > min.prevalence) > 0, colMeans(prev > min.prevalence) > 0]
    }
    
    df <- as.data.frame(prev)
    df$ID <- rownames(prev)
    df <- gather(df, "ID")
    names(df) <- c("Taxa", "DetectionThreshold", "Prevalence")
    df$DetectionThreshold <- as.numeric(as.character(df$DetectionThreshold))
    df$Prevalence <- as.numeric(as.character(df$Prevalence))

    if (is.null(taxa.order)) {
      o <- names(sort(rowSums(prev)))
    } else {
      o <- taxa.order
    }
    df$Taxa <- factor(df$Taxa, levels = o)

    theme_set(theme_bw(10))
    p <- ggplot(df, aes(x = DetectionThreshold, y = Taxa, fill = Prevalence))
    p <- p + geom_tile()
    p <- p + xlab("Detection Threshold")    
    p <- p + scale_x_log10()

    p <- p + scale_fill_gradientn("Prevalence", 
        breaks = seq(from = 0, to = 1, by = .1),
	colours = colours, limits = c(0, 1))
    
    return(list(plot = p, data = df))
    
} 


core_lineplot <- function (x, title = "Common core",  
                   xlabel = "Abundance", 
                   ylabel = "Core size (N)") {

    Abundance <- Prevalence <- Count <- NULL
    
    df <- as.data.frame(x)
    df$ID <- rownames(x)
    df <- gather(df, "ID")
    names(df) <- c("Abundance", "Prevalence", "Count")
    df$Abundance <- as.numeric(as.character(df$Abundance))
    df$Prevalence <- as.numeric(as.character(df$Prevalence))
    df$Count <- as.numeric(as.character(df$Count))    

    theme_set(theme_bw(20))
    p <- ggplot(df, aes(x = Abundance,
      	 	    	y = Count,
			color = Prevalence, 
                        group = Prevalence))
    
    p <- p + geom_line()
    p <- p + geom_point()
    p <- p + scale_x_log10()
    p <- p + xlab(xlabel)
    p <- p + ylab(ylabel)
    p <- p + ggtitle(title)
        
    list(plot = p, data = x)
}





