library(ggplot2)
library(blastula)
library(glue)

# this is how we set up the key
# create_smtp_creds_key(
#   id = "gmail",
#   user = "al@newgraphenvironment.com",
#   provider = "gmail",
#   overwrite = TRUE
# )


# Data for Santa hat
hat_df <- data.frame(
  "Element" = c("PomPom", "Hat", "Hat", "Hat"),
  "Position" = c(0, -1, -2, -3),
  "Width" = c(0.5, 2, 3, 4)
)

# Data for stars (reduced by 25%)
star_df <- data.frame(
  x = runif(37, -2.5, 2.5),
  y = runif(37, -0.5, 3.5)
)

plot <- ggplot() +
  # Add yellow stars in the background
  geom_point(
    data = star_df,
    aes(x = x, y = y),
    colour = "yellow",
    size = 1.5
  ) +
  # Hat body (increased size by 20% and extended base to bottom of plot)
  geom_polygon(
    data = data.frame(
      x = c(-2.4, 2.4, 0),
      y = c(0, 0, 3.6)
    ),
    aes(x = x, y = y),
    fill = "#CF140D",
    color = "black"
  ) +
  # White strip at the bottom of the hat (increased depth by 25%)
  geom_polygon(
    data = data.frame(
      x = c(-2.4, 2.4, 2.4, -2.4),
      y = c(0, 0, -0.375, -0.375)
    ),
    aes(x = x, y = y),
    fill = "white",
    color = "black"
  ) +
  # Pom-pom (increased size by 20%)
  geom_point(
    aes(x = 0, y = 3.6),
    colour = "black",
    size = 18
  ) +
  geom_point(
    aes(x = 0, y = 3.6),
    colour = "white",
    size = 14.4
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    plot.title = element_text(hjust = 0.5, colour = "white", face = "bold", family = "serif", size = 15),
    panel.background = element_rect(fill = "black", colour = "black"),
    plot.background = element_rect(fill = "black", colour = "black"),
    panel.grid = element_blank()
  ) +
  labs(title = "Awesome Solstice and Merry Christmas!")

# plot




plot_email <- add_ggplot(plot)

# include the logo
logo_footer <- blastula::add_image(file = 'fig/nge-full_black.png')


email <- compose_email(
  header = md(glue(
    "<font size='8' color='black'><b> Thank U ALL 4 Everything!<b></font>
    <br>
    <font size='4' color='red'> We truly appreciate your support and the spirit of collaboration you bring — it means so much to us!</font>")),

  body = md(c(

    plot_email
  )),
  footer = md(glue(
    # "This card was inspired by an article and code written by Greta Gasparac - here at https://towardsdatascience.com/christmas-cards-81e7e1cce21c.
    # <br>
    # See an interactive online version of the card here https://newgraphenvironment.com/solstice_cards
    # <br>
    "See the code we used to produce this card here https://github.com/NewGraphEnvironment/solstice_cards

    {logo_footer}"))
)

# send just one email
email %>%
  smtp_send(
    from = "info@newgraphenvironment.com",
    to = "al@newgraphenvironment.com",
    subject = "Happy Holidays from New Graph Environment!",
    credentials = creds_key(id = "gmail")
  )

# or make a list of people to send it to.  Moved actual list to mybookdown-template/scripts

l <- c(
  # 'lucy@newgraphenvironment.com',
  #      'tara@newgraphenvironment.com',
  #      'mateo@newgraphenvironment.com',
       'al@newgraphenvironment.com',
       'info@newgraphenvironment.com')

source("/Users/airvine/Library/CloudStorage/OneDrive-Personal/Admin/xmas_contacts.R")


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
l %>%
  purrr::map(email_send_batch)

