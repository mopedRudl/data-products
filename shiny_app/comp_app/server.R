#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(ggplot2)
library(dplyr)
library(bbr)
library(htmltab)
library(stringr)
library(shiny)

#setwd("/Users/mebner/Documents/for_me/R_coursera/GitHub/data-products/shiny_app/player_comparions_per_career_year/")
##setwd("/Users/mickey/Documents/GitHub/data-products/shiny_app/player_comparions_per_career_year")

df_players = data.frame()
for (i in  letters){
  
  # vector output
  players <- try(get_players(i))
  df_players <- rbind(df_players,players)
}

players <- df_players #%>% mutate(from = as.numeric(from), to = as.numeric(to)) %>% mutate(years_active = to - from) %>% filter(!is.na(from) & from >= 1980 & years_active >= 5)



#############
###server####
#############

id <- c("Dummy")
input <- as.data.frame(id)
input$player1 <- "Michael Jordan"
input$player2 <- "Kobe Bryant"

shinyServer(function(input, output) {
  output$plot <- reactive({
    input$goButton
    withProgress(message = "Loading Data",value = 0,{ 

    selection1 <- players %>% subset(player == input$player1) %>% select(slug)
    name1 <- players %>% subset(slug == as.character(selection1)) %>% select(player)
    initial1 <- paste0(substr(as.character(selection1), 1, 1),"/")
    df1 <- htmltab(doc = paste0("https://www.basketball-reference.com/players/",initial1,as.character(selection1),".html"), which = 1, header = 1,rm_nodata_cols = F)
    df1 <- df1 %>% mutate(player = as.character(name1), year = as.numeric(substr(Season,1,4))) %>%
      arrange(year) %>% mutate(career_year = row_number(player))
    

    selection2 <- players %>% subset(player == input$player2) %>% select(slug)
    name2 <- players %>% subset(slug == as.character(selection2)) %>% select(player)
    initial2 <- paste0(substr(as.character(selection2), 1, 1),"/")
    df2 <- htmltab(doc = paste0("https://www.basketball-reference.com/players/",initial2,as.character(selection2),".html"), which = 1, header = 1,rm_nodata_cols = F)
    df2 <- df2 %>% mutate(player = as.character(name2), year = as.numeric(substr(Season,1,4))) %>%
      arrange(year) %>% mutate(career_year = row_number(player))
    
    df <- bind_rows(df1,df2) %>% mutate(Age = as.numeric(Age),
                                        G = as.numeric(G),
                                        GS = as.numeric(GS),
                                        MP = as.numeric(MP),
                                        FG = as.numeric(FG),
                                        FGA = as.numeric(FGA),
                                        `FG%` = as.numeric(`FG%`),
                                        `3P` = as.numeric(`3P`),
                                        `3PA` = as.numeric(`3PA`),
                                        `3P%` = as.numeric(`3P%`),
                                        `2P` = as.numeric(`2P`),
                                        `2PA` = as.numeric(`2PA`),
                                        `2P%` = as.numeric(`2P%`),
                                        `eFG%` = as.numeric(`eFG%`),
                                        FT = as.numeric(FT),
                                        FTA = as.numeric(FTA),
                                        `FT%` = as.numeric(`FT%`),
                                        ORB = as.numeric(ORB),
                                        DRB = as.numeric(DRB),
                                        TRB = as.numeric(TRB),
                                        AST = as.numeric(AST),
                                        STL = as.numeric(STL),
                                        BLK = as.numeric(BLK),
                                        TOV = as.numeric(TOV),
                                        PF = as.numeric(PF),
                                        PTS = as.numeric(PTS),
                                        BLK = as.numeric(BLK),
                                        TOV = as.numeric(TOV),
                                        PF = as.numeric(PF),
                                        PTS = as.numeric(PTS))
    })
    withProgress(message = "Making Plot",value = 0,{
    plot <- renderPlot({
      ggplot(data=df, aes(x=Age, y = PTS,group = player)) +
        geom_line(aes(color=player),size = 2)+
        geom_point(aes(color=player))+
        theme_light(base_size = 11, base_family = "")+
        scale_color_manual(values=c("darkorange","dodgerblue"))+
        #scale_linetype_manual(values=c("solid", "solid"))+
        scale_x_continuous(breaks = seq(0,100,by=1))+
        labs(y = "Points per Game",
             x = "Career Year")
    })
    })
    return(plot)
  })

}
)




