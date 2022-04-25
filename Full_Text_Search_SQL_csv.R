
# packages

library(shiny) 
library(RSQLite)
library(shinyWidgets)
library(DT)
library(DBI)
library(sqldf)

#library(odbc)
#library(dplyr)
#library(dbplyr)
#library(pool)
#library(ODB)


#create database file in R
#file <- read.csv("C:\\Users\\lisa-maria.kuso\\Documents\\shiny_SQL\\Datei\\database.csv")
file <- read.csv("database.csv")

# shiny layout
ui <- fluidPage(
  tags$h1("Full Text Search"),
  searchInput(
    inputId = "search",
    label = "Enter search query",
    value = "",
    placeholder = "e.g. fatty acid",
    btnSearch = icon("search"),
    btnReset = icon("remove", verify_fa = FALSE),
    width = "450px"
  ),
  DTOutput("table")
)

# Server function
server <- function(input, output, session){
 
# Connection with in memory from read-in csv.file  
  con <- dbConnect(RSQLite::SQLite(), ":memory:") 
  dbWriteTable(con, "database", file)
  dbListTables(con)

  
# form search query from input (in SQL language)/ here only names  
  sqlInput <- reactive({
    paste("SELECT * FROM database WHERE Names like '%",input$search,"%'
          OR contig LIKE '%",input$search,"%'
          OR ID LIKE '%",input$search,"%'
          OR Parent LIKE '%",input$search,"%'
          OR type LIKE '%",input$search,"%'")
  })

  
# Search query -> SQLite -> output 
  sqlOutput <- reactive({
    dbGetQuery(con, sqlInput())
  })


# show SQL output in data table 
  output$table <- DT::renderDT(sqlOutput(), server=TRUE, options=list(pageLength=10, dom='p, i'), selection = "single", rownames = F)


# disconnect database    
  cancel.onSessionEnded <- session$onSessionEnded(function() {
  dbDisconnect(con)
})
  
  } 



# Run the application 
shinyApp(ui = ui, server = server)
 
