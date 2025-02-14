# **Chilean Mutual Funds Dataset**

This dataset aims to address the existing gap in the availability of data on the mutual funds industry in Chile. It contains 26,544 annual observations spanning the period 2012-2023, gathered from public and non-public administrative sources. This dataset is the result of a mentorship collaboration with the Comisión para el Mercado Financiero (CMF), providing a unique resource for financial research.

What makes this dataset distinctive is its scale, diversity, and integration of multiple levels of aggregation and classification, enabling new opportunities for in-depth analysis within the financial research community.

## Repository Contents
This repository provides the main scripts used for data collection, processing, and initial merging.

## 1. Scripts
**Python Scripts** (located in the `Scripts` folder)

Used to collect internal regulations files from all active mutual funds.
Processed to create one of the dataset’s key classifications: type of investor.

**Stata Scripts**

Process public daily data from:
- "Cartolas Diarias" (daily transaction records)
- "Cartola de Costos" (cost reports)
- "Archivo de Identificación" (fund identification archive)
## 2. Data
The `Data` folder contains:

- Processed CSV files extracted from AAFM (Asociación de Fondos Mutuos), which publishes mutual fund share prices in their news section.
- Raw TXT data from Cartolas Diarias, obtained manually due to website captcha restrictions that make web scraping difficult.
- Unprocessed internal regulations files for ongoing funds, collected using our Python tool.
  
This repository provides essential tools and resources for researchers and analysts interested in exploring Chile’s mutual fund industry.
