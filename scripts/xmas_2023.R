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

# Create data frame for a n-level christmas tree
#   - specify 2*n bars (but have only n unique values)
#   - set divergence values (values at the same level should differ only in the sign)
#   - set labels for different parts of the tree
df <- data.frame("Happy" = c("Awesome",  "Awesome", "Solstice", "Solstice", "and", "and",
                            "Merry", "Merry", "Christmas!!!", "Christmas!!!"),
                 "Holidays" = c(-0.3, 0.3, -1.5, 1.5, -2.5, 2.5, -3.5, 3.5, -0.75, 0.75),
                 "part" = c(rep("bottom", 2), rep("tree", 6), rep("star", 2)))
#  c(-0.3, 0.3, -1.5, 1.5, -2.5, 2.5, -3.5, 3.5, -0.75, 0.75)

# Convert wish to factor, specify levels to have the right order
df$Happy <- factor(df$Happy, levels = c("Christmas!!!", "Merry", "and", "Solstice", "Awesome"))

plot <- ggplot(df, aes(x = Happy, y = Holidays, fill = part)) + geom_bar(stat="identity") +
  coord_flip() +
  theme_minimal() +
  ylim(-5, 5) +
  theme(legend.position = "none",
        # axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank()) +
  scale_fill_manual(values = c( "#FDBA1C",  "#643413", "#1A8017")) +
  geom_point(aes(x=3.7, y=0.5), colour="#CF140D", size=12) +
  geom_point(aes(x=2.5, y=-1), colour="#393762", size=12) +
  geom_point(aes(x=1.7, y=1.5), colour="#CF140D", size=12) +
  geom_point(aes(x=2.8, y=2.5), colour="#393762", size=12) +
  geom_point(aes(x=1.8, y=-2.8), colour="#CF140D", size=12)



plot_email <- add_ggplot(plot)

# include the logo
logo_footer <- blastula::add_image(file = 'fig/logo_newgraph/BLACK/PNG/nge-full_black.png')


email <- compose_email(
  header = md(glue(
    "<font size='8' color='black'><b> Thank You for Everything!<b></font>
    <br>
    <font size='4' color='red'> We appreciate your support and collaboration!</font>")),

  body = md(c(

    plot_email
  )),
  footer = md(glue(
    "This card was inspired by an article and code written by Greta Gasparac - here at https://towardsdatascience.com/christmas-cards-81e7e1cce21c.
    <br>
    See the code we used to produce it here https://github.com/NewGraphEnvironment

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

# or make a list of people to send it to
l <- c('joethorley@poissonconsulting.ca',
       'brandon.geldart@sernbc.ca',
       'John.DeGagne@gov.bc.ca',
       'snorris@hillcrestgeo.ca',
       'mike@keefereco.com',
       'lucy@newgraphenvironment.com',
       'tara@newgraphenvironment.com',
       'mateo@newgraphenvironment.com',
       'al@newgraphenvironment.com',
       'mfjeld@nupqu.com',
       'jeremy.phelan@steerenvironmental.com',
       'Craig.Mount@gov.bc.ca',
       'David.Maloney@gov.bc.ca ',
       'Mya.Eastmure@gov.bc.ca',
       'Chelsea.Regina@bchydro.com',
       'afernando@gitksanwatershed.com',
       'jamesbaxternelson@gmail.com',
       'iraleeanderson@gmail.com',
       'ico@masseenvironmental.com',
       'fiona@masseenvironmental.com',
       'tyson@masseenvironmental.com',
       'chaz.ware@gitxsanbusiness.com',
       'emily.hirai@gitxsanbusiness.com',
       'vernon.joseph@wetsuweten.com',
       'tlucoordinator@mlib.ca',
       'parimtee@yahoo.com',
       'tyler.weir@gov.bc.ca'
)


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
