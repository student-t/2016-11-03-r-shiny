# This file is generated from the corresponding .Rmd file



## =====
## Setup
## =====

install.packages("shiny")
install.packages("DT")

source("https://bioconductor.org/biocLite.R")
biocLite(c(
    "BSgenome.Scerevisiae.UCSC.sacCer3",
    "TxDb.Scerevisiae.UCSC.sacCer3.sgdGene",
    "GenomicRanges",
    "rtracklayer",
    "Gviz"))


# To upgrade an old Bioconductor installation
source("https://bioconductor.org/biocLite.R")
biocLite("BiocUpgrade")


## ============
## Hello, world
## ============

library(shiny)

ui_hello <- fluidPage(titlePanel("Hello world"))

server_hello <- function(input, output, session) { }

app_hello <- shinyApp(ui_hello, server_hello)
app_hello


class(ui_hello)
as.character(ui_hello)


class(app_hello)

# Various ways of running an app
runApp(app_hello)
runGadget(app_hello)
runGadget(app_hello, viewer=dialogViewer("App 1"))
print(app_hello)
app_hello


## ================
## input and output
## ================

ui_modulo <- fluidPage(
    titlePanel("Counting modulo app"),
    sliderInput("modulo", "Modulo", 1, 20, 10),
    sliderInput("step", "Step", 1, 20, 3),
    textInput("title", "Plot title", "A plot"),
    plotOutput("plotout"))

server_modulo <- function(input, output, session) {
    output$plotout <- renderPlot({
        plot((seq_len(100)*input$step) %% input$modulo, main=input$title)
    })
}

shinyApp(ui_modulo, server_modulo, options=list(height=800))


# An alternative UI layout
ui_modulo_2 <- fluidPage(
    titlePanel("Counting modulo app, sidebar layout"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("modulo", "Modulo", 1, 20, 10),
            sliderInput("step", "Step", 1, 20, 3),
            textInput("title", "Plot title", "A plot")),
        mainPanel(
            plotOutput("plotout"))))


## ===========================
## Shiny apps and Shiny Server
## ===========================

### ------------------------------
### App directory upload challenge
### ------------------------------
# 
# 1. Create a directory for an app. Name the directory in a way that
# will be unique, such as with your own name or a secret identity. We
# are going to upload it to a shared directory on a server.
# 
# 2. Save the code from one of the apps above to "app.R" in your
# directory. Modify the code to look or do something different if you
# like, such as plotting your favourite function.
# 
# 3. Run your app with:
# 

runApp("yourdirectoryname")

# 
# 4. Upload your app to our server with `scp`. Your instructor will give
# you details for how to do this.
# 
#
## =======================================
## Reactive expressions save recomputation
## =======================================

# Example of a reactive expression
y <- reactive(input$x + 1)

#or
y <- reactive({
    input$x + 1
})

#or
y <- reactive({
    return(input$x + 1)
})


#Later, in another reactive context where the value of the expression is needed
...
    y()
...


ui_pythagorus <- fluidPage(
    titlePanel("Hypotenuse app"),
    sliderInput("a", "Length a", 0, 10, 5),
    sliderInput("b", "Length b", 0, 10, 5),
    textOutput("result"))

server_pythagorus <- function(input, output, server) {
    a2 <- reactive({
        cat("Compute a squared.\n")

        input$a ** 2
    })

    b2 <- reactive({
        cat("Compute b squared.\n")

        input$b ** 2
    })

    output$result <- renderText({
        cat("Compute hypotenuse.\n")
        h <- sqrt(a2() + b2())
        cat("Done computing hypotenuse.\n")

        paste0("The hypotenuse is ", h)
    })
}

shinyApp(ui_pythagorus, server_pythagorus)


### -------------
### Tea challenge
### -------------
# 
# Muriel and Ronald are having an argument about tea. Muriel claims to
# be able to tell if tea or milk is poured into a cup first. An
# experiment is devised to test Muriel's claim. Eight cups of tea are
# made, four with tea first and four with milk first, and Muriel's
# accuracy is tested. She classifies all eight cups correctly. The
# results seem to confirm Muriel's claim, but Ronald wants to know how
# likely a result like this would have been if Muriel's supposed ability
# was simply luck.
# 

permutations <- function(items)
    do.call(cbind, lapply(seq_along(items),
        function(i) rbind(items[i], permutations(items[-i]))))

tea <- 3
milk <- 3
tea_correct <- 2
milk_correct <- 2

x <- c(rep(0,tea), rep(1,milk))
y <- c(rep(0,tea_correct), rep(1,tea-tea_correct),
       rep(0,milk-milk_correct), rep(1,milk_correct))
statistic <- sum(x == y)
x_perms <- permutations(x) # <- this is slow
distribution <- colSums(x_perms == y)
p <- mean(distribution >= statistic)

p

# 
# We'd like to explore how this test works with different inputs, but
# avoid unnecessary computation, especially calls to `permutations`.
# Even with eight cups there were quite a lot of permutations to
# consider. (It's possible to write much more efficient code than the
# above. In R you would normally use
# `fisher.test(x,y,alternative="greater")`. However, for the sake of a
# slightly silly exercise we will use the above.)
# 
#
####                             
#### Ronald's test as a Shiny app
####                             
# 

ui_tea <- fluidPage(
    titlePanel("Ronald's exact test"),
    numericInput("tea", "Tea first", 3),
    numericInput("milk", "Milk first", 3),
    numericInput("tea_correct", "Tea first correctly called", 2),
    numericInput("milk_correct", "Milk first correctly called", 2),
    textOutput("p_text"))

permutations <- function(items)
    do.call(cbind, lapply(seq_along(items),
        function(i) rbind(items[i], permutations(items[-i]))))

server_tea <- function(input, output, server) {
    output$p_text <- renderText( withProgress(message="Computing p", {
        x <- c(rep(0,input$tea), rep(1,input$milk))
        y <- c(rep(0,input$tea_correct), rep(1,input$tea-input$tea_correct),
               rep(0,input$milk-input$milk_correct), rep(1,input$milk_correct))
        statistic <- sum(x == y)
        x_perms <- permutations(x) # <- this is slow
        distribution <- colSums(x_perms == y)
        p <- mean(distribution >= statistic)

        paste0("p-value is ",p)
    }))
}

shinyApp(ui_tea, server_tea)

# 
#
####          
#### Challenge
####          
# 
# 1. Use what you have just learned to make this app more responsive.
# The slow part is the call to the `permutations` function. We would
# like to avoid re-running this unnecessarily.
# 
# 2. In the story, there were four cups of tea first and four cups of
# milk first, and Muriel was correct all eight times. Can Ronald
# reasonably reject the idea that Muriel's ability is due to chance?
# 
#
## ===========================================================
## tabsetPanel: what you can't see doesn't need to be computed
## ===========================================================

ui_tea_tabset <- fluidPage(
    titlePanel("Ronald's exact test"),
    tabsetPanel(
        tabPanel("Input",
            br(),
            numericInput("tea", "Tea first", 3),
            numericInput("milk", "Milk first", 3),
            numericInput("tea_correct", "Tea first correctly called", 2),
            numericInput("milk_correct", "Milk first correctly called", 2)),
        tabPanel("Result",
            br(),
            textOutput("p_text"))))

shinyApp(ui_tea_tabset, server_tea, options=list(height=500))


## ==============
## Genome browser
## ==============

### --------------------------------
### Genome browser challenge, part 1
### --------------------------------
# 
# The following code produces a diagram for a region of a genome. Your
# collaborator is asking you to make diagrams for a whole lot of
# different locations in the genome. Create a Shiny app to create these
# diagrams for them.
# 

library(GenomicRanges)
library(Gviz)
library(rtracklayer)
library(BSgenome.Scerevisiae.UCSC.sacCer3)
library(TxDb.Scerevisiae.UCSC.sacCer3.sgdGene)

genome <- BSgenome.Scerevisiae.UCSC.sacCer3
txdb <- TxDb.Scerevisiae.UCSC.sacCer3.sgdGene

# We want to be able to interactively specify this location:
location <- GRanges("chrI:140000-180000", seqinfo=seqinfo(genome))

axis_track <- GenomeAxisTrack()
seq_track <- SequenceTrack(genome)
gene_track <- GeneRegionTrack(
    txdb, genome=genome, name="Genes", showId=TRUE, shape="arrow")

# Load data, at a reasonable level of detail for width(location)
n <- min(width(location), 1000)
d1 <- rtracklayer::summary(
    BigWigFile("forward.bw"), location, n, "max")[[1]]
d2 <- rtracklayer::summary(
    BigWigFile("reverse.bw"), location, n, "max")[[1]]
data_track <- DataTrack(
    d1, data=rbind(d1$score,-d2$score), groups=c(1,2),
    name="PAT-seq", type="l", col="#000000", legend=FALSE)

plotTracks(
    list(axis_track, seq_track, gene_track, data_track),
    chromosome=as.character(seqnames(location)),
    from=start(location), to=end(location))

# 
# 
#
## ===============
## Updating inputs
## ===============

ui_updater <- fluidPage(
    titlePanel("Updating inputs demonstration"),
    textInput("text", "A text input", "I keep saying"),
    actionButton("button", "A button"))

server_updater <- function(input,output,session) {
    observeEvent(input$button, {
        updateTextInput(session, "text", value=paste(input$text, "without a shirt"))
    })
}

shinyApp(ui_updater, server_updater)


### --------------------------------
### Genome browser challenge, part 2
### --------------------------------
# 
# 1. Add buttons to your genome browser to navigate left and right,
# using the `shift` function for GRanges.
# 
# 2. (Optional, more difficult) Add buttons to zoom in and out.
# 
# 
# 
#
## =======
## Modules
## =======

ns <- NS("somenamespace")
ns("foo")
ns("bar")


# Define a trivial module

# In the UI, we use NS( ) to prefix all of the ids
mymodule_ui <- function(id) {
    ns <- NS(id)

    div(
        numericInput(ns("number"), "Number", 5),
        textOutput(ns("result")))
}

# callModule( ) will magically prefix ids for us in the server function
mymodule_server <- function(input, output, session, multiply_by) {
    output$result <- renderText({
        paste0(input$number, " times ", multiply_by, " is ", input$number * multiply_by)
    })
}


# Use the module in an app

ui_mult <- fluidPage(
    titlePanel("Demonstration of modules"),
    h2("Instance 1"),
    mymodule_ui("mod1"),
    h2("Instance 2"),
    mymodule_ui("mod2"))

server_mult <- function(input, output, session) {
    callModule(mymodule_server, "mod1", multiply_by=3)
    callModule(mymodule_server, "mod2", multiply_by=7)

    #Debugging
    observe( print(reactiveValuesToList(input)) )
}

shinyApp(ui_mult, server_mult)


### --------------
### Best practice?
### --------------

### --------------------------------
### Genome browser challenge, part 3
### --------------------------------
# 
# Adapt your genome browser to be a Shiny module. It should be usable
# with the following code:
# 

# Load your module code
source("browser.R")

ui_usebrowser <- fluidPage(
    titlePanel("Using a genome browser module"),
    browser_ui("browser"))

server_usebrowser <- function(input,output,session) {
    callModule(browser_server, "browser")
}

shinyApp(ui_usebrowser, server_usebrowser)

# 
# 
#
## ==========
## DataTables
## ==========

library(TxDb.Scerevisiae.UCSC.sacCer3.sgdGene)
txdb <- TxDb.Scerevisiae.UCSC.sacCer3.sgdGene

gene_df <- data.frame(
    gene=names(genes(txdb)),
    location=as.character(genes(txdb)),
    row.names=NULL, stringsAsFactors=FALSE)

ui_table <- fluidPage(
    titlePanel("Gene table"),
    DT::dataTableOutput("genes"))

server_table <- function(input,output,session) {
    output$genes <- DT::renderDataTable(
            server = TRUE,
            selection = "single",
            options = list(pageLength=10), {
        gene_df
    })

    observeEvent(input$genes_rows_selected, {
        cat("Selected:\n")
        print(input$genes_rows_selected)
        print(gene_df[ input$genes_rows_selected, ])
        # Wouldn't it be nice if something happened in response to this?
    })

    # Debugging:
    # observe(print(reactiveValuesToList(input)))
}

shinyApp(ui_table, server_table, options=list(height=600))


### --------------------------------
### Genome browser challenge, part 4
### --------------------------------
# 
# Add your genome browser module to the above DataTables app. When a row
# is selected, the genome browser should go to the appropriate location.
# 
# 
#
## ==================
## Shiny in Rmarkdown
## ==================

---
title: "A title"
output: html_document
runtime: shiny
---






## =======================
## Solutions to challenges
## =======================
