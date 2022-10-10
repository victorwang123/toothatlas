library(ggplot2)
library(ggimage)
library(DistMap)

e14.5_geometry = read.csv("e14.5_geometry.csv", row.names = 1)

e14.5_spatial = readRDS("e14.5_spatial.rds")

e14.5_image = "e14.5-outline.png"

# vish

setGeneric(name = "computeVISH", def = function(object, gene, threshold=0.75) {standardGeneric("computeVISH")})
setMethod(f = "computeVISH",
          signature = "DistMap",
          function(object, gene, threshold) {
            gene.expr <- as.numeric(object@data[gene, ])
            b1 <- sweep(object@mcc.scores, 2, gene.expr, '*')
            gene.expr[gene.expr < 0] = 0
            gene.expr[gene.expr > 0] <- 1
            b2 <- sweep(object@mcc.scores, 2, gene.expr, '*')
            q <- rowSums(b1)/rowSums(b2)
            q[is.na(q)] <- 0
            q <- q/(1+q)
            q[q < quantile(q, threshold)] <- 0
            return (as.numeric(q))
          })

e14.5_spatial = mapCells(e14.5_spatial)

plot_vish_image = function(gene, thres) {
  ggplot(e14.5_geometry, aes(x = x, y = -z)) + geom_image(x = 25.5, y = -27, image = e14.5_image, size = 1) + geom_point(aes(color =  computeVISH(e14.5_spatial, gene, threshold = thres)), size = 0.5) + scale_color_gradient(low = "lightgrey", high = "red") + theme_classic() + theme(legend.position = "none", axis.line = element_blank(), axis.title = element_blank(), axis.text = element_blank(), axis.ticks = element_blank()) + ggtitle(gene) + theme(plot.title = element_text(size = 15, face = "bold", hjust = 0.5, vjust = -2))
}

plot_vish_image("Sox9", 0.6)
plot_vish_image("Sdc1", 0.85)
plot_vish_image("Runx2", 0.7)
plot_vish_image("Cdkn1c", 0.8)
plot_vish_image("Enpp1", 0.9)
plot_vish_image("C1qtnf3", 0.88)
plot_vish_image("Postn", 0.7)
