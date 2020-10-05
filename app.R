#
#
# We want to build a shiny App that has mutltiple
# functions:

# 1) App that contains all the WhatsR-functions and necessary dictionaries, example files etc.
# 2) Ability to upload txt file and parse it
# 3) Radiobuttons to control settings for parsing
# 4) Control panels for redrawing plots with other settings

# 4) multiple panes:
# - How to extract WhatsApp Data with pictures
# - Show parsed head of table, filterable by date
# - Download parsed Version as Rdataframe
# - Show statistics summary and plots

# 5) Going crazy:
# - Download nicely formatted PDF of statistical analysis + Plots
# - Using HTML and CSS to make it look pretty
# - Write a LaTeX template that recreates WhatsApp PDF logfiles from the dataframe

# setting working directory
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# fixing font issue when running on Windows
# extrafont::loadfonts(device="win")

# installing packages (This might need to be done manually on a server with root access)
if (!"devtools" %in% installed.packages()) {

  install.packages("devtools")
}

if (!"shiny" %in% installed.packages()) {

  install.packages("shiny")
}

if (!"shinythemes" %in% installed.packages()) {

  install.packages("shinythemes")
}

if (!"shinyWidgets" %in% installed.packages()) {

  install.packages("shinyWidgets")
}

if (!"shinyjs" %in% installed.packages()) {

  install.packages("shinyTime")
}

if (!"DT" %in% installed.packages()) {

  install.packages("DT")
}

if (!"ggplot2" %in% installed.packages()) {

  install.packages("ggplot2")
}

if (!"rsconnect" %in% installed.packages()) {

  install.packages("rsconnect")
}

if (!"WhatsR" %in% installed.packages()) {

  devtools::install_github("gesiscss/WhatsR")
}


# shiny backend
library(shiny)
library(shinythemes)
library(shinyWidgets)
library(shinyjs)
library(shinyTime)
library(DT)
library(ggplot2)
library(rsconnect)
library(WhatsR)



# Define UI for application that draws a histogram
ui <- fluidPage(theme  = shinytheme("flatly"),

                ### Setting up shiny JS
                useShinyjs(),


                ########### Styling ################

                setBackgroundColor("#ECE5DD"),

                tags$style(type = 'text/css',
                           '.navbar { background-color: #25D366  ;}',
                           '.navbar-default .navbar-brand{color: white;}',
                           '.tab-panel{ background-color: red   ; color: white}',
                           '.nav navbar-nav li.active:hover a, .nav navbar-nav li.active a {
                            background-color: orange ;
                            border-color: purple    ;
                            }'
                ),

                ###############  MAIN PAGE ###############

                navbarPage(tags$img(height = 35, width = 35, src = "WhatsR_logo.png"),

                           tabPanel("Overview",

                                    column(tags$p(HTML("<h1 align='center'> WhatsR </h1>"),
                                                  "The WhatsR app is a parser for exported WhatsApp Chat messages.
                                       That means that you can upload a WhatsApp Chatlog file to this
                                       Website and your data will be converted from a plain text file to
                                       an R dataframe with information about each message organized in columns
                                       (like an Excel sheet). You can then download the data to play around with it
                                       yourself or you can use this website to show you some cool   statistical analyses
                                       done with your chatlog. You can also download the necessary R-functions and
                                       parse the files on your local computer using this", tags$a(href = "https://github.com/JuKo007/WhatsR","R package.")
                                                  , "The package and this corresponding app were written with the goal to enable parsing of WhatsApp messages from both iOS and
                                       Android devices, from phones with different date and time settings (this influences how the exported text
                                       files look like and how they have to be analyzed) and to be relatively easily expandable to multiple languages. Currently,
                                       only English and German are supported though."),

                                           tags$p(HTML("<h1 align='center'> Disclaimer </h1>"),
                                                  "The R-package and the corresponding app are still in its development. The code is still ugly and
                                       inefficient. Both the R-package and this app will be subject to change. Should you be facing any issues or odd
                                       behavior, please report it",tags$a(href = "https://github.com/gesiscss/WhatsR/issues","here.")),

                                           tags$p("Neither the R-package, nor this app are in any way related to, supported or endorsed by the WhatsApp company. They are
                                       meant to be a scientific tool for analysis of interpersonal social relationships and as a gadget for
                                       quantified self enthusiasts interested in visualizing their own interpersonal relationships."),

                                           tags$p("You should use this software responsibly. If you want to analyze a chatlog you exported, you should
                                       ask all members of that chat for their permission. You should also be carefull to never share your
                                       raw or parsed chatlog files with anybody except the members of the chat. Every chat very likely contains highly
                                       personal data such as phone-numbers, links to social media accounts and intimate conversations."),

                                           tags$p(HTML("<h1 align='center'> FAQ </h1>"),
                                                  tags$strong("What is the goal of this parser?"),
                                                  HTML("<br>"),
                                                  "It is supposed to be a tool for scientifc analysis of interpersonal relationships
                                       in research conducted with informed and consenting participants. Certain aspects of
                                       interpersonal communication patterns (e.g. who's contacting whom, when, how often, which emojies
                                       are used, the sentiment of exchanges messages etc.) might help researchers to quantify
                                       interpersonal relationships in greater detail and at better resolution. The parser helps to structure
                                       the chatlogs in such a way that further analysis becomes a lot easier without the need to directly interact
                                       with the raw files.If you are using the web app or the R-package, your data is ",tags$strong("NOT"),
                                                  "used for research purposes and will only be visible to you."),

                                           tags$p(tags$strong("Is it safe to upload my chatlogs to this app?"),HTML("<br>"),
                                                  "This app was build using the", tags$a(href = "https://cran.r-project.org/web/packages/shiny/shiny.pdf","shiny R-package."),
                                                  "As such, data from users is processed in seperate containers and no user will be able to
                                       access data of another user. This app does neither safe raw or parsed data uploaded or generated by the users, nor
                                       any information about the users themselves. The source code of the app is available in the repository of the R-package
                                       linked above. If you are concered about security, you can always download the R-package and process files on
                                       your local machine rather than using this app."),

                                           tags$p(tags$strong("Why is my language not available?"),HTML("<br>"),
                                                  "To make this parser work with a language, it needs some information about text that is
                                       inserted by WhatsApp into the chatfile for specific actions such as attached files, adding
                                       new friends to a group, missed calls, live locations etc. These texts are different in every language
                                       and also different on iOS and Android. An attached file on a German android phone would generate the pattern
                                       'FILENAME (Datei angehängt)', on an English android phone it would be 'FILENAME (file attached)' and on an english
                                       iOS phone it would be '<attached: FILENAME>'. To make this parser work in a specific language, these patterns have
                                       to be added as regular expressions to its language database. If you are willing to extract these manually from a
                                       chatfile in your language, I will gladly add them to the language database and update the package and this app."),

                                           width = 6, offset = 3)

                           ),

                           tabPanel("Example",

                                    column(


                                      tags$p(HTML("<h1 align='center'> Example Data </h1>"),
                                             HTML("<br>"),
                                             "If you do not want to analze your own data or want to check first what this
                                    parser does, you can find a small example file below. If you click on the button
                                    below the displayed example data, your browser will download the file and you can use this file in the 'Upload Date' tab."),

                                      HTML("<br>"),

                                      tags$br(),

                                      tags$img(height = 629,
                                               width = 1064,
                                               src = "ExampleData.jpg"),

                                      tags$br(),
                                      tags$br(),

                                      width = 6, offset = 3

                                    ),

                                    column(

                                      downloadButton(outputId = "ExampleDownload", label = "Download Example Data", style = "text-align: center")
                                      , width = 5, offset = 5)

                           ),

                           tabPanel("Upload Data",

                                    sidebarLayout(
                                      sidebarPanel(

                                        fileInput(inputId = "file", label = "Select your exported WhatsApp .txt chatfile",
                                                  accept = "text/plain"),

                                        radioButtons("os", "Which operating System were the messages extracted from",
                                                     c("Android" = "android", "Iphone" = "ios")
                                        ),
                                        radioButtons("language", "Whats the language setting of the phone the messages where extracted from?",
                                                     c("English" = "english", "German" = "german")
                                        ),
                                        radioButtons("media", "Were media files included in the extraction?",
                                                     c("Yes" = TRUE, "No" = FALSE)
                                        ),
                                        radioButtons("Anon", "Do you want to anonimze the names of chat participants?",
                                                     c("Yes" = TRUE, "No" = FALSE, "Add anonimized column" = "both")
                                        ),
                                        radioButtons("URL", "Do you want to shorten send links to domain names?",
                                                     c("Yes" = "domain", "No" = FALSE)
                                        ),

                                        actionButton(inputId = "submit", label = "Upload File", class = "btn-warning")
                                      ),

                                      mainPanel(

                                        column(tags$p(HTML("<h1 align='center'> WhatsR </h1>"),
                                                      "The WhatsR app is a parser for exported WhatsApp Chat messages.
                                       That means that you can upload a WhatsApp Chatlog file to this
                                       Website and your data will be converted from a plain text file to
                                       an R dataframe with information about each message organized in columns
                                       (like an Excel sheet). You can then download the data to play around with it
                                       yourself or you can use this website to show you some cool   statistical analyses
                                       done with your chatlog. You can also download the necessary R-functions and
                                       parse the files on your local computer using this", tags$a(href = "https://github.com/JuKo007/WhatsR","R package.")
                                                      , "The package and this corresponding app were written with the goal to enable parsing of WhatsApp messages from both iOS and
                                       Android devices, from phones with different date and time settings (this influences how the exported text
                                       files look like and how they have to be analyzed) and to be relatively easily expandable to multiple languages. Currently,
                                       only English and German are supported though."),

                                               tags$p(HTML("<h1 align='center'> Disclaimer </h1>"),
                                                      "The R-package and the corresponding app are still in its development. The code is still ugly and
                                       inefficient. Both the R-package and this app will be subject to change. Should you be facing any issues or odd
                                       behavior, please report it",tags$a(href = "https://github.com/gesiscss/WhatsR/issues","here.")),

                                               tags$p("Neither the R-package, nor this app are in any way related to, supported or endorsed by the WhatsApp company. They are
                                       meant to be a scientific tool for analysis of interpersonal social relationships and as a gadget for
                                       quantified self enthusiasts interested in visualizing their own interpersonal relationships."),

                                               tags$p("You should use this software responsibly. If you want to analyze a chatlog you exported, you should
                                       ask all members of that chat for their permission. You should also be carefull to never share your
                                       raw or parsed chatlog files with anybody except the members of the chat. Every chat very likely contains highly
                                       personal data such as phone-numbers, links to social media accounts and intimate conversations."),

                                               tags$p(HTML("<h1 align='center'> FAQ </h1>"),
                                                      tags$strong("What is the goal of this parser?"),
                                                      HTML("<br>"),
                                                      "It is supposed to be a tool for scientifc analysis of interpersonal relationships
                                       in research conducted with informed and consenting participants. Certain aspects of
                                       interpersonal communication patterns (e.g. who's contacting whom, when, how often, which emojies
                                       are used, the sentiment of exchanges messages etc.) might help researchers to quantify
                                       interpersonal relationships in greater detail and at better resolution. The parser helps to structure
                                       the chatlogs in such a way that further analysis becomes a lot easier without the need to directly interact
                                       with the raw files.If you are using the web app or the R-package, your data is ",tags$strong("NOT"),
                                                      "used for research purposes and will only be visible to you."),

                                               tags$p(tags$strong("Is it safe to upload my chatlogs to this app?"),HTML("<br>"),
                                                      "This app was build using the", tags$a(href = "https://cran.r-project.org/web/packages/shiny/shiny.pdf","shiny R-package."),
                                                      "As such, data from users is processed in seperate containers and no user will be able to
                                       access data of another user. This app does neither safe raw or parsed data uploaded or generated by the users, nor
                                       any information about the users themselves. The source code of the app is available in the repository of the R-package
                                       linked above. If you are concered about security, you can always download the R-package and process files on
                                       your local machine rather than using this app."),

                                               tags$p(tags$strong("Why is my language not available?"),HTML("<br>"),
                                                      "To make this parser work with a language, it needs some information about text that is
                                       inserted by WhatsApp into the chatfile for specific actions such as attached files, adding
                                       new friends to a group, missed calls, live locations etc. These texts are different in every language
                                       and also different on iOS and Android. An attached file on a German android phone would generate the pattern
                                       'FILENAME (Datei angehängt)', on an English android phone it would be 'FILENAME (file attached)' and on an english
                                       iOS phone it would be '<attached: FILENAME>'. To make this parser work in a specific language, these patterns have
                                       to be added as regular expressions to its language database. If you are willing to extract these manually from a
                                       chatfile in your language, I will gladly add them to the language database and update the package and this app."),

                                               width = 10, offset = 1)
                                      ),
                                    )
                           ),

                           tabPanel("Explore Data",

                                    sidebarPanel(

                                      checkboxGroupInput("show_vars", "Select Columns to display:",

                                                         choices = c(""),

                                                         selected = c("")),

                                      tags$br(),
                                      tags$br(),
                                      actionButton("excludeRows", "Exclude selected Rows"),
                                      tags$br(),
                                      tags$br(),
                                      actionButton("RestoreRows", "Restore all excluded rows"),
                                      tags$br(),
                                      tags$br(),
                                      downloadButton("downloadData", "Download all Data"),
                                      tags$br(),
                                      tags$br(),
                                      downloadButton("downloadSelection", "Download selected Data")),

                                    mainPanel(DTOutput("frame"))

                                    ),

                           tabPanel("Results",

                                    tabsetPanel(type = "tabs",

                                                tabPanel("Messages",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_msg", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate1",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate1",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-01-19 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      actionButton("MsgUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("message1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("message2"),
                                                           tags$br(),
                                                           plotOutput("tokensbwah1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("tokensbwah2")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Wordcloud",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_wc", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate2",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00" ,placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate2",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07",  placeholder = "2020-11-01 09:30:00"),

                                                                      actionButton("WCUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("wordcloud1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("wordcloud2")

                                                         ),

                                                         width = 6, offset = 5),


                                                tabPanel("Lexical Dispersion",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      textInput("LeDiPlo_text", HTML("Word <br/> Enter a word to use it in a lexical dispersion plot"), value = "test", width = NULL, placeholder = NULL),

                                                                      checkboxGroupButtons("Sender_input_lediplo", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate3",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate3",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      actionButton("LeDiPloUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("lexicaldispersion1")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Links",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_links", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate4",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate4",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      sliderInput("LinkMinimum","Minimum Occurance of Domain to be included in plots", min = 1, max = 100, value = 5),

                                                                      actionButton("LinksUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("links1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("links2"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("links3", height = 800),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("links4")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Smilies",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_smilies", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate5",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate5",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      sliderInput("SmilieMinimum","Minimum Occurance of Smilie to be included in plots", min = 1, max = 100, value = 5),

                                                                      actionButton("SmilieUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("smilies1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("smilies2"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("smilies3"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("smilies4")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Emojis",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_emoji", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate6",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate6",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      sliderInput("EmojiMinimum","Minimum Occurance of Emoji to be included in plots", min = 1, max = 100, value = 5),

                                                                      actionButton("EmojiUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("emoji1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("emoji2"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("emoji3", height = 800),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("emoji4", height = 800)

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Locations",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_location", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate7",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"),value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate7",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      actionButton("LocUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("location1")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Replies",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_replies", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate8",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"),value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate8",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      actionButton("ReplyUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("replytime1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("replytime2")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Media",

                                                         sidebarPanel(h3("Visualization Settings"),

                                                                      checkboxGroupButtons("Sender_input_media", HTML("Sender <br/> Select a list of Senders to be included in the plots, all others will be ignored"), "Upload chatfile to see List of Senders"),

                                                                      textInput("startdate9",HTML("Starting Date <br/> Enter the date and time from which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      textInput("enddate9",HTML("Ending Date <br/> Enter the date and time until which you want to include data into the plot in this format: <br/> yyyy-mm-dd hh:mm:ss"), value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      actionButton("MediaUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("media1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("media2"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("media3"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("media4")

                                                         ),

                                                         width = 6, offset = 5)

                                          )



                                    ),

                                    tabPanel("Impressum",

                                             column(tags$p("Julian Kohne,"), tags$br(),
                                                    tags$p("GESIS - Leibniz Institute for the Social Sciences,"), tags$br(),
                                                    tags$p("Unter Sachsenhausen 6 - 8,"), tags$br(),
                                                    tags$p("50667 Cologne,"), tags$br(),
                                                    tags$p("Tel.: 0221/47694-0,"), tags$br(),
                                                    tags$p("Email: Julian•Kohne[at]gesis•org"),


                                                    width = 6, offset = 5)

                                    ),

                           tabPanel("Testing Stuff",

                                    #textOutput("rows"),
                                    textOutput("unique_senders")

                           )

))

# Define server logic
server <- function(input, output, session) {

  # creating reactive value
  rv <- reactiveValues(data = NULL)

  # hiding the download buttons if no file has been uploaded
  observe({
    shinyjs::hide("downloadData")

    if (is.data.frame(rv$data))
      shinyjs::show("downloadData")
  })

  observe({
    shinyjs::hide("downloadSelection")

    if (is.data.frame(rv$data))
      shinyjs::show("downloadSelection")
  })

  observe({
    shinyjs::hide("excludeRows")

    if (is.data.frame(rv$data))
      shinyjs::show("excludeRows")
  })

  observe({
    shinyjs::hide("RestoreRows")

    if (is.data.frame(rv$data))
      shinyjs::show("RestoreRows")
  })

  ####### Testing StackOverflow Solution

  # parsing function for data upload
  observeEvent(input$submit, {

    # require inputs
    req(input$file)

    # reading the data in
    rv$data <- parse_chat(name = input$file$datapath,
                          EmojiDic = "internal",
                          smilies = 2,
                          anon = input$Anon,
                          media = input$media,
                          web = input$URL,
                          order = "both",
                          language = input$language,
                          os = input$os,
                          rpnl = " start_newline ",
                          rpom = " media_omitted ")

    # making an internal copy
    rv$copy <- rv$data

  })

  # row exclusion
  observeEvent(input$excludeRows,{

    # require inputs
    req(rv$copy,input$show_vars,input$frame_rows_selected)

    # subset copy
    rv$copy <- rv$copy[-c(input$frame_rows_selected),c(input$show_vars)]

  })

  # row restoration
  observeEvent(input$RestoreRows,{

    # require inputs
    req(rv$copy,input$show_vars)

    # resetting copy
    rv$copy <- rv$data[,c(input$show_vars)]

  })

  # rendering copy of the dataframe
  output$frame <- renderDT({
    datatable(rv$copy[,c(input$show_vars)])
  })


  ####### backend for downloading parsed data



  # Allow for download of complete parsed Data
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$file$name, "_parsed.rds", sep = "\t")
    },
    content = function(file) {
      saveRDS(rv$data, file, version = 2)
    }
  )

  # Allow for download of parsed Data
  output$downloadSelection <- downloadHandler(
    filename = function() {
      paste(input$file$name, "_parsed_selection.rds", sep = "\t")
    },
    content = function(file) {
      saveRDS(rv$copy, file, version = 2)
    }
  )

  ####################### UPDATING INPUT SELECTION OPTIONS

  observeEvent(input$submit, {

    ### Updating selection of columns
    updateCheckboxGroupInput(session,
                             "show_vars",
                             choices = colnames(rv$data),
                             selected = colnames(rv$data)[1:12])


    ### Updating all Sender selections for all analyses
    updateCheckboxGroupButtons(session,
                               "Sender_input_msg",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_wc",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_lediplo",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_links",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_smilies",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_emoji",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_location",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_replies",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    updateCheckboxGroupButtons(session,
                               "Sender_input_media",
                               choices = unique(as.character(rv$data$Sender)),
                               selected = unique(as.character(rv$data$Sender)))

    ### Updating all selected dates to the minimum and maximum timestamps in the uploaded chat

    updateTextInput(session,
                    "startdate1",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate1",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate2",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate2",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate3",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate3",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate4",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate4",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate5",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate5",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate6",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate6",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate7",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate7",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate8",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate8",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

    updateTextInput(session,
                    "startdate9",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[1]))

    updateTextInput(session,
                    "enddate9",
                    value = gsub("[a-zA-Z]", " ", rv$data$DateTime[length(rv$data$DateTime)]))

  })


  ######################### GENERATING PLOTS

  # updating the plots when a button is pressed or a new dataset is uploaded
  observeEvent(c(input$submit,input$MsgUpdate),{

    output$message1 <- renderPlot({req(rv$data);plot_messages(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1)}, res = 100)
    output$message2 <- renderPlot({req(rv$data);plot_messages(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1, plot = "pie")}, res = 100)
    output$tokensbwah1 <- renderPlot({req(rv$data);plot_tokens(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1, plot = "cumsum")}, res = 100)
    output$tokensbwah2 <- renderPlot({req(rv$data);plot_tokens_over_time(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1, plot = "heatmap")}, res = 100)

  })

  observeEvent(c(input$submit,input$WCUpdate),{

    output$wordcloud1 <- renderPlot({req(rv$data);plot_wordcloud(rv$data, names = input$Sender_input_wc, starttime = input$startdate2, endtime = input$enddate2)}, res = 100)
    output$wordcloud2 <- renderPlot({req(rv$data);plot_wordcloud(rv$data, comparison = TRUE, names = input$Sender_input_wc, starttime = input$startdate2, endtime = input$enddate2)}, res = 100)

  })


  observeEvent(c(input$submit,input$LeDiPloUpdate),{

    output$lexicaldispersion1 <- renderPlot({req(rv$data);plot_lexical_dispersion(rv$data, keywords = input$LeDiPlo_text, names = input$Sender_input_lediplo, starttime = input$startdate3, endtime = input$enddate3)}, res = 100) # We still need to add a Keyword here

  })

  observeEvent(c(input$submit,input$LinksUpdate),{

    output$links1 <- renderPlot({req(rv$data);plot_links(rv$data, plot = "cumsum", names = input$Sender_input_links, starttime = input$startdate4, endtime = input$enddate4, min.occur = input$LinkMinimum)}, res = 100)
    output$links2 <- renderPlot({req(rv$data);plot_links(rv$data, plot = "heatmap", names = input$Sender_input_links, starttime = input$startdate4, endtime = input$enddate4, min.occur = input$LinkMinimum)}, res = 100)
    output$links3 <- renderPlot({req(rv$data);plot_links(rv$data, plot = "bar", names = input$Sender_input_links, starttime = input$startdate4, endtime = input$enddate4, min.occur = input$LinkMinimum)}, res = 100, height = 800) # We still need a min.occur value here
    output$links4 <- renderPlot({req(rv$data);plot_links(rv$data, plot = "splitbar", names = input$Sender_input_links, starttime = input$startdate4, endtime = input$enddate4, min.occur = input$LinkMinimum)}, res = 100)

  })

  observeEvent(c(input$submit,input$SmilieUpdate),{

    output$smilies1 <- renderPlot({req(rv$data);plot_smilies(rv$data, plot = "cumsum", names = input$Sender_input_smilies, starttime = input$startdate5, endtime = input$enddate5, min.occur = input$SmilieMinimum)}, res = 100)
    output$smilies2 <- renderPlot({req(rv$data);plot_smilies(rv$data, plot = "heatmap", names = input$Sender_input_smilies, starttime = input$startdate5, endtime = input$enddate5, min.occur = input$SmilieMinimum)}, res = 100)
    output$smilies3 <- renderPlot({req(rv$data);plot_smilies(rv$data, plot = "bar", names = input$Sender_input_smilies, starttime = input$startdate5, endtime = input$enddate5, min.occur = input$SmilieMinimum)}, res = 100) # We might need a SmilieVec here
    output$smilies4 <- renderPlot({req(rv$data);plot_smilies(rv$data, plot = "splitbar", names = input$Sender_input_smilies, starttime = input$startdate5, endtime = input$enddate5, min.occur = input$SmilieMinimum)}, res = 100)

  })

  observeEvent(c(input$submit,input$EmojiUpdate), {

    output$emoji1 <- renderPlot({req(rv$data);plot_emoji(rv$data, plot = "cumsum", names = input$Sender_input_emoji, starttime = input$startdate6, endtime = input$enddate6, min.occur = input$EmojiMinimum)}, res = 100)
    output$emoji2 <- renderPlot({req(rv$data);plot_emoji(rv$data, plot = "heatmap", names = input$Sender_input_emoji, starttime = input$startdate6, endtime = input$enddate6, min.occur = input$EmojiMinimum)}, res = 100)
    output$emoji3 <- renderPlot({req(rv$data);plot_emoji(rv$data, plot = "bar", names = input$Sender_input_emoji, starttime = input$startdate6, endtime = input$enddate6, min.occur = input$EmojiMinimum)}, res = 100, height = 800) # We need a min.occur value here
    output$emoji4 <- renderPlot({req(rv$data);plot_emoji(rv$data, plot = "splitbar", names = input$Sender_input_emoji, starttime = input$startdate6, endtime = input$enddate6, min.occur = input$EmojiMinimum)}, res = 100, height = 800)  # We need a min.occur value here


  })

  observeEvent(c(input$submit,input$LocUpdate), {

    output$location1 <- renderPlot({req(rv$data);plot_location(rv$data, add.jitter = FALSE ,mapzoom = 12, names = input$Sender_input_location, starttime = input$startdate7, endtime = input$enddate7)}, res = 100, height = 1000) # We need buttons for all of these settings

  })

  observeEvent(c(input$submit,input$ReplyUpdate),{

    output$replytime1 <- renderPlot({req(rv$data);plot_replytimes(rv$data, type = "replytime", names = input$Sender_input_replies, starttime = input$startdate8, endtime = input$enddate8)}, res = 100)
    output$replytime2 <- renderPlot({req(rv$data);plot_replytimes(rv$data, type = "reactiontime", names = input$Sender_input_replies, starttime = input$startdate8, endtime = input$enddate8)}, res = 100)

  })

  observeEvent(c(input$submit,input$MediaUpdate),{

    output$media1 <- renderPlot({req(rv$data);plot_media(rv$data, plot = "cumsum", names = input$Sender_input_media, starttime = input$startdate9, endtime = input$enddate9)}, res = 100)
    output$media2 <- renderPlot({req(rv$data);plot_media(rv$data, plot = "heatmap", names = input$Sender_input_media, starttime = input$startdate9, endtime = input$enddate9)}, res = 100)
    output$media3 <- renderPlot({req(rv$data);plot_media(rv$data, plot = "bar", names = input$Sender_input_media, starttime = input$startdate9, endtime = input$enddate9)}, res = 100)
    output$media4 <- renderPlot({req(rv$data);plot_media(rv$data, plot = "splitbar", names = input$Sender_input_media, starttime = input$startdate9, endtime = input$enddate9)}, res = 100)


  })

  output$network1 <- renderPlot({req(rv$data);animate_network(rv$data)}, res = 100) # this will not work out of the box


  ####################### TRYING OUT STUFF
  output$unique_senders <- renderPrint({req(rv$data);unique(as.character(rv$data$Sender))})

  # displaying output for selected rows
  output$rows <- renderText(input$frame_rows_selected)

}

# Run the application
shinyApp(ui = ui, server = server)
