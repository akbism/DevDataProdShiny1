suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(markdown))
indicators<-fread("data/WDI_April2013_CETS.csv")
shinyUI(fluidPage(
    titlePanel("World Development Index Explorer"),
    tags$head(
        tags$style(type="text/css", "tfoot {display: table-header-group}") # Move filters to top of datatable
    ),
    sidebarLayout(
        sidebarPanel( h4("Select Indicators"), br(),                      
                      uiOutput("indicator1"),
                      textOutput("text2"), br(),
                      uiOutput("indicator2"),
                      textOutput("text3"), br(),
                      uiOutput("slider1")
        ),
        
        
        mainPanel(
            navbarPage("WDI Analytics", 
                       tabPanel("About", 
                                h6(img(src="WB1.png", height = 100, width = 100),
                                    "Source:", a("The World Bank", href="http://data.worldbank.org/data-catalog/world-development-indicators"),HTML("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
                                    "Application Developed By:", a("Amar Kumar", href="http://in.linkedin.com/in/amar03/")),
                                includeMarkdown("include.md")), 
                       tabPanel("Indicators Details", dataTableOutput('ind')),
                       tabPanel("WorldBank Data", 
                                HTML('
                            <script type="text/javascript">
                            $(document).ready(function() {
                            $("#downloadData").click(function() {
                                var filtered_table_data = $("#table1").find("table").dataTable()._("tr", {"filter":"applied"});
                                Shiny.onInputChange("filtered_table", filtered_table_data);
                                                    });
                                                });
                                </script>
               			    '),
                                downloadButton('downloadData', 'Download WDI Data'),
                                dataTableOutput('table1')),
                       # tabPanel("Animated Dashboard",textOutput("text1"), htmlOutput("view_gviz1"))
                       tabPanel("Animated Dashboard","Indicator I: Blue & Indicator II: Green", htmlOutput("view_gviz1"))
            )        
            
        ))
)
)