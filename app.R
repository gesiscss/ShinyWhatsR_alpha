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

######## trying out the shiny manager
# define some credentials
credentials <- data.frame(
  user = c("JuKo"), # mandatory
  password = c("admin"), # mandatory
  start = c("2019-04-15"), # optional (all others)
  expire = c(NA),
  admin = c(TRUE),
  comment = "Analyse your own WhatsApp Chatlogs!",
  stringsAsFactors = FALSE
)

# you can use keyring package to set database key
# library(keyring)
# key_set("R-shinymanager-key", "obiwankenobi")

# Init the database
# create_db(
#   credentials_data = credentials,
#   sqlite_path = "../database.sqlite", # will be created
#   passphrase = key_get("R-shinymanager-key", "obiwankenobi")
#   # passphrase = "passphrase_wihtout_keyring"
# )


# installing packages (This might need to be done manually on a server with root access)
if (!"devtools" %in% installed.packages()) {

  install.packages("devtools")
}

if (!"encryptr" %in% installed.packages()) {

  install.packages("encryptr")
}

if (!"shiny" %in% installed.packages()) {

  install.packages("shiny")
}

if (!"shinymanager" %in% installed.packages()) {

  install.packages("shinymanager")
}

if (!"shinythemes" %in% installed.packages()) {

  remotes::install_github("datastorm-open/shinymanager")
}

if (!"shinyWidgets" %in% installed.packages()) {

  install.packages("shinyWidgets")
}

if (!"shinyjs" %in% installed.packages()) {

  install.packages("shinyjs")
}

if (!"shinyalert" %in% installed.packages()) {

  install.packages("shinyalert")
}

if (!"shinyTime" %in% installed.packages()) {

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

if (!"ggwordcloud" %in% installed.packages()) {

  install.packages("ggwordcloud")
}

if (!"WhatsR" %in% installed.packages()) {

  devtools::install_github("gesiscss/WhatsR")
}

if (!"digest" %in% installed.packages()) {

  install.packages("digest")
}

if (!"slickR" %in% installed.packages()) {

  install.packages("slickR")
}

if (!"keyring" %in% installed.packages()) {

  install.packages("keyring")
}


# shiny backend
library(encryptr)
library(digest)
library(shiny)
library(shinymanager)
library(shinythemes)
library(shinyjs)
library(shinyalert)
library(shinyTime)
library(DT)
library(ggplot2)
library(ggwordcloud)
library(rsconnect)
library(shinyWidgets)
library(slickR)
library(keyring)
library(WhatsR)


# Define UI for application that draws a histogram
ui <- fluidPage(theme  = shinytheme("flatly"),

                ### Setting up shiny JS and shinyAlert
                useShinyjs(),
                useShinyalert(),

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

                navbarPage(tags$img(height = 35, width = 35, src = "WhatsR_logo.png"), id = "WhatsR",

                           tabPanel("Overview",

                                    column(tags$p(style = "text-align: justify;",HTML("<h1 align='center'> Analyze your own WhatsApp Chatlogs! </h1>"),
                                                    "Dear study participant, on this website you have the opportunity to securely analyze,
                                                  your own WhatsApp chatlogs and to learn something about your chatting behavior and your digital
                                                  social relationships in exchange for providing some meta-information about your chat. In the following steps,
                                                  we will guide you through the process of how to export and securely upload you WhatsApp chatlogs to this website.
                                                  You will then have the opportunity to interactively explore your messages and to see what kind of information can
                                                  be extracted from a chatlog. This information will only be visible to you and will be deleted as soon as you close
                                                  this website. You can then interactively decide which parts (if any) of the displayed information you would feel
                                                  comfortable to donate to our research project. Importantly, it is not possible to donate any personal identifiable information
                                                  such as names, the content of messages, telephone numbers or sent media files. It's only possible to donate meta-information
                                                  such as when a message was sent, how many words it contained or if it contained emoji, smilies or links. Should you decide to donate
                                                  any meta-information about your chat, you will receive access to an interactive analysis environment to analyze your own data,
                                                  see who is sending the most words, who is using which emojis and smilies, which words are used most frequently in the chat
                                                  or who takes how long to respond to messages on average. Again, this information is only for you and we will only save the meta-information
                                                  that you explicitly reviewed and shared with us."),

                                           width = 6, offset = 3),

                                    tags$br(),
                                    tags$br(),

                                    column(slickROutput("slickr", width = "700px", height = "100%"),

                                           width = 6, offset = 3),

                                    column(tags$p(style = "text-align: justify;",HTML("<h1 align='center'> How is my data secured? </h1>"),
                                                  "All traffic on this website is secured with the SSL protocol and no information is persistently stored
                                                  until you manually review it and explicitly donate it to us. You will see your messages after uploading them to
                                                  the website but only you will be able to see them and only for the duration of your visit on this website. After you close
                                                  the browser tab, all information that you did not explicitly donate to us will be deleted. Importantly, you will only be able
                                                  to donate anonymous metadata. That means even if you wanted, it is not physically possible to donate personal data such as
                                                  message content, names, telephone numbers, sent files,images or videos. All data will be collected and processed according
                                                  to the European General Data Protection Guidelines on a secured Server at the University of Ulm, Germany. All donated meta-data is encrypted with RSA.
                                                  This study was reviewed and approved by the Ethics Committee of the University of Ulm, Germany."),

                                           width = 6, offset = 3),

                                    column(tags$p(style = "text-align: justify;",HTML("<h1 align='center'> What is the donated Metadata used for? </h1>"),
                                                  "The donated Metadata is used for research purposes only. That means that we will analyze your chatlog metadata
                                                  in combination with your survey responses and average the results over all participants. We will publish the aggregated results
                                                  in peer-reviewed scientific journals and present them on scientifc conferences to other scientists. The main goal of this research
                                                  project is to learn if specific types of relationships can be distinguished by patterns in how people communicate with each other.
                                                  The anonmized metadata will be uploaded to the open science framework (www.osf.org) so that other researchers can validate our results."),

                                           width = 6, offset = 3),

                                    headerPanel(""),

                                  fluidRow(
                                    column(12, align = "center", actionButton("IntroCheck", label = "Understood, take me to the upload page", class = "btn-warning"))
                                  )

                           ),

                           # tabPanel("Example",
                           #
                           #          column(
                           #
                           #            tags$p(HTML("<h1 align='center'> Example </h1>"),
                           #                   HTML("<br>"),
                           #                   paste(
                           #                     "In this panel, we will show you an example of how to export your WhatsApp chatlog data, how to upload it and what kind of insights can be generated from them. All you need to do this is your phone and an email address that only you have access to. We have summed up the instructions for your convenience but you can find
                           #                   the official instructions"), a("here", href="https://faq.whatsapp.com/android/chats/how-to-save-your-chat-history/?lang=en"),"."),
                           #
                           #            tags$p(HTML("<h2 align='center'> Exporting WhatsApp chatlogs </h2>"),
                           #
                           #                   tags$br(),
                           #
                           #                   tags$div(tags$ul(
                           #                     tags$li(tags$span(tags$b("Step 1:"),"Open WhatsApp on your phone and go to the conversation with the social contact you chose in part 1 of the study.")),
                           #                     tags$br(),
                           #                     tags$li(tags$span(tags$b("Step 2:"),"In the top right corner of your screen, click on the symbol with the",tags$b("three dots (...)"))),
                           #                     tags$br(),
                           #                     tags$li(tags$span(tags$b("Step 3:"),"In the dropdown menu that opens, click on",tags$b("'More'"))),
                           #                     tags$br(),
                           #                     tags$li(tags$span(tags$b("Step 4:"),"Click on", tags$b("'Export Chat'") ,"and select", tags$b("'Without Media Files'"))),
                           #                     tags$br(),
                           #                     tags$li(tags$span(tags$b("Step 5:"),"Enter you email address. Please pick an email address that only you have access to and double check for correct spelling")),
                           #                     tags$br(),
                           #                     tags$li(tags$span(tags$b("Step 6:")," Access your Email client. You will have received an email from WhatsApp with your chatlog as an attachment.
                           #                                       The file type is", tags$b(".txt"),"If you not only receive a .txt file but also media files, please go through the steps again and ensure that you
                           #                                       select the export option",tags$b("'Without Media Files'"),". Download the exported chat to your computer."))
                           #
                           #                     ))
                           #
                           #
                           #                   ),
                           #
                           #            tags$p(HTML("<h2 align='center'> Uploading your exported WhatsApp Chatlog </h2>")),
                           #            tags$p("If you did everything correctly, you should now have a .txt file of your chatlog. Depending on which text editor you are using, if you are on a Mac or PC or if the chat was exported from an
                           #                   android phone or iphone it might look slightly different. For example, the date format might look different or the emoji
                           #                   might be rendered incorrectly. This is okay and shouldn't bother you. In the next tab you can see some examples of the results that can be generated from
                           #                   the chatlog."),
                           #
                           #            tags$br(),
                           #            tags$br(),
                           #
                           #            fluidRow(
                           #              column(12, align = "center", actionButton("UploadCheck", label = "Take me to the upload page", class = "btn-warning"))
                           #            ),
                           #
                           #            # tags$img(height = 629,
                           #            #          width = 1064,
                           #            #          src = "ExampleData.jpg",
                           #            #          hover = "Example Data for an exported WhatsApp Chatlog"),
                           #
                           #            width = 6, offset = 3)
                           #
                           # ),

                           tabPanel("Upload Data",

                                    sidebarLayout(
                                      sidebarPanel( h3("Upload Settings", align = "center"),

                                        h3("Operating System"),
                                        helpText("Please indicate whether you exported the chat from an iphone or from an android phone.
                                                 This information is necessary because chatlogfiles are structured differently on Android and iOS."),
                                        radioButtons("os", "",
                                                     c("Android" = "android", "Iphone" = "ios")
                                        ),

                                        h3("Chat Language"),
                                        helpText("Please indicate the language setting of the phone the chat was extracted from. This information is necessary
                                                 because the dates and times are formatted differently depending on the language setting, which is important for processing
                                                 the chatlog correctly."),
                                        radioButtons("language", "",
                                                     c("English" = "english", "German" = "german")
                                        ),
                                        # radioButtons("media", "Did you include media files in your export?",
                                        #              c("Yes" = TRUE, "No" = FALSE)
                                        # ),
                                        # radioButtons("Anon", "Do you want to anonimze the names of chat participants?",
                                        #              c("Yes" = TRUE, "No" = FALSE, "Add anonimized column" = "both")
                                        # ),
                                        # radioButtons("URL", "Do you want to shorten send links to domain names?",
                                        #              c("Yes" = "domain", "No" = FALSE)
                                        # ),

                                        h3("Uploading Chatlog File"),
                                        helpText("You can select your exported WhatsApp chatlog by clicking on the 'Choose File' button below. Once you chose a file, a button for processing the file will appear. By clicking on the 'Process File' button, you are not donating any data yet. You will
                                                 have the opportunity to review and select your data in the next step before you donate any metadata
                                                 and can always close the website to delete everything that you didn't explicitly donate."),

                                        fileInput(inputId = "file",
                                                  label = "",
                                                  accept = "text/plain",
                                                  buttonLabel = "Choose File"),

                                        actionButton(inputId = "submit", label = "Process File", class = "btn-warning")
                                      ),

                                      mainPanel(

                                        column(

                                          tags$p(HTML("<h2 align='center'> Exporting WhatsApp chatlogs </h2>"),

                                                 tags$br(),

                                                 tags$div(tags$ul(
                                                   tags$li(tags$span(tags$b("Step 1:"),"Open WhatsApp on your phone and go to the conversation with the social contact you chose in part 1 of the study.")),
                                                   tags$br(),
                                                   tags$li(tags$span(tags$b("Step 2:"),"In the top right corner of your screen, click on the symbol with the",tags$b("three dots (...)"))),
                                                   tags$br(),
                                                   tags$li(tags$span(tags$b("Step 3:"),"In the dropdown menu that opens, click on",tags$b("'More'"))),
                                                   tags$br(),
                                                   tags$li(tags$span(tags$b("Step 4:"),"Click on", tags$b("'Export Chat'") ,"and select", tags$b("'Without Media Files'"))),
                                                   tags$br(),
                                                   tags$li(tags$span(tags$b("Step 5:"),"Enter you email address. Please pick an email address that only you have access to and double check for correct spelling")),
                                                   tags$br(),
                                                   tags$li(tags$span(tags$b("Step 6:")," Access your Email client. You will have received an email from WhatsApp with your chatlog as an attachment.
                                                                 The file type is", tags$b(".txt"),"If you not only receive a .txt file but also media files, please go through the steps again and ensure that you
                                                                 select the export option",tags$b("'Without Media Files'"),". Download the exported chat to your computer."))

                                                 ),HTML("<h2 align='center'> Uploading WhatsApp chatlogs </h2>"),

                                                 tags$ul(

                                                   tags$li(tags$span(tags$b("Step 7:"),"Using the panel on the left side, select the correct settings and select the correct chatlog to upload and click on",tags$b("Process file")))

                                                 )

                                                 )


                                          ),

                                               width = 10, offset = 1)
                                      ),
                                    )
                           ),

                           tabPanel("Explore Data",

                                    sidebarPanel(

                                      h2("Select Data", align = "center"),
                                      tags$p("In this tab, you can see the data that you uploaded in tabular format and what kind of information
                                             can be extracted from your chat. This information is only visible to you and will not be saved unless
                                             you click the 'Donate Selection' button at the bottom of this page. If you click this button, only the displayed
                                             selection will be send to us. You can thus individually decide which parts of the data you feel comfortable sharing.
                                             Importantly, the columns 'Message','Flat','TokVec', and 'Location' are only visible to you and cannot be donated. They will be excluded automatically
                                             from the donation process if you don't to it manually to preserve your anonymity."),
                                      h3("Exclude Columns"),
                                      helpText("You can simply exclude whole columns from the selection in the table on the right by clicking on the menu below
                                               and selecting or deselcting the respective column names."),
                                      pickerInput("show_vars", "Select Columns to display:",
                                                  choices = c(""),
                                                  selected = c(""),
                                                  label = "Click to select columns",
                                                  multiple = TRUE),

                                      h3("Exclude Rows"),
                                      helpText("You can simply click on rows of data in the table to your right if you want to exclude them from the selction. To exclude them, first highlight
                                                all rows you want to exclude by clicking on them and then press the 'Exclude selected row(s)' button below. You can restore all previously excluded rows by clicking on the 'Restore all excluded rows' button."),
                                      actionButton("excludeRows", "Exclude selected row(s)"),
                                      actionButton("RestoreRows", "Restore all excluded rows"),

                                      h3("Donate Data"),
                                      helpText("You can donate the selection of data in the table to your right by clicking the button below.
                                               If you feel comfortable with it and decide to donate your data, you will be automatically forwarded
                                               to the results page for your chat."),

                                      actionButton(inputId = "donation", label = "Donate Selection and go to Analysis page", class = "btn-warning")
),

                                    mainPanel(

                                      h1("Your Selection for Data Donation", align = "center"),

                                      DTOutput("frame"),

                                      fluidRow(
                                        column(1, align = "topright", downloadButton("downloadSelection", "Download selected Data")),
                                        column(1, align = "topleft", downloadButton("downloadData", "Download All Data"), offset = 9),
                                      ),

                                              )

                                    ),

                           tabPanel("Results",

                                    tabsetPanel(type = "tabs",

                                                tabPanel("Messages",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders and the timeframe that should be included in the analysis."),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_msg", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate1","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate1","", value = "2038-01-19 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      # actionButton("MsgUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           h1("Amount of Messages", align = "center"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("message1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("message2"),
                                                           tags$br(),
                                                           tags$br(),
                                                           h1("Messages over Time", align = "center"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("tokensbwah1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("tokensbwah2"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("tokensovertime1"),
                                                           # tags$br(),
                                                           # tags$br(),
                                                           # plotOutput("tokensovertime2"),
                                                           # tags$br(),
                                                           # tags$br(),
                                                           # plotOutput("tokensovertime3"),
                                                           # tags$br(),
                                                           # tags$br(),
                                                           # plotOutput("tokensovertime4")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Wordcloud",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right side, you can see wordclouds shwocasing which words are used most in the chat
                                                                      and by which person. In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders and the timeframe that should be included in the analysis, the minimum
                                                                             number of times a word needs to occur to be included and the fontsizes in the plot."),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_wc", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Select Word Minimum"),
                                                                      helpText("You can drag and drop the slider below to adjust the minimum number of times words need to occur in the conversation to be included in the plots on the right. If your plots look messy, try to reduce this number."),
                                                                      sliderInput("WCMinimum","", min = 1, max = 100, value = 5),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate2","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate2","", value = "2038-01-19 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      h3("Overall Wordcloud Fontsize"),
                                                                      helpText("You can drag and drop the slider below to adjust the fontsize for the upper plot"),
                                                                      sliderInput("WCFontsize","", min = 1, max = 100, value = 5),

                                                                      h3("Wordcloud by Sender Fontsize"),
                                                                      helpText("You can drag and drop the slider below to adjust the fontsize for the lower plot"),
                                                                      sliderInput("WCFontsize2","", min = 1, max = 100, value = 5),


                                                         ),

                                                         mainPanel(

                                                           plotOutput("wordcloud1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("wordcloud2")

                                                         ),

                                                         width = 6, offset = 5),


                                                tabPanel("Lexical Dispersion",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right side, you can see at which points in the conversation specific keywords are used. In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can chose a keyword to search the conversation for and the timeframe for the plots."),

                                                                      h3("Select a Keyword"),
                                                                      helpText("You can enter a keyword here to display all occurances of the word in your uploaded chatlog file."),
                                                                      textInput("LeDiPlo_text","", value = "test", width = NULL, placeholder = NULL),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_lediplo", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate3","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp until which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate3","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("LeDiPloUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("lexicaldispersion1")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Links",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right side, you can see how often which links are shared by whom and when. In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders, the minimum occurance of a link and the timeframe that should be included in the analysis."),


                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_links", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Select Link Minimum"),
                                                                      helpText("You can drag and drop the slider below to adjust the minimum number of times a domain needs to occur in the conversation to be included in the plots on the right. If your plots look messy, try to reduce this number."),
                                                                      sliderInput("LinkMinimum","", min = 1, max = 100, value = 5),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate4","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate4","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("LinksUpdate","Update Plots", class = "btn-warning")

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

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right, you can see how often which smilies are used by whom and when. In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders and the timeframe that should be included in the analysis."),


                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_smilies", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Select Smiley Minimum"),
                                                                      helpText("You can drag and drop the slider below to adjust the minimum number of times a smiley needs to occur in the conversation to be included in the plots on the right. If your plots look messy, try to reduce this number."),
                                                                      sliderInput("SmilieMinimum","", min = 1, max = 100, value = 5),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate5","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate5","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("SmilieUpdate","Update Plots", class = "btn-warning")

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

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right, you can see how often which emoji are used by whom and when.In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders, minimum number of emoji and the timeframe that should be included in the analysis."),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_emoji", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Select Emoji Minimum"),
                                                                      helpText("You can drag and drop the slider below to adjust the minimum number of times an emoji needs to occur in the conversation to be included in the plots on the right. If your plots look messy, try to reduce this number."),
                                                                      sliderInput("EmojiMinimum","", min = 1, max = 100, value = 5),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate6","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate6","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("EmojiUpdate","Update Plots", class = "btn-warning")

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


                                                tabPanel("Media",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right, you can see how often which media file types are shared by whom and when. In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders and the timeframe that should be included in the analysis."),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_media", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate9","", value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate9","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("MediaUpdate","Update Plots", class = "btn-warning")

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

                                                         width = 6, offset = 5),

                                                tabPanel("Replies",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right, you can see how long it takes people in the chat to reply and to be replied to. In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders and the timeframe that should be included in the analysis."),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_replies", "", "Upload chatfile to see List of Senders"),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate8","",value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate8","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("ReplyUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("replytime1"),
                                                           tags$br(),
                                                           tags$br(),
                                                           plotOutput("replytime2")

                                                         ),

                                                         width = 6, offset = 5),

                                                tabPanel("Locations",

                                                         sidebarPanel(h3("Visualization Settings", align = "center"),
                                                                      tags$p("On the right, you can see the locations that a re shared by people in the chat on a map.In this panel, you can tweak the settings for the plots on the right side.
                                                                             You can control the senders and the timeframe that should be included in the analysis."),

                                                                      h3("Selecting Senders"),
                                                                      helpText("You can select/deselect the senders for which to display the results by clicking on them below. Results will then be recomputed"),
                                                                      checkboxGroupButtons("Sender_input_location","", "Upload chatfile to see List of Senders"),

                                                                      h3("Selecting Start Time"),
                                                                      helpText("You can choose the timestamp from which to include messages in the results by entering it below. Enter the date and time from which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("startdate7","",value = "1970-01-01 00:00:00", placeholder = "2018-01-29 10:24:00"),

                                                                      h3("Selecting End Time"),
                                                                      helpText("You can choose the timestamp up tp which to include messages in the results by entering it below. Enter the date and time until which you want to include data into the plot in this format: yyyy-mm-dd hh:mm:ss"),
                                                                      textInput("enddate7","", value = "2038-19-01 03:14:07", placeholder = "2020-11-01 09:30:00"),

                                                                      #actionButton("LocUpdate","Update Plots", class = "btn-warning")

                                                         ),

                                                         mainPanel(

                                                           plotOutput("location1")

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

                                    )

))

# Wrap your UI with secure_app
ui <- secure_app(ui)

# Define server logic
server <- function(input, output, session) {

  ###### Shiny manager

  # call the server part
  # check_credentials returns a function to authenticate users
  res_auth <- secure_server(
    check_credentials = check_credentials(credentials)#"../database.sqlite",
                                          #passphrase = key_get("R-shinymanager-key", "obiwankenobi"))
  )

  output$auth_output <- renderPrint({
    reactiveValuesToList(res_auth)
  })




  # hiding tabs that should only be shown conditionally
  hideTab("WhatsR","Example",session = session)
  hideTab("WhatsR","Explore Data",session = session)
  hideTab("WhatsR","Results",session = session)
  hideTab("WhatsR","Upload Data",session = session)

  # unhide tabs one by one

  observeEvent(input$IntroCheck, {

    showTab("WhatsR","Upload Data",session = session)
    updateNavbarPage(session, "WhatsR","Upload Data")

  })

  # observeEvent(input$UploadCheck, {
  #
  #   showTab("WhatsR","Upload Data",session = session)
  #   updateNavbarPage(session, "WhatsR","Upload Data")
  #
  # })

  observeEvent(input$submit, {

    showTab("WhatsR","Explore Data",session = session)
    updateNavbarPage(session, "WhatsR","Explore Data")

  })

  # DATA DONATION STEP
  observeEvent(input$donation, {

    # popup
    shinyalert("Consent", "Do you want to donate the data selection?",
               type = "success",
               showConfirmButton = TRUE,
               showCancelButton = TRUE,
               confirmButtonText = "Donate data and show results",
               cancelButtonText = "Take my back to the selection window",
               size = "m",
               closeOnEsc = FALSE,
               closeOnClickOutside = FALSE)

  })

  # only do this on confirmation
  observeEvent(input$shinyalert, {

    # only execute if users confirm
    if (req(input$shinyalert) == TRUE) {

      # making a copy for data donation with only the selected columns (Rows are already updated at this point)
      rv$copy2 <- rv$copy[,c(input$show_vars)]

      # removing non-donateable columns (This doesn't work correctly yet)
      if(sum(colnames(rv$copy2) %in% c("Message","Flat","TokVec","Location")) > 0) {

        # removing columns and saving to another object
        rv$copy2 <- rv$copy2[,!(colnames(rv$copy2) %in% c("Message","Flat","TokVec","Location"))]

        #popup
        shinyalert("Autoremoved Columns",
                   type = "error",
                   "The columns 'Message','Flat','TokVec' and 'Location' cannot be donated.They have been automatically removed from your selection to preserve your privacy.",
                   showConfirmButton = TRUE,
                   confirmButtonText = "OK",
                   closeOnEsc = FALSE,
                   closeOnClickOutside = FALSE,
                   inputId = "autoremoveAlert")

      } else {

        # making a copy for data donation with only the selected columns (Rows are already updated at this point)
        rv$copy2 <- rv$copy[,c(input$show_vars)]

        }

      # saving (naming convention needs to be changed)
      LocalFilename <- sprintf("%s_%s.rds", as.integer(Sys.time()), digest(rv$copy2))
      saveRDS(rv$copy2, file = paste("./UserData/",LocalFilename, sep = ""))

      # encrypting file with public key
      encrypt_file(paste("./UserData/",LocalFilename, sep = ""))

      # removing the unencrypted file
      file.remove(paste("./UserData/",LocalFilename, sep = ""))

      # removing object
      rv$copy2 <- NULL

      # routing to results tab
      showTab("WhatsR","Results",session = session)
      updateNavbarPage(session, "WhatsR","Results")

    }

  })

  # creating reactive value
  rv <- reactiveValues(data = NULL)

  # hiding the download buttons if no file has been uploaded
  observe({
    shinyjs::hide("submit")

    if (!is.null(input$file))
      shinyjs::show("submit")
  })

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
                          anon = TRUE,
                          media = FALSE,
                          web = "domain",
                          order = "both",
                          language = input$language,
                          os = input$os,
                          rpnl = " start_newline ",
                          rpom = " media_omitted ")

    # making an internal copy for column and row selection
    rv$copy <- rv$data

  })

  # row exclusion
  observeEvent(input$excludeRows,{

    # require inputs
    req(rv$copy,input$show_vars,input$frame_rows_selected)

    # subset copy
    rv$copy <- rv$copy[-c(input$frame_rows_selected),]

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

    datatable(rv$copy[,c(input$show_vars)], options = list(pageLength = 20))

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

  # Allow for download of example data
  output$ExampleDownload <- downloadHandler(
    filename = function() {paste("ExtendedExampleChat","txt", sep = ".")},
    content = function(file) {file.copy("data/ExtendedExampleChat.txt", file)}
  )



  ####################### UPDATING INPUT SELECTION OPTIONS

  observeEvent(input$submit, {

    ### Updating selection of columns
    updatePickerInput(session,
                             "show_vars",
                             choices = colnames(rv$data),
                             selected = colnames(rv$data)[c(1:2,6:7,9:11,13:14)])

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
    output$tokensovertime1 <- renderPlot({req(rv$data);plot_tokens_over_time(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1)}, res = 100)
    #output$tokensovertime2 <- renderPlot({req(rv$data);plot_tokens_over_time(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1, plot = "year")}, res = 100)
    #output$tokensovertime3 <- renderPlot({req(rv$data);plot_tokens_over_time(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1, plot = "weekday")}, res = 100)
    #output$tokensovertime4 <- renderPlot({req(rv$data);plot_tokens_over_time(rv$data, names = input$Sender_input_msg, starttime = input$startdate1, endtime = input$enddate1, plot = "hours")}, res = 100)

    })

  observeEvent(c(input$submit,input$WCUpdate),{

    output$wordcloud1 <- renderPlot({req(rv$data);plot_wordcloud(rv$data, names = input$Sender_input_wc, starttime = input$startdate2, endtime = input$enddate2, min.freq = input$WCMinimum, font.size = input$WCFontsize)}, res = 100)
    output$wordcloud2 <- renderPlot({req(rv$data);plot_wordcloud(rv$data, comparison = TRUE, names = input$Sender_input_wc, starttime = input$startdate2, endtime = input$enddate2, min.freq = input$WCMinimum, font.size = input$WCFontsize2)}, res = 100)

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

  ####################### EXAMPLE SLIDESHOW
  output$slickr <- renderSlickR({
    imgs <- list.files("./www/Slideshow", pattern=".png", full.names = TRUE)
    slickR(imgs)
  })

}

# Run the application
shinyApp(ui = ui, server = server)
