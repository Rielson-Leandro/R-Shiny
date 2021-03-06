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
    
    if(is.null(inFile1)) {inFile1
      return(NULL)
    } else {
       read.csv2(inFile1$datapath, header=input$header1, sep=input$sep1, quote=input$quote1)
    }
  })
  
  output$contents1 <- renderDataTable({
    
    data.frame(callData())
    
  }, options = list(pageLength = 10))
  
  output$datas <- renderUI({
    teste <- callData()
    
  })

  
  output$seletorvariavelx <- renderUI({
    teste <- callData()
   
    selectInput("x", label = "selecione a variavel X:", 
                choices = c(colnames(teste)),
                selected = "Day"
    )
  })
   
      output$seletorvariavely <- renderUI({
        teste <- callData()
        
        selectInput("y", label = "Selecione a variavel Y:", 
                    choices = c(colnames(teste)),
                    selected = "Daily_Total_Points_Earned"
        )
        
      })
  
  
  
  ## Code for regression model
  runRegression <- reactive({
    
   
      regmod <- summary(lm(as.formula(paste(input$y," ~ ",paste(input$x,collapse="+"))),
                           callData()))
      regmod
    
    
    
  })
  
  
  ## Regression output
  output$regression <- renderPrint({
    runRegression()
    
    
  })
  
  ## Plot residuals
  output$residplot <- renderPlot({
    data <- as.data.frame(callData())
    regmod <- summary(lm(as.formula(paste(input$y," ~ ",paste(input$x,collapse="+"))),
                         callData()))
  
    data <- data[, input$y]
    if(input$residcheck){
      plot(data, regmod$residuals, xlab = input$y, ylab = 'Residuals')
      abline(0, 0)                  # the horizon
    }
    
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    data <- callData()
    if(input$nvars == "1"){
      summary(data[, input$x])
    }else{
    summary(data[, c(input$x, input$y)])
  }
  })
  
  ## Generate Plots using x and y inputs from UI
  
  output$plot1 <- renderPlot({
    data <- as.data.frame(callData())
    if(input$nvars == "1"){
      ggplot(data, aes_string(x = data[, input$x], y = input$y)) +
        geom_point(aes(color = factor(data[,input$x]))) + 
        geom_smooth(method = lm) 
    }else{
    ggplot(data, aes_string(x = data[,input$x], y = input$y)) +
      geom_point(aes(color = factor(data[,input$x]))) + 
      geom_smooth(method = lm) 
    }
  })
  
  ## Boxplot
  output$plot2 <- renderPlot({
    data <- as.data.frame(callData())
    
    ggplot(data, aes_string(x = data[,input$x], y = input$y)) +
      geom_point(aes(color = factor(data[,input$x]))) + 
      geom_boxplot(aes(color = factor(data[,input$x])),
                   alpha = 0.3, outlier.colour = 'red', outlier.size = 2.5)
  })
  
  
  ## Lineplot
  output$plot3 <- renderPlot({
    data <- as.data.frame(callData())
    ggplot(data = data, aes_string(x = data[,input$x], y = input$y)) +
      geom_point(aes(group = data, color = factor(data[,input$x]))) +
      geom_line(aes(color = factor(data[,input$y])))
  })
  
  
  ## Identify row of outlier
  output$position <- DT::renderDataTable({
    nearPoints(position, input$plot_click)
    brushedPoints(position, input$plot_brush)
    
  })
  
  output$position2 <- DT::renderDataTable({
    nearPoints(data.frame(callData()), input$plot_click)
    brushedPoints(callData(), input$plot_brush)
    
  })
  
  output$position3 <- DT::renderDataTable({
    nearPoints(data.frame(callData()), input$plot_click)
    brushedPoints(callData(), input$plot_brush)
    
  })
  
  
}
