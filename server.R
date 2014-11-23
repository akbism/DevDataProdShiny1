suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(WDI))
suppressPackageStartupMessages(library(ISOcodes))
suppressPackageStartupMessages(library(googleVis))
library(shinyIncubator)
indicators<-fread("data/WDI_April2013_CETS.csv")
data(ISO_3166_1)
FUN<-function(x) {
    nation<-ISO_3166_1[,2]
    x<-subset(x,select=-c(iso2c, region, income, lending))
    x<-x[x$iso3c %in% nation,]
    x[complete.cases(x),]
}

shinyServer(
    function(input, output, session) {
        mydata<-reactive({
            a<-FUN(WDI(indicator=c(input$id1, input$id2),country = "all",  extra=T))
            return(a)
        })
        output$table1<-renderDataTable(mydata()[order(mydata()$country, mydata()$year), ], options = list(sDom = "ilftr", bPaginate = FALSE))
        
        output$slider1<-renderUI({
            sliderInput("yr", "Year (Only for visualization):", min(mydata()$year), max(mydata()$year), min(mydata()$year), step = 1, 
                        animate=animationOptions(interval=4000, loop=T))
        }) 
        output$indicator1<-renderUI({
            selectInput("id1", "Indicator-I", choices=indicators$Series.Code, width="100%")
        }) 
        output$indicator2<-renderUI({
            selectInput("id2", "Indicator-II", choices=indicators$Series.Code, width="100%")
        })  
        
        ######
        ProcessedFilteredData <- reactive({
            v <- input$filtered_table
            col_names <- names(mydata())
            n_cols <- length(col_names)
            n_row <- length(v)/n_cols
            m <- matrix(v, ncol = n_cols, byrow = TRUE)
            df <- data.frame(m)
            names(df) <- col_names
            return(df)
        })
        
        output$downloadData <- downloadHandler(
            filename = function() { 'filtered_data.csv' }, content = function(file) {
                write.csv(ProcessedFilteredData(), file, row.names = FALSE)
            }
        )
        ######
        # output$text1<-renderText(paste("No of rows",dim(mydata())[1], "&", "No of columns",dim(mydata())[2]))
        my.text2<-reactive({
            b<-indicators$Series.Name[indicators$Series.Code==input$id1]
            return(b)
        })
        my.text3<-reactive({
            c<-indicators$Series.Name[indicators$Series.Code==input$id2]
            return(c)
        }) 
        output$text2<-renderText({my.text2()})
        output$text3<-renderText({my.text3()})
        output$ind<-renderDataTable({indicators})
        output$view_gviz1<-renderGvis({
            G1<-gvisMotionChart(mydata(),
                                idvar="country", 
                                timevar="year",
                                xvar=input$id1, 
                                yvar=input$id2,
                                sizevar=input$id1, colorvar=input$id2, date.format="%Y", 
            )
            G2<-gvisGeoChart(mydata()[mydata()$year==input$yr,],
                             locationvar="country", 
                             colorvar=input$id1,
                             options=list(height=230, colorAxis="{colors:['#FFFFFF', '#0000FF']}")) 
            
            G3<- gvisGeoChart(mydata()[mydata()$year==input$yr,],
                              locationvar="country", 
                              colorvar=input$id2,
                              options=list(height=230 )) 
            G23<- gvisMerge(G2,G3, horizontal=F)
            G123<- gvisMerge(G23,G1, horizontal=T)
            
            
            return(G123)
            
        })
        
        # outputOptions(output, "view_gviz1", suspendWhenHidden = FALSE)
        #        outputOptions(output, 'Visualization', suspendWhenHidden=FALSE)
    })
