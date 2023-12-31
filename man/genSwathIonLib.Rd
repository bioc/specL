\name{genSwathIonLib}

\alias{genSwathIonLib}
\alias{SWATH}
\alias{swath}
\alias{MRM}
\alias{specL}

\title{Spectrum library generator for SWATH analysis}

\description{

    This function generates an ion library for SWATH analysis.
    It takes a R data object which contains a peak list.
    The R data object can be generated using the 
    \code{read.bibliospec} function.
    
}

\usage{

    genSwathIonLib(data, 
        data.fit = data,
        mascotIonScoreCutOFF=20,
        proteinIDPattern='',
        max.mZ.Da.error = 0.1,
        ignoreMascotIonScore = TRUE,
        topN = 10,
        fragmentIonMzRange = c(300, 1800),
        fragmentIonRange = c(4, 100),
        fragmentIonFUN = .defaultSwathFragmentIon,
        iRT = specL::iRTpeptides,
        AminoAcids = protViz::AA,
        breaks=NULL,
        NORMALIZE=.normalize_rt)
}

\arguments{

  \item{data}{data set containing mZ and peptide sequence.}

  \item{mascotIonScoreCutOFF}{a value for filtering the specs.}

  \item{proteinIDPattern}{a filter for protein.}

  \item{max.mZ.Da.error}{the mZ error in Dalton on ms2 level.}

  \item{ignoreMascotIonScore}{Boolean if mascot score is considered or not.}

  \item{topN}{returns the most \code{N} intense fragment ion only.}

  \item{fragmentIonMzRange}{mZ range filter of fragment ion.}

  \item{fragmentIonRange}{range filter of the number of identified fragment ion 
  which are assigned in the spectrum library set in \code{fragmentIonTyp}.
  Use this option to generate a library with a minimum of five transitions 
  for all peptides using \code{c(5,100)}, all peptides where at least not five transmissions
  found were omitted.}

  \item{fragmentIonFUN}{\code{function (b, y)} which derives all requested 
    fragment ion out a given tuple of \code{b} and \code{y} ion. If the 
    parameter is not specified the method uses an internal function similar 
    as the example below.}

  \item{iRT}{optional table which contains iRT peptides. If an iRT table 
  is provided (default) a \code{lm} is applied to normalize the rt in 
  \code{data}. See also \code{?iRT}. A necessary condition is that 
  \code{data} contains at least two iRT peptides.}

  \item{AminoAcids}{a list containing of 1-letter code and mono-isotopic mass of 
  the amino acids. Default uses the \code{protViz::AA} data set.}

  \item{data.fit}{data set containing mZ and peptide sequence 
  which is used for normalizing rt using a linear model 
  \code{lm(formula = rt ~ aggregateInputRT * fileName, data)}. 
  The rt aggregation for the model uses \code{median}.}

  \item{breaks}{provides a vector of SWATH windows. If q1 (precursor mass) and q3 (fragment ion) fall into the same SWATH window the fragment ion is ignored in the resulting ion library. The follwing code shows an example \code{breaks=seq(400, 2000, by=25)}.}

  \item{NORMALIZE}{is a \code{function(data, data.fit, iRT, plot=FALSE)} normalizing the rt.
 The default is a internal R helper function using \code{lm}.}
}

\details{

The function is the main contribution of the \code{specL} package.
It generates the spectra library used in a SWATH analysis workflow
out of a mass spectrometric measurement.

\code{genSwathIonLib} uses the core functions \code{protViz::findNN}, 
\code{protViz::fragmentIon}, and \code{protViz::aa2mass}.

The input is read by using \code{read.bibliospec} function of this package
and passed by the \code{data} function parameter.
If no BiblioSpec files are available also Mascot DAT files 
can be read using scripts contained in the protViz package exec folder.

If the protein information is lost you can benefit
for the \code{specL::annotate.protein_id.Rd} method.

The function first appear in the \code{protViz} 0.1.45 package. 
It has been removed in \code{protViz} 0.2.6 to avoid package dependencies.

}

\value{

    The output is a data structure defined as \code{specLSet} object.
    The generic method \code{ionlibrary} returns a list of \code{specL} objects, 
    \code{specLSet} also stores the input and normalized retention times.

}

\seealso{ 

    The S4 class definition:
  \code{showClass("specL")}
  \code{showClass("specLSet")}

    and the package vignette file.
  \code{vignette('specL')} 

}

\author{

   Christian Panse, Christian Trachsel, 
   and Jonas Grossmann 2012, 2013, 2014, 2016

}

\examples{

    myFragmentIon <- function (b, y) {
        Hydrogen <- 1.007825
        Oxygen <- 15.994915
        Nitrogen <- 14.003074

        b1_ <- (b )
        y1_ <- (y ) 

        b2_ <- (b + Hydrogen) / 2
        y2_ <- (y + Hydrogen) / 2 

        b3_ <- (b + 2 * Hydrogen) / 3
        y3_ <- (y + 2 * Hydrogen) / 3

        return( cbind(b1_, y1_, b2_, y2_, b3_, y3_) )
    }

    peptideStd.ionLib <- genSwathIonLib(data=peptideStd, 
        data.fit=peptideStd.redundant, 
        fragmentIonFUN=myFragmentIon)
        
        
    summary(peptideStd.ionLib)


    idx<-40

    op <- par(mfrow = c(2,1))

    plot(peptideStd.ionLib)

    text(rt.input(peptideStd.ionLib)[idx],
        rt.normalized(peptideStd.ionLib)[idx],
        "X", cex=1.5)

    plot(ionlibrary(peptideStd.ionLib)[[idx]])


    \dontrun{
        write.spectronaut(peptideStd.ionLib, 
            file="peptideStd.ionLib.csv")
   }
}
