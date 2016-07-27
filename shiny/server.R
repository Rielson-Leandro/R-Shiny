library(shiny)
# options(shiny.error = browser)

#=== Código aqui será carregado uma vez quando o aplicativo é iniciado ===
funConfig <- read.csv("input_control.csv", header=TRUE, sep = ",", quote = '"')

shinyServer(function(input, output, session) {
  #=== Código aqui será carregado quando um novo usuário se conecta ao aplicativo ===
  
  # Ler e exibir os dados
  table <- read.csv("data.csv", header = TRUE, sep = ",", quote = '"')
  output$table <- renderTable({
    # Mostrar a tabela
    
    table
  })
  
  # Preencher lista de seleção única com base no arquivo de configuração
  # As colunas do quadro de dados é de "fator" classe em vez de ' charactor '
  
  updateSelectInput(session, "input_funName", choices = as.character(funConfig$displayName))
  # browser()
  
  # ============= Debug ===============
  output$debug <- renderText({
    index <- which(funConfig$displayName == input$input_funName)
    
    paste( "We are here!!",
          funConfig[index, "needResponse"] == 1,
          funConfig[index, "funName"])
  })
  #====================================
  
  # UI entrada dinâmica com base na função selecionada pelo usuário  
  getFunIndex <- reactive({
    # O ideal será sempre um item selecionado
    # if (is.null(input$input_funName))
    #   return(0)
    
    which(funConfig$displayName == input$input_funName)
  })
  
  isResposeNeeded <- reactive({
    funConfig[getFunIndex(), "needResponse"] == 1
  })
  
  isSingleTerm <- reactive({
    funConfig[getFunIndex(), "singleTerm"] == 1
  })
  
  output$selectResponse <- renderUI({
    if (isResposeNeeded()) {
      selectInput("response", 'Dependent Variable', choices = names(table))
    } else {
      selectInput("response", 'Dependent Variable', choices = "")
    }
  })
  
  output$inputUI <- renderUI({
    if (isResposeNeeded()) {
      
      allColNames <- names(table)
      
      if (isSingleTerm()) {
        selectInput("terms", "Independent Variable", choices = allColNames[allColNames != input$response])        
      } else {
        checkboxGroupInput("terms", "Independent Variables", choices = allColNames[allColNames != input$response])
      }
      
    } else {
      # Se a função selecionada requer um argumento numérico (atualmente só suporta entrada numérico)
      reqArgName <- funConfig[getFunIndex(), "requiredArg"]
      if (reqArgName != "") {
        numericInput("reqArg", reqArgName, value = 3)            
      } else {
        return(NULL)
      }
    }
  })
  
  
  # Obter o nome da função real que R reconhece
  getFunName <- reactive({
    as.character(funConfig[getFunIndex(), "funName"])
  })
  
  # Compor a fórmula para análise de regressão
  getFormula <- reactive({
    if (length(input$terms) == 0) 
      return(NULL)
    
    as.formula(paste(input$response, " ~ ", paste(input$terms, collapse = " + ")))
  })
  
  # Obter os modelos equipados para ANOVA
  getFittedModels <- reactive({
    if (length(input$terms) == 0) 
      return(NULL)
    
    modelList <- list()
    i <- 1
    for (term in input$terms) {
      # browser()
      modelList[[i]] <- lm(as.formula(paste(input$response, " ~ ", term)), table)
      i <- i + 1
    }
    return(modelList)
  })
  
  
  # Executar a análise e obter o objeto de resultado
  # lm(formula, data)
  # glm(formula, family = gaussian, data)
  # anova(Object...) onde objeto é um ou mais embutidos objetos de resultado
  # chisq.test(x) em que X deve ser um grupo 2 - d matriz / tabela
  # kmeans(x, centers) - vamos esquecer isso por enquanto
  
  hasPlot <- TRUE
  hasSummary <- TRUE
  
  
  getFirstArg <- function(funName) {
    tryCatch({
      formalArgs(funName)[1]
    }, error = function(e) {
      return(NULL)
    } )
  }
  
  getResult <- reactive({
    # Reset session flag
    hasPlot <<- TRUE
    hasSummary <<- TRUE
    
    if (funConfig[getFunIndex(), "needResponse"] == 1) {
      if (is.null(getFormula()))
        return(NULL)
      
      funName <- getFunName();
      
      # Precisa atualizar as flags para o sumario
      
      switch (getFirstArg(funName),
        "formula" = do.call(funName, list(getFormula(), data = table)),
        "object" = { # fazer lm para cada variável independente
          hasPlot <<- FALSE
          hasSummary <<- FALSE
          
          return(do.call(funName, getFittedModels()))
        }, 
        "x" = {
          hasPlot <<- FALSE
          hasSummary <<- FALSE
          return(do.call(funName, list(x = table[, c(input$response, input$terms)])))
        } # passar na matriz 2 - D
      )
    } 
    else {
      # Se a função selecionada requer um argumento numérico (atualmente só suporta entrada numérico)
      reqArgName <- funConfig[getFunIndex(), "requiredArg"]
      if (reqArgName != "") {
        do.call(getFunName(), list(x=table, centers=input$reqArg))
        # hasSummary <<- FALSE
      } else {
        hasPlot <<- FALSE
        hasSummary <<- FALSE
        do.call(getFunName(), list(table))
      }
    }
  })
  
  # Display the plot
  output$plot <- renderPlot({
    if (is.null(getResult()) || !hasPlot)
      return(NULL)
    else
      with(table, plot(getResult()))
  })
  
    
  output$summary <- renderPrint({
    if (is.null(getResult())) {
      return(NULL)
    }

    if (hasSummary) {
      summary(getResult())
    } else {
      getResult()
    }
  })
})