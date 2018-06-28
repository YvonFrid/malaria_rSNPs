#' @title Get genes associated to a given disease ID
#' @author Script from the Disgenet template, customised by Yvon Mbouamboua
#' @param diseaseID disgenet ID of the disease of interest
#' @param diseaseName disease name, as found in Disgenet
#' @return a data frame with the information about each gene associated to the query disease
#' 
GetGenesForDisease <- function(diseaseID, diseaseName) {
  message("\tGetGenesForDisease\t", diseaseID)
  
  ## Generate the SQL query for DisGeNet
  oql <- paste(sep = "", "DEFINE
               c0='/data/gene_disease',
               c1='/data/genes',
               c2='/data/diseases',
               c3='/data/gene_disease_summary',
               c4='/data/publication',
               c5='/data/sources'
               ON
               'http://www.disgenet.org/web/DisGeNET'
               SELECT
               c0 (source, geneId, source, geneId, source, geneId, associationType,                         originalSource, originalSource, originalSource, sentence, pmid),
               c1 (pantherName, symbol, geneId, description, symbol, geneId),
               c2 (diseaseId, name, hpoName, diseaseId, name, STY, MESH,                                    diseaseClassName, doName, type, OMIM, type),
               c3 (score),
               c4 (year)
               FROM
               c0
               WHERE
               (
               c2 = '", diseaseID, "'
               AND
               c5 = 'ALL'
               )
               ORDER BY
               c3.score DESC" )
  
  
  ## Open a connection to disgenet and get the full table of disease-associated genes.
  dataTsv <- rawToChar(
    charToRaw( 
      getURLContent(url, 
                    readfunction = charToRaw(oql), 
                    upload = TRUE, 
                    customrequest = "POST")))
  gene.data <- read.csv(textConnection(dataTsv), header = TRUE, sep = "\t")
  
  return(gene.data)
}



  ## SNPs

GetSnpsForDisease <- function(diseaseID, diseaseName) {
  message("\tGetSnpsForDisease\t", diseaseID)
  
  ## Generate the SQL query for DisGeNet
  oql <- "DEFINE
  c0='/data/variant_disease_summary',
  c1='/data/diseases',
  c2='/data/variants',
  c3='/data/sources'
  ON
  'http://www.disgenet.org/web/DisGeNET'
  SELECT
  c0 (snpId, score, EI, snpId, source, diseaseId, Npmids),
  c1 (diseaseId, name, hpoName, diseaseId, name, STY, MESH, diseaseClassName, doName, type, OMIM),
  c2 (DSI, DPI, chromosome, coord, most_severe_consequence, REF_ALT, class, AF_EXAC, AF_1000G)
  FROM
  c0
  WHERE
  (
  c1 = 'C0024530'
  AND
  c3 = 'ALL'
  )
  ORDER BY
  c0.score DESC" 
  
  ## Open a connection to disgenet and get the full table of disease-associated SNPs
  dataTsv <- rawToChar(
    charToRaw( 
      getURLContent(url, 
                    readfunction = charToRaw(oql), 
                    upload = TRUE, 
                    customrequest = "POST")))
  snp.data <- read.csv(textConnection(dataTsv), header = TRUE, sep = "\t")
  
  return(snp.data)
}
