
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

# path to database file (file already converted manually in SQLite)
# change path!
#sqlitePath <- "C:\\Users\\lisa-maria.kuso\\Documents\\shiny_SQL\\Datei\\database.db"
sqlitePath <- "database.db"

#create database file in R
#file <- read.csv("C:\\Users\\lisa-maria.kuso\\Documents\\shiny_SQL\\Datei\\database.csv")

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
  #con <- dbConnect(RSQLite::SQLite(), ":memory:") 
  #dbWriteTable(con, "database", file)
  #dbListTables(con)
  
# Connection with SQLite and database file
  con <- dbConnect(RSQLite::SQLite(), sqlitePath) 
  
# form search query from input (in SQL language)/ here only names  
  sqlInput <- reactive({
    paste("SELECT * FROM database WHERE Names like", "'%", input$search, "%';")
  })

  
# Search query -> SQLite -> output 
  sqlOutput <- reactive({
    dbGetQuery(con, sqlInput())
  })
  
  #dbDisconnect(con)      funktioniert nicht!!!

# show SQL output in data table 
  output$table <- DT::renderDT(sqlOutput(), server=TRUE, options=list(pageLength=10, dom='p, i'), selection = "single", rownames = F)
} 

# Run the application 
shinyApp(ui = ui, server = server)
 
