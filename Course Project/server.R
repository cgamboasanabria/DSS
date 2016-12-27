library(shiny)
library(caret)
library(rpart)
library(e1071)
library(rpart.plot)
data(iris)
inTrain<-createDataPartition(y=iris$Species, p = 0.7, list=FALSE)
training<-iris[inTrain,]
modFit<-train(Species~., method="rpart", data=training)

shinyServer(
function(input, output) {
  output$SpeciesPrediction<-renderText({
    userInput <-data.frame(input$id1,input$id3,input$id4,input$id2)
    names(userInput)<-c("Sepal.Length","Petal.Length","Petal.Width","Sepal.Width")
    levels(iris$Species)[predict(modFit,newdata=userInput)]
  })
  output$tree <- renderPlot({          
    prp(modFit$finalModel)                                       
  })
}
)