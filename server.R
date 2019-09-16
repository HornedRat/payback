
library(googlesheets)
library(dplyr)
library(tidyr)
library(shiny)

httr::set_config(httr::config(http_version = 0))
gs_auth(token = "googlesheets_token.rds")

    
shinyServer(function(input, output) {
    
    output$text <- renderUI({
        HTML("<br/>Tutaj pojawi się rozliczenie")
    }) 
    
    observeEvent(input$goButton, {
        pointer <- gs_key(input$gs_id)
        data <- gs_read(pointer)
        
        spends <- data %>%
            group_by(Paid_by) %>%
            summarise(spend = sum(Amount)) %>%
            rename(user = Paid_by)
        
        #debts
        debts <- data %>%
            mutate(all = rowSums(.[4:ncol(data)], na.rm = T)) %>%
            gather(key = "user", value = "part", -Name, -Amount, -Paid_by, -all) %>%
            mutate(debt = (part / all) * Amount) %>%
            group_by(user) %>%
            summarise(debt = sum(debt, na.rm = T))
        
        #join
        balance <- spends %>%
            full_join(debts) %>%
            mutate_if(is.numeric,coalesce,0) %>%
            mutate(current_balance = spend - debt) %>%
            select(user, current_balance)
        
        
        balance_i <- balance
        text <- ""
        step <- 1
        
        #payback algorythm
        while (sum(balance_i$current_balance^2) >= 0.001) {
            #getting the most debted user
            balance_i <- balance_i %>%
                arrange(current_balance)
            paying <- balance_i[1,]
            
            #getting the user, that has most money to collect
            receiving <- balance_i[nrow(balance),]
            
            if (receiving$current_balance >= paying$current_balance) {
                amount_paid <- paying$current_balance
            } else {
                amount_paid <- receiving$current_balance
            }
            
            text <- paste(text, paste(step, "-",
                                      "Użytkownik", paying$user,
                                      "oddaje", abs(round(amount_paid,2)),
                                      "użytkownikowi", receiving$user),
                          sep = "<br/>")
            
            #correcting the current balance
            balance_i[1,2] <- balance_i[1,2] - amount_paid
            balance_i[nrow(balance),2] <- balance_i[nrow(balance),2] + amount_paid
            
            step <- step + 1
        }
        
        text <- paste(text, "Rozliczono!", sep = "<br/>")
        output$text <- renderUI({
            HTML(text)
        }) 
        
    })
        
})
