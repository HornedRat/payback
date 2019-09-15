#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel("Payback"),

    # input
    fluidRow(
        column(10,
            textInput("gs_id",
                      "Wstaw Google Sheets ID",
                      value = "1aDyGgixKVlqRkbY7uDEaDTLKZ0ziNpEYZ_vaD7Wfx74",
                      width = '100%')
        ),
        column(2,
               actionButton('goButton', "EVALUATE"))
    ),
    fluidRow(column(12,
                    "Kliknij",
                    a("tutaj", href = "https://docs.google.com/spreadsheets/d/17Jsk2Pofc0ECHBekPc2cVSNEUNLToPm80E6QzdyjJSk/"),
                    "aby skopiować template arkusza do rozliczeń. Wrzuć go do Arkuszy Google, edytuj, a następnie wklej ID")),
    fluidRow(
        column(12,
               htmlOutput("text")
               )
    )

))
