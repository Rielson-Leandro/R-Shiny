library(igraph)
library(plyr)
library(ggplot2)
library(TraMineR)
library(cluster)
library(ggmap)
library(reshape2)
library(shiny)
library(shinydashboard)
library(lsa)

options(shiny.maxRequestSize = 500*1024^2) # 500 MB limit upload



# Create server side of dashboard
server <- function(input, output) {
  
  ## Data Import
 
  callData <- reactive({
   inFile1 <- input$file1
    
    if(is.null(inFile1)) {
      return(NULL)
    } else {
       read.csv(inFile1$datapath, header=input$header1, sep=input$sep1, quote=input$quote1)
    }
   
   output$seletorvariavelx <- renderUI({
     if(input$file1 == "dados.csv") {
       variaveisA <- inFile1
     } else {
       if(input$varx != input$vary) {
         variaveisA <- inFile1[inFile1!= input$vary]
       } else {
         variaveisA <- inFile1
       }
     }
     
     selectInput("varx", "Variável x:", variaveisA, selected = input$varx)
   })
   
  })

  
  output$contents1 <- renderDataTable({
    
    
   callData()
    
  }, options = list(pageLength = 10))
  
  #Variável X e Y
  ## Generate Plots using x and y inputs from UI
  
  #Variável X
  
  
  #Variável Y
  output$seletorvariavely <- renderUI({
    variaveisB <- inFile1[inFile1 != input$varx]
    if(!is.null(input$vary)) {
      if(input$varx == input$vary) {
        selecionadaB <- variaveisB[1]
      } else {
        selecionadaB <- input$vary
      }
    } else {
      selecionadaB <- input$vary
    }
    selectInput("vary", "Variável y:", variaveisB, selected = selecionadaB)
  })
  
  output$output_recomm <- renderTable({
    recommendation()
  })
  
  
}
