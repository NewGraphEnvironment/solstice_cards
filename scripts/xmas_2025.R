# this is how we set up the key to access our account
# blastula::create_smtp_creds_key(
#   id = "gmail",
#   user = "al@newgraphenvironment.com",
#   provider = "gmail",
#   overwrite = TRUE
# )

if(!fs::file_exists("fig/peace_2025_quote.png")){
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
}

# build the email body
email_body <- blastula::add_image(
  file = 'fig/peace_2025_quote.png',
  width = "75%",
  # read by screen readers if images don’t load
  alt = "Holiday card: Peace in space with nine moons"
)

# include the logo
logo_footer <- blastula::add_image(
  file = "fig/nge-full_black.png",
  width = "25%",
  alt = "New Graph Logo"
)

email <- blastula::compose_email(
  header = blastula::md(glue::glue(
    "
<div style='text-align:center; line-height:1.4;'>

  <div style='font-size:24px; font-weight:700; margin-top:6px; letter-spacing:0.3px;'>
    <span style='color:#0b7d2b;'>Happy Solstice</span>
    <span style='color:#333333;'> and </span>
    <span style='color:#b22222;'>Merry Christmas</span>
  </div>

  <div style='font-size:14px; color:#444444; margin-top:6px;'>
    We're grateful for your support and partnership - thank you for the trust and teamwork.
  </div>

</div>
"
  )),

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
  # 'lucy@newgraphenvironment.com',
  # 'tara@newgraphenvironment.com',
  # 'mateo@newgraphenvironment.com',
  'al@newgraphenvironment.com',
  'info@newgraphenvironment.com'
  )

# grab a list of all the contacts as the contacts_all object
source("~/Projects/current/Admin/contacts/contacts.R")


# make a function to send them all
email_send_batch <- function(recip){
  blastula::smtp_send(
    email = email,
    from = "info@newgraphenvironment.com",
    to = recip,
    subject = "Happy Holidays from New Graph Environment!",
    credentials = blastula::creds_key(id = "gmail")
  )
}

# test locally
l |>
  purrr::map(email_send_batch)


# and go ahead and mail it to the whole list - only works if it is small
# contacts_all |>
#   dplyr::pull(email) |>
#   purrr::map(email_send_batch)

# break into batches of 70 to send and not hit limits
contacts_split <- split(contacts_all$email, ceiling(seq_along(contacts_all$email) / 70))

# send in chunks 1 per minute
purrr::walk(seq_along(contacts_split), \(i) {

  blastula::smtp_send(
    email = email,
    from = "al@newgraphenvironment.com",
    to = "al@newgraphenvironment.com",
    bcc = contacts_split[[i]],
    subject = "Happy Holidays from New Graph Environment!",
    credentials = blastula::creds_key(id = "gmail")
  )

  message("Sent batch ", i, " of ", length(contacts_split))

  Sys.sleep(60)
})
