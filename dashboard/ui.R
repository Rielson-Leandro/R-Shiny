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
    menuItem("Welcome", tabName = "tab0"),
    
    menuItem("Tabela", tabName = "tab1"),
    
    menuItem("Tabela", tabName = "tab2")
    
  )#SidebarMenu
)#Sidebar

# Define the body of the dashboard
body <- dashboardBody(
  tabItems(
    
    # Tab 1
    tabItem(tabName = "tab1",
            h3("Pegou"),
            h5(""),
            fluidRow(
              box(
                title = "Call data input", 
                status = "primary",
                width = 4,
                fileInput('file1', 'Choose CSV File',
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
  
      numericInput("nvars", "Número de variáveis:", value = 1, min = 1, max = 2),
      uiOutput("seletorvariavelx")
    
    )
    #tabItem(tabName = "tab3", )
    # Close tabItems 
    
  )
  
  # Close body  
)

# Combine the UI of dashboard
ui <- dashboardPage(header, sidebar, body)
