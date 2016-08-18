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



# Define the header of the dashboard
header <- dashboardHeader(title = "Rielson Dashboard")

# Define the sidebar of the dashboard
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Bem-Vindo", tabName = "tab0"),
    
    menuItem("Tabela", tabName = "tab1"),
    
    menuItem("variavel", tabName = "tab3"),
    
    menuItem("Grafico", tabName = "tab4"),
    
    menuItem("Sumario", tabName = "tab2")
    
    
  )#SidebarMenu
)#Sidebar

# Define the body of the dashboard
body <- dashboardBody(
  tabItems(
    
    tabItem(tabName = "tab0",
            h3("Escolha uma das opções ao lado")

            
    ),
    
    # Tab 1
    tabItem(tabName = "tab1",
            h3("Tabela"),
            fluidRow(
              box(
                title = "Escolha um arquivo", 
                status = "primary",
                width = 4,
                fileInput('file1', 'Importe um arquivo',
                          accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                tags$hr(),
                checkboxInput('header1', 'Header', TRUE),
                radioButtons('sep1', 'Separator',
                             c(Comma=',',
                               Semicolon=';',
                               Tab='\t'),
                             ';'),
                radioButtons('quote1', 'Quote',
                             c(None='',
                               'Double Quote'='"',
                               'Single Quote'="'"),
                             '')
              ),
              box(
                title = "Data", 
                status = "primary",
                width = 8,
                tags$div(style="width:auto; height:auto; overflow:auto;padding:5px;",
                         dataTableOutput('contents1')
                )
              )
            )
    ),
    
    tabItem(tabName = "tab2",
            #checkboxInput("residcheck", "Show Residual Plot", FALSE),
            #h4("Regression Model"),
            #verbatimTextOutput("regression"),
            #plotOutput('residplot'),
            h4("Summary"),
            verbatimTextOutput("summary")
    
    ),
    
    tabItem(tabName = "tab3",
            h3("Variaveis"),
            #uiOutput("seletorvariavelx"),
            #uiOutput("seletorvariavely")
            numericInput("nvars", "Número de variáveis:", value = 1, min = 1, max = 2),
            uiOutput("seletorvariavelx"),
            conditionalPanel(
              cond = "input.nvars == 2", 
              uiOutput("seletorvariavely")
            )
            
    ),
  
    tabItem(tabName = "tab4",
            h3("Graficos não está funcionando"),
                        tabPanel("Table", 
                                 
                                 DT::dataTableOutput('data_table')),
                        
                        tabPanel("Plot",
                                 radioButtons("plot_type", "Select Plot Type:",
                                              c("point", "boxplot"),
                                              inline = TRUE),
                                 #actionButton("move_filtered", "Send Filtered Data to Main Table"),
                                 conditionalPanel(
                                   condition = "input.plot_type == 'point'", 
                                   plotOutput("plot1")),
                                              #brush = "plot_brush"),
                                   #DT::dataTableOutput('position')),
                                 conditionalPanel(
                                   condition = "input.plot_type == 'boxplot'",
                                   plotOutput("plot2"))
                                   #           brush = "plot_brush"),
                                   #DT::dataTableOutput('position2')),
                               #  conditionalPanel(
                                #   condition = "input.plot_type == 'line'",
                                 #  plotOutput("plot3")
                                  #            brush = "plot_brush"),
                                   #DT::dataTableOutput('position3')
                                 #)
                                 
                        )
    )
    
    
    
    
    
    #tabItem(tabName = "tab3", )
    # Close tabItems 
    
  )
  
  # Close body  
)

# Combine the UI of dashboard
ui <- dashboardPage(header, sidebar, body)
