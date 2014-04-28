#### about the data
# The data shows the origins of the international MIT students.
#
# The data was provided by MIT International Student Office (http://web.mit.edu/iso/)
# and was shared through the Analytics Edge course from MIT via EdX.



#### set up working directory
rm(list = ls())
getwd()
setwd('/Users/hawooksong/Desktop/r_visualization/MIT_international_students')
dir()


#------------
# Barplot
#------------

## load the ggplot2 library
library(ggplot2)



## load intl.csv data
intl <- read.csv("data/intl.csv")
head(intl, 10)
str(intl)




## make a bar plot
ggplot(intl, aes(x=Region, y=PercentOfIntl)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=PercentOfIntl))
dev.copy(png, './figures/1.png')
dev.off()

## make Region an ordered factor and re-plot: attempt 1
intl <- intl[order(- intl$PercentOfIntl), ]  
intl
# this command re-orders the rows in the data frame but does NOT re-order the Region factor variable

ggplot(intl, aes(x=Region, y=PercentOfIntl)) +
  geom_bar(stat="identity") +
  geom_text(aes(label=PercentOfIntl))



## make Region an ordered factor and re-plot: attempt 2
intl <- transform(intl, Region = reorder(Region, -PercentOfIntl))
# this command not only re-orders the rows in the data frame but also re-orders the Region factor variable

ggplot(intl, aes(x = Region, y = PercentOfIntl)) + 
  geom_bar(stat = 'identity') + 
  geom_text(aes(label = PercentOfIntl))
dev.copy(png, './figures/2.png')
dev.off()



## make the percentages out of 100 instead of fractions
intl$PercentOfIntl = intl$PercentOfIntl * 100



## make the plot
ggplot(intl, aes(x=Region, y=PercentOfIntl)) +
  geom_bar(stat="identity", fill="dark blue") +
  geom_text(aes(label=PercentOfIntl), vjust=-0.4) +
  ylab("Percent of International Students") +
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_text(angle = 45, hjust = 1))
dev.copy(png, './figures/3.png')
dev.off()



#------------
# World map
#------------

## load the ggmap package
# library(ggmap)
# detach('package:ggmap', unload = TRUE)

## Load in the international student data
intlall <- read.csv("data/intlall.csv",stringsAsFactors=FALSE)

## Lets look at the first few rows
head(intlall)
head(is.na(intlall))
unique(is.na(intlall$Citizenship))

## Those NAs are really 0s, and we can replace them easily
intlall[is.na(intlall)] = 0

## Now lets look again
head(intlall) 

## Load the world map
world_map <- map_data("world")  # map_data() is from ggplot2 package
head(world_map)
str(world_map)

## Lets merge intlall into world_map using the merge command
mapIntlMIT <- merge(world_map, intlall, by.x ="region", by.y = "Citizenship")
head(mapIntlMIT)
str(mapIntlMIT)

## Plot the map
ggplot(mapIntlMIT, aes(x=long, y=lat, group=group)) +
  geom_polygon(fill="white", color="black") +
  coord_map("mercator")
dev.copy(png, './figures/4.png')
dev.off()

## Reorder the data
mapIntlMIT <- mapIntlMIT[order(mapIntlMIT$group, mapIntlMIT$order), ]

## Re-plot
ggplot(mapIntlMIT, aes(x=long, y=lat, group=group)) +
  geom_polygon(fill="white", color="black") +
  coord_map("mercator")
dev.copy(png, './figures/5.png')
dev.off()

## Let's look for China
# in the intlall data set
grep('China', intlall$Citizenship)
intlall$Citizenship[19]

# in the world_map data set
grep('China', unique(world_map$region))
unique(world_map$region)[48]

# because intlall and world_map data sets used diifferent names for China, it was
# dropped during the merge process

## How about Russia?
# in the intlall data set
grep('Russia', intlall$Citizenship)
intlall$Citizenship[81]

# in the world_map data set
grep('Russia', unique(world_map$region))
sort(unique(world_map$region))

ggplot(world_map, aes(x = long, y = lat, group = group)) + 
  geom_polygon(color = 'black', fill = 'white')
dev.copy(png, './figures/6.png')
dev.off()

head(subset(world_map, long > 150 & lat > 50))

## Lets "fix" that in the intlall dataset
intlall$Citizenship[intlall$Citizenship=="China (People's Republic Of)"] = "China"
intlall$Citizenship[intlall$Citizenship=='Russia'] = 'USSR'

## We'll repeat our merge and order from before
mapIntlMIT <- merge(world_map, intlall, 
                   by.x ="region",
                   by.y = "Citizenship")
mapIntlMIT <- mapIntlMIT[order(mapIntlMIT$group, mapIntlMIT$order),]

## re-plot with mercator projection
ggplot(mapIntlMIT, aes(x=long, y=lat, group=group)) +
  geom_polygon(aes(fill=Total), color="black") +
  coord_map("mercator")
# what is going on?

## re-plot without mercator projection
ggplot(mapIntlMIT, aes(x=long, y=lat, group=group)) +
  geom_polygon(aes(fill=Total), color="black") 
dev.copy(png, './figures/7.png')
dev.off()

## We can try other projections - this one is visually interesting
ggplot(mapIntlMIT, aes(x=long, y=lat, group=group)) +
  geom_polygon(aes(fill=Total), color="black") +
  coord_map("ortho", orientation=c(20, 80, 0))
dev.copy(png, './figures/8.png')
dev.off()
