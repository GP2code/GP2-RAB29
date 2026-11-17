# RAB29 p.Arg175Lys in Parkinson’s disease

`GP2 ❤️ Open Science 😍`

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24325351.svg)](https://doi.org/10.5281/zenodo.24325351)

**Last updated:** November 2026

## Summary

This is the online repository for the manuscript titled **"RAB29 p.Arg175Lys in Parkinson’s disease"**. RAB GTPases have recently emerged as contributors to Parkinson’s disease through the discovery of *RAB32* p.S71R, highlighting vesicular trafficking and LRRK2 signaling as key pathogenic pathways. This study aims to investigate rare coding variants in the RAB GTPase genes *RAB32*, *RAB29*, and *RAB38* and their association with the risk of developing Parkinson’s disease.

## Data statement

Data used in the preparation of this article were obtained from the Global Parkinson’s Genetics Program (GP2; [https\://gp2.org](https://gp2.org)).

All GP2 data are hosted in collaboration with the Accelerating Medicines Partnership in Parkinson’s disease, and are available via application on the website ([https\://amp-pd.org/register-for-amp-pd](https://amp-pd.org/register-for-amp-pd)). For up-to-date information on GP2 data acquisition, access, and policies, visit [https\://gp2.org/](https://gp2.org/). Tier 1 data can be accessed by completing a form on the Accelerating Medicines Partnership in Parkinson’s Disease (AMP®-PD) website ([https\://amp-pd.org/register-for-amp-pd](https://amp-pd.org/register-for-amp-pd)). Tier 2 data access requires approval and a Data Use Agreement signed by your institution.

In this analysis we used Tier 2 GP2 Release 11 ([10.5281/zenodo.17753486](https://doi.org/10.5281/zenodo.17753486)) and Release 12 data ([10.5281/zenodo.20932193](https://doi.org/10.5281/zenodo.20932193)).

### Helpful Links

- [GP2 Website](https://gp2.org/)  
  - [GP2 Cohort Dashboard](https://gp2.org/cohort-dashboard-advanced/)  
- [Introduction to GP2](https://movementdisorders.onlinelibrary.wiley.com/doi/10.1002/mds.28494)  
  - [Other GP2 Manuscripts (PubMed)](https://pubmed.ncbi.nlm.nih.gov/?term=%22global+parkinson%27s+genetics+program%22)

## Repository Orientation

- The `analyses/` directory includes all analyses discussed in the manuscript.

<pre> THIS_REPO/ 
  ├── analyses/ 
  |     ├── 00_RAB29.Gene-analysis.ipynb
  |     └── 01_RAB29.R175K_NBA.ipynb
  |     └── 02_RAB29.EUR_Meta-analysis_prep.ipynb
  |     └── 03_RAB29.Meta-analysis.R
  |     └── 04_RAB29.Haplotype_LD.ipynb
  |     └── 05_RAB32.Gene-analysis.ipynb
  |     └── 06_RAB38.Gene-analysis.ipynb
  ├── LICENSE
  └── README.md 
</pre>

&nbsp;

## Analysis Notebooks

### Languages: Python, bash, and R

| Directory | Notebooks | Description |
| :---- | :---- | :---- |
| `analyses/` | `00_RAB29.Gene-analysis.ipynb` | Investigation of rare non-synonymous variants in RAB29 |
| `analyses/` | `01_RAB29.R175K_NBA.ipynb` | Investigation of RAB29 p.R175K variant carriers in the NBA |
| `analyses/` | `02_RAB29.EUR_Meta-analysis_prep.ipynb` | Preparing EUR dataset for meta-analysis |
| `analyses/` | `03_RAB29.Meta-analysis.R` | Meta-analysis of RAB29 p.R175K across study groups |
| `analyses/` | `04_RAB29.Haplotype_LD.ipynb` | Investigation of RAB29 p.R175K haplotype and LD with RAB29 GWAS hit |
| `analyses/` | `05_RAB32.Gene-analysis.ipynb` | Investigation of rare non-synonymous variants in RAB32 |
| `analyses/` | `06_RAB38.Gene-analysis.ipynb` | Investigation of rare non-synonymous variants in RAB38 |

&nbsp;

## Software

| Software | Version(s) | Resource URL | RRID | Notes |
| :---- | :---- | :---- | :---- | :---- |
| ANNOVAR | d.02.03.2025 | [http\://www\.openbioinformatics.org/annovar/](http://www.openbioinformatics.org/annovar/) | RRID:SCR\_012821 | Used for variant annotation. |
| BCFtools | v.1.23.1 | [http\://samtools.sourceforge.net/mpileup.shtml](http://samtools.sourceforge.net/mpileup.shtml) | RRID:SCR\_005227 | Used for genomic file manipulation. |
| Beagle | v.5.2 | [https\://faculty.washington.edu/browning/beagle/beagle.html](https://faculty.washington.edu/browning/beagle/beagle.html) | NA | Used for phasing. |
| gnomAD | v.4.1 | [http\://gnomad.broadinstitute.org/](http://gnomad.broadinstitute.org/) | RRID:SCR\_014964 | Used to retrieve population frequency data. |
| PLINK | v.1.9, v. 2.0 | [http\://www\.nitrc.org/projects/plink](http://www.nitrc.org/projects/plink) | RRID:SCR\_001757 | Used for genetic analyses. |
| Python Programming Language | 3.10.19 | [http\://www\.python.org/](http://www.python.org/) | RRID:SCR\_008394 | pandas; numpy; seaborn; matplotlib; io; sys; plotnine; glob; re; subprocess; scipy; collections; Used for general data wrangling/plotting/analyses |
| R Project for Statistical Computing | v.4.5.2 | [http\://www\.r-project.org/](http://www.r-project.org/) | RRID:SCR\_001905 | dplyr; tibble; meta; logistf; ggplot2; Used for general data wrangling/plotting/analyses |
| SAMtools | v.1.23.1 | [http\://samtools.sourceforge.net/mpileup.shtml](http://samtools.sourceforge.net/mpileup.shtml) | RRID:SCR\_005227 | Used for genomic file manipulation. |

&nbsp;
