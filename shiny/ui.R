library(shiny)

shinyUI(fluidPage(
  titlePanel("Pro_SPB"),
  sidebarLayout(
    sidebarPanel(
      selectInput('input_funName', 'Please select a function to execute:', 
                  c("Linear Regression", "Logistic Regression", "ANOVA", "Chi-Square")),
      tags$hr(),
      
      # Depende da função selecionada, uma variável de resposta pode ser necessária
      # Se a resposta ~ prazo: lista de seleção única + Radio Button/Check Boxes
      # Se única entrada : lista de seleção vazia + Entrada de texto com etiqueta dinâmica
      wellPanel( 
        # conditionalPanel(
        #   'reponseRequired === 1',
        #    selectInput('response', 'Dependent Variable', choices = "")
        # ),
        
        uiOutput("selectResponse"),
        uiOutput("inputUI")
        # Poderíamos também usar ConditionalPanel
      ),
      tags$hr(),

      h4("Debug Output"),
      textOutput("debug")
            
      # # Download      
      # radioButtons('format', 'Format', c('JPEG', 'PNG', 'PDF'), inline = TRUE),
      # downloadButton('downloadData', 'Download')
    ),
    
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Tabela", tableOutput('table')),
                  tabPanel("Grafico", plotOutput('plot')),
                  tabPanel("Sumario", verbatimTextOutput('summary'))
                  )
    )
  )
))