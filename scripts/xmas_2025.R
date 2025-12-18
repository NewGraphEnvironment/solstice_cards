# this is how we set up the key to access our account
# blastula::create_smtp_creds_key(
#   id = "gmail",
#   user = "al@newgraphenvironment.com",
#   provider = "gmail",
#   overwrite = TRUE
# )

# grab the raw image built with our prompt
img <- magick::image_read("fig/peace_2025.png")

# annotation for the image
quote_text <- paste(
  "“Well - well, everyone knows how to dance.",
  "There’s only so much time.”",
  "- Mac Miller",
  sep = "\n"
)

img_with_quote <- img |>
  magick::image_annotate(
    text = quote_text,
    gravity = "south",
    location = "+0+10",
    size = 40,
    font = "Georgia",
    style = "italic",
    color = "white",
    strokecolor = "black",
    strokewidth = 1
  )

# write the annotated image to file
magick::image_write(img_with_quote, path = "fig/peace_2025_quote.png")

# build the email body
email_body <- blastula::add_image(
  file = 'fig/peace_2025_quote.png',
  width = "75%"
  )

# include the logo
logo_footer <- blastula::add_image(
  file = "fig/nge-full_black.png",
  width = "25%"
)

email <- blastula::compose_email(
  header = blastula::md(glue::glue(
    "
<div style='text-align:center; line-height:1.4;'>

  <div style='font-size:18px; color:#222222; font-weight:600;'>
    Thank You For Everything
  </div>

  <div style='font-size:24px; color:#0b7d2b; font-weight:700; margin-top:6px;'>
    Happy Solstice and Merry Christmas!
  </div>

  <div style='font-size:14px; color:#b22222; margin-top:4px;'>
    We appreciate your spirit of collaboration
  </div>

</div>
"
  )
  ),

  body = blastula::md(c(

    email_body
  )),
footer = blastula::md(glue::glue(
  "
See how this card was made:
[Script](https://github.com/NewGraphEnvironment/solstice_cards/blob/main/scripts/xmas_2025.R) -
[Prompt](https://github.com/NewGraphEnvironment/solstice_cards/blob/main/scripts/prompt_2025.txt)

<br>

{logo_footer}
"
))
)

# send just one email
email |>
  blastula::smtp_send(
    from = "info@newgraphenvironment.com",
    to = "al@newgraphenvironment.com",
    subject = "Happy Holidays from New Graph Environment!",
    credentials = blastula::creds_key(id = "gmail")
  )

# or make a list of people to send it to.  Moved actual list to mybookdown-template/scripts

l <- c(
  'lucy@newgraphenvironment.com',
  'tara@newgraphenvironment.com',
  'mateo@newgraphenvironment.com',
  'al@newgraphenvironment.com',
  'info@newgraphenvironment.com')

# grab a list of all the contacts as the contacts_all object
source("~/Projects/current/Admin/contacts/contacts.R")


# make a function to send them all
email_send_batch <- function(recip){
  smtp_send(
    email = email,
    from = "info@newgraphenvironment.com",
    to = recip,
    subject = "Happy Holidays from New Graph Environment!",
    credentials = creds_key(id = "gmail")
  )
}

# and go ahead and mail it to the whole list
contacts_all |>
  purrr::map(email_send_batch)

