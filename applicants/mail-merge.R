library(googlesheets)
library(gmailr)
library(glue)
library(purrr)

sheet <- gs_key("1sAUqRxH1n5im8YtJiPY6IBSHDtPhF8EL9LmeH9K6Y14", visibility = "private")
applicants <- gs_read(sheet)

email <- applicants$`Email Address`
num <- applicants$`Permission number`
decision <- applicants$Decision


# Accept ------------------------------------------------------------------

accept_template <- paste(readLines("applicants/accept-email.md"), collapse = "\n")

accept_send <- function(email, num) {
  body <- glue(accept_template, num = num)

  message <- mime() %>%
    from("h.wickham@gmail.com") %>%
    to(email) %>%
    subject("Stats337") %>%
    text_body(body)

  message %>% create_draft()

  email
}

sent <- character()
to_send <- decision == "Accept" & !is.na(decision) & !(email %in% sent)
sent <- map2_chr(email[to_send], num[to_send], possibly(accept_send, NA_character_))


# Fail to accept ----------------------------------------------------------

pass_template <- paste(readLines("applicants/pass-email.md"), collapse = "\n")

pass_send <- function(email, num) {
  message <- mime() %>%
    from("h.wickham@gmail.com") %>%
    to(email) %>%
    subject("Stats337") %>%
    text_body(pass_template)

  message %>% create_draft()

  email
}

sent <- character()
to_send <- decision == "Pass" & !is.na(decision) & !(email %in% sent)
sent <- map(email[to_send], possibly(pass_send, NA_character_))
