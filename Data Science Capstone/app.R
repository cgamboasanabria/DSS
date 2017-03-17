suppressWarnings(library(shiny))
suppressWarnings(library(tidytext))
suppressWarnings(library(dplyr))

ui<-fluidPage(
   
   # Application title
   titlePanel("Word prediction with n-grams"),
   
   # Sidebar with a slider input for text
   sidebarLayout(
      sidebarPanel(
          helpText("Enter a sentence to begin the next word prediction"),
          textInput("inputString", "Enter your text here", value = ""),
          br(),
          br(),
          br(),
          br()
      ),
      
      # Show the predicted word
      mainPanel(
          h2("Predicted Next Word"),
          verbatimTextOutput("prediction"),
          strong("Sentence Input:"),
          tags$style(type='text/css', '#text1 {background-color: rgba(255,255,0,0.40); color: blue;}'), 
          textOutput('text1'),
          br()
    
      )
   )
)

load("./ngrs.RData")

coincidence<-function(txt, ngr){
    #cleaning
    txt<-gsub(",", "", txt)
    txt<-gsub("[.]", "", txt)
    txt<-gsub(";", "", txt)
    txt<-gsub(":", "", txt)
    #spliting word
    x<-strsplit(txt, " ")
    
    #Last ngr words
    pos<-(length(x[[1]])-ngr+1):length(x[[1]])
    
    words<-paste(c(x[[1]][pos]), collapse = ' ')
    
    #coincidences in ngr-gram
    load("./ngrs.RData")
    
    ngrinit<-ngrs[[ngr]]%>%
        filter(word==paste(c(x[[1]][pos]),
                           collapse = ' '))
    if(dim(ngrinit)[1]>0){
        
        #matching ngr+1-gram
        ngrfinal<-ngrs[[ngr+1]]
        ngrfinal<-filter(ngrfinal,
                         grepl(paste("^",
                                     ngrinit$word,
                                     sep=""),
                               ngrfinal$word)==TRUE)
        
        #suggested word
        d<-dim(unnest_tokens(ngrfinal, final, word))[1]
        if(d>0){
            secu<-seq(ngr+1, d, by=ngr+1)
            full<-unnest_tokens(ngrfinal, sug, word)[secu, 2]%>%
                count(sug, sort=TRUE)
            full[, 1]
        }else paste("No coincidences")
    } else paste("No coincidences")
}

suggested<-function(x){
    
    l<-list()
    for(i in 9:2){
        l[i]<-coincidence(x, i)
    }
    
    vec<-NULL
    for(i in 1:8){
        vec[i]<-("No coincidences"%in%l[[i]])
    }
    
    l[[min(which(vec==TRUE))-1]] 
}


# Define server
server<-shinyServer(function(input, output) {
    output$prediction <- renderPrint({
        leng<-length(strsplit(input$inputString, " ")[[1]])
        result <-ifelse(leng==0, "Type a word", if(leng<8){
            if(coincidence(tolower(input$inputString), leng)!="No coincidences"){
                coincidence(tolower(input$inputString), leng)[[1]]
            }else(if(coincidence(tolower(input$inputString), leng-1)!="No coincidences"){
                coincidence(tolower(input$inputString), leng-1)[[1]]
            }else(coincidence(tolower(input$inputString), leng-3)[[1]]))
        }else(suggested(tolower(input$inputString))))
        result
    });
    
    output$text1 <- renderText({
        input$inputString});
}
)

# Run the application 
shinyApp(ui = ui, server = server)

