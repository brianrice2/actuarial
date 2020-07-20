# Actuarial projects

Small projects relating to actuarial valuations. As of July 2020, this *is* a package so operates through functions as opposed to executing scripts.

## Shiny

The segment rates can also be viewed through shiny. To view, simply run `actuarial::run_shiny()`.

This is defined by the app.R file in `R/`. There's more info and some cool examples on the [Shiny website][4]. This app has also been deployed to shinyapps.io at http://brianrice2.shinyapps.io/actuarial_rates -- you can use this link instead of booting up RStudio.

## Behind the corporate bond rates

The Treasury High Quality Market (HQM) corporate bond yield curve drives many of the interest rates used in actuarial valuations. The following information is published in [James A Girola's report for the U.S. Department of the Treasury][1].

The basics:

* The Pension Protection Act of 2006 (PPA) mandates that Treasury publish a corporate bond yield curve for calculating the present values of pension liabilities and lump sum distributions. This yield curve represents the *corporate bond market* rather than the U.S. Treasury market - corporate bonds are much more heterogeneous than treasury bonds.
* The yield curve must be a single blended curve reflecting high quality corporate bonds, i.e., bonds rated AAA, AA, or A. The spot rate for each month is calculated as the average of that month's daily rates, so as to reduce volatility (side note: these daily rates do not seem to be publicly available).
* It must be projected for indefinitely long maturities beyond 30 years maturity. This is necessary because of the nature of pension liabilities - the yield curve may be used to discount cash flows well beyond 30 years into the future. The projected discount rates must be reliable and must reflect the behavior of long-term interest rates.
* The resulting rates are integral to actuarial valuations, and are used for projections, determining funding compliance, calculating present value of future cash flows, and much more.


Also see: [HQM White Papers][2] and [HQM Basic Concepts][3]

[1]: https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/hqm_pres.pdf
[2]: https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/pension_yieldcurve_020705.pdf
[3]: https://www.treasury.gov/resource-center/economic-policy/corp-bond-yield/Documents/ycp_oct2011.pdf
[4]: https://shiny.rstudio.com

## To Do

* Allow the Shiny app to pull in new data and update segment rates automatically
