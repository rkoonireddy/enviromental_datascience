###install R and R studio
# R: www.r-project.org
# RStudio: www.rstudio.com

### some useful links to learn R
# Introduction to R for Economists: https://www.youtube.com/watch?v=kD1qq5tBrLg&list=PLcTBLulJV_AIuXCxr__V8XAzWZosMQIfW
# R for Econometrics: https://raw.githack.com/uo-ec607/lectures/master/08-regression/08-regression.html
# R for Econometrics II: https://hhsievertsen.github.io/applied_econ_with_r/
# Intro to R: https://hhsievertsen.shinyapps.io/r_introduction/
# Rstudio basics: https://github.com/matteorg/r_for_very_beginners/blob/main/BasicsRStudio.html
# Last years tutorial (polished): https://github.com/matteorg/intro_R_for_Econometrics/blob/main/IntroToR.R
# A package to provide help with basic R: https://spielmanlab.github.io/introverse/



########### Overview
# 0. basic R objects
# 1. set working directory, install packages and getting help
# 2. import data
# 3. clean data
# 4. summarize data
# 5. data visualization
# 6. regressions and tests
# 7. R markdown



### packages that need to be installed
#install.packages("foreign")
#install.packages("readr")
#install.packages("readxl")
#install.packages("dplyr")
#install.packages("Hmisc")
#install.packages("fastDummies")
#install.packages("tidyr")
#install.packages("vtable")
#install.packages("stargazer")
#install.packages("wooldridge")
#install.packages("gapminder")
#install.packages("ggplot2")
#install.packages("gganimate")
#install.packages("gifski")
#install.packages("av")
#install.packages("sandwich")
#install.packages("lmtest")
#install.packages("fixest")
#install.packages("broom")
#install.packages("modelsummary")
#install.packages("AER")
#install.packages("car")
#install.packages("foreign")


# 0. basic R objects: values, vectors, matrices, data frames --------------
### data types
typeof(3) # mostly numbers are stored as double
typeof(3.5)
typeof('hello') # strings are stored as character
typeof(TRUE) # logical
3 > 5
typeof(3 > 5)

### assign a value
a <- 1  # shortcut: option + - for mac, alt + - for windows

### vector
# create a vector
x <- c(1, 2, 3, 4, 5)
y <- c(4: 8)
# show certain elements of a vector
x[2]  # by index
y[2:4]
y[y > 5]  # by certain condition

### matrices
# create a matrix
z <- cbind(x, y)
z
class(z)
# show certain elements
z[3, 2]   # index: row 3, column 2
z[z > 3] # by certain condition
z[x > 3]

### data frame
# change matrix to data frame
w <- as.data.frame(z)
class(w)
dim(w)
# create a new variabe in a data frame
w$a <- c(6:10)
# show certain element of certain variable
w[2, ] # show second row
w[ , 3] # show the third column
w$y[3] # show third element of variable y



# 1. set working directory, install packages and getting help -------------

### set working directory
# what I usually do: session--set working directory--choose directory (you should choose the folder where you downloaded the R folder from OLAT)
#setwd("/Users/jifeng/Dropbox (Personal)/Courses.MSc.Empirical.Methods/Active/TA_sessions/Week_3_jf/R Tutorial/R")
getwd()

### install packages

# load! (different from stata, need to load before use it)
library(foreign)



### getting help
help("list.files") # get help for basic functions
?list.files  # same as help()
??dplyr # more general
??foreign::read.dta   #certain function in a package
?`:`  # help for symbol


### remove an object
rm(x)

### clear working space
rm(list=ls())





# 2. import data ----------------------------------------------------------

### getting data from internet
# download data from internet
url <- "https://www.stats.govt.nz/assets/Uploads/Annual-enterprise-survey/Annual-enterprise-survey-2017-financial-year-provisional/Download-data/annual-enterprise-survey-2017-financial-year-provisional-csv.csv"
download.file(url, destfile = "data/asset.csv") #then can check data is in the directory folder, can also specify location to store at certain folder
list.files("data")

### read data
# csv files
library(readr)
assetData = read_csv("data/asset.csv", col_names = TRUE)
#excel
library(readxl)
berkeleyData <- read_xls("data/berkeley.xls" )
#dta
library(foreign)
mrozData <- read.dta("data/mroz.dta" )

###view dataset
# get to know dataset
dim(berkeleyData)  # show dimension of dataset
colnames(berkeleyData)  # show variable names
str(berkeleyData)  # show dataset structure
# view dataset
head(berkeleyData) # show what the dataset looks like from the top
head(berkeleyData, n = 10) # specify number of obs to be shown
View(berkeleyData) # open the dataset, same as click on the dataset
View(berkeleyData[berkeleyData$Applications=="Men", ]) #only view certain rows with some condition
View(berkeleyData[,2:4]) # only view certain columns
View(dplyr::select(berkeleyData, Admit:Total)) # only show certain variables, need select function from dplyr package
View(dplyr::select(berkeleyData,c('Admit','Total'))) # select vars to be shown

### Remove dataset
rm(assetData)



# 3. clean data -----------------------------------------------------------

library(dplyr)
### rename variable
View(mrozData)
mrozData <- rename(mrozData, husband_age = husage, husband_education = huseduc, husband_wage = huswage)
# two conventions: either husband_education, or husbandEducation

### label a variable
library(Hmisc)
label(mrozData$hushrs) = "Working hours per year for husbands"
View(mrozData)


### sort data
mroz_sort <- arrange(mrozData, educ)
mroz_sort <- arrange(mrozData, desc(educ))
## note: in R, always remember to say where you want R to put the altered object after any command
      # just run arrange(mrozData, wage) won't do anything to the original dataset
arrange(mrozData, educ)

### create new variables
# option 1 
mrozData = mutate(mrozData, log_hours=log(hours), hours_10 = hours/10)
# option 2
mrozData$log_wage = log(mrozData$wage)

### create a categorical variable based on certain condition
# option 1
mrozData <-  mutate(mrozData, high_edu = factor((educ > 10), labels = c("low", "high")))   # check what factor function does: factor(mrozData$educ>10)
View(select(mrozData, c('educ','high_edu')))
# Option 2 (bit slower)
mrozData$highedu[mrozData$educ <= 10] = "low"
mrozData$highedu[mrozData$educ > 10] = "high"
View(select(mrozData, c('educ','highedu', 'high_edu')))

### Transform categorical into numeric dummy variable
mrozData$highedu2 = as.numeric(mrozData$highedu=="high")
View(select(mrozData, c('educ','highedu', 'highedu2')))

### create dummies from categorical variable
library(fastDummies)
dummy <- dummy_cols(berkeleyData, select_columns = "Major")


### drop variables from certain dataset
mrozData <- within(mrozData, rm("highedu","high_edu"))
mrozData$highedu2 = NULL


### reorder variables
mrozData_relo <- relocate(mrozData, wage, educ, age)

### reshape dataset
library(tidyr)
wide <- table4a # table4a is just an existing dataset 
pivot_longer(wide, c("1999", "2000"))
long <- pivot_longer(wide, c("1999", "2000"), names_to = 'year', values_to = 'gdp')
wide2 <- pivot_wider(long, id_cols = 'country', names_from = 'year', values_from = 'gdp', names_prefix = 'year_')

### merge datasets
# first just create two datasets for illustration, you can ignore this step
first_df <- tibble(
  country = c('Afghanistan', 'Belgium', 'China', 'Denmark'),
  population = c(333, 11, 1382, 57)
)
second_df <- tibble(
  country = c('Afghanistan', 'Belgium', 'Denmark', 'Germany'),
  gdp = c(35, 422, 211, 3232)
)
# the actual merge
left_join(first_df, second_df, by = "country") # merge based on obs from first_df
right_join(first_df, second_df, by = "country") # merge based on obs from second_df
inner_join(first_df, second_df, by = "country") # merge based on common obs
full_join(first_df, second_df, by = "country") # merge based on obs from both first_df and second_df


### create subset of data
## in R, can work with different data frames at the same time, not like stata
# select some variables（columns)
sub1 <- subset(mrozData, select = age:wage)
sub2 <- subset(mrozData, select = c("hours","age","wage","city"))
# select certain subsample(rows) based on certain condition
sub3 <- filter(mrozData, city==1) # only obs from the city
sub3 <- subset(mrozData, city==1) # equivalent
# of course can combine both and set more conditions
sub4 <- subset(mrozData, city==1 & educ>12, select = c("hours","age","wage","city", "educ"))


### deal with missing values
# first create a small dataset with missing valus (you can ignore this step)
missing <- full_join(first_df, second_df, by = "country")
# count number of missing values in certain variable
sum(is.na(missing$gdp)) # gives you 1 missing
# create a new variable from existing variable if that var is not missing
missing$highgdp[missing$gdp <= 300 & is.na(missing$gdp) == FALSE] = "low"
missing$highgdp[missing$gdp > 300 & is.na(missing$gdp) == FALSE] = "high"
# Important remarks:
   # -You can use == (exactly equal), >, <, <=, >=, or != (not equal)
   # -While "&" sets joint conditions, "|" means "or"
   # -You cannot say missing$gdp!=NA to say "if gdp is not missing"
   # -You need to use is.na(variable_name)==TRUE/FALSE, which reads: [if variable is (TRUE) or is not (FALSE) missing (na)]





# 4. summarize data -------------------------------------------------------

# Let's first create a folder for figures and tables
if(!file.exists("Figures&Tables")){
  dir.create("Figures&Tables")
}

### summary of the whole dataset
summary(berkeleyData) # brief summary of all variables
## summary for a subset of dataset 
# can use pipe operator %>%: "then" operator, can combine several steps in one command, shortcut: command+shift+m for mac
mrozData %>% mutate(log_hours=log(hours)) %>% subset(city==1, select = c("age", "wage", "log_hours")) %>% summary


### basic summary statistics for one variable
mean(mrozData$wage)
sd(mrozData$wage)
summarise(mrozData, mean_wage = mean(wage, na.rm = TRUE), sd_wage = sd(wage), median_wage = median(wage), min_edu = min(educ))  #na.rm = TRUE means: calculate the mean ignoring any missing
sum1 <- summarise(mrozData, mean_wage = mean(wage, na.rm = TRUE), sd_wage = sd(wage), median_wage = median(wage), min_edu = min(educ))


### summary frequency
table(mrozData$educ) # summary of frequency of categorical variable
mytable <- table(mrozData$educ, mrozData$city) # summary of frequency by two categorical variables
mytable
prop.table(mytable) # cell percentages
margin.table(mytable, 1) # educ frequencies, sum over city
margin.table(mytable, 2) # city frequencies, sum over educ

### summarize by group
# use group_by from dplyr
group <- group_by(mrozData, kidslt6)  # this doesn't change dataset itself, but changes how the dataset is perceived
summarise(group, mean_wage = mean(wage), sd_wage = sd(wage), max_wage = max(wage))

# or use vtable to get nicer tables
install.packages("vtable")
library(vtable)
st(mrozData, group='city') # summarize all variables by city
# create a subset with certain vars
sub5 <- subset(mrozData, select = c("hours","age","wage","city", "educ", "kidsge6", "kidslt6"))
st(sub5, group='kidslt6') # summarize selected variable by kidslt6 (can also set certain condition)
st(sub5, group='kidslt6', file='Figures&Tables/sum_group.html') # store it as html file

### export summary table
library(stargazer)
stargazer(mrozData, type="text") # as text
stargazer(subset(mrozData, city==1, select = c(age, educ, wage, hours, exper)),type = "html", out = "./Figures&Tables/sum_mroz.html") # summary selected variables and export as html



# 5. data visualization ---------------------------------------------------


### basic plots
airquality <- airquality #import a dataset that is already in R 
# Basic histogram
hist(airquality$Ozone)
# Scatter plot
with(airquality, plot(Wind, Ozone)) #option 1
plot(airquality$Wind, airquality$Ozone) #option2
# add title
plot(airquality$Wind, airquality$Ozone, main = "Ozone and Wind in New York City") 
# label x, y axis
plot(airquality$Wind, airquality$Ozone, main = "Ozone and Wind in New York City", xlab ="wind", ylab = "ozone") 
# specify lower and upper limit of axes
plot(airquality$Wind, airquality$Ozone, main = "Ozone and Wind in New York City", xlab ="wind", ylab = "ozone", xlim = c(5,15), ylim = c(50,100)) 
# Change color of a subset of your datapoints
plot(airquality$Wind, airquality$Ozone) # the original plot
with(subset(airquality, Month == 5), points(Wind, Ozone, col = "blue")) # change obs in May to blue
with(subset(airquality, Month != 5), points(Wind, Ozone, col = "red")) # change obs not in May to red
legend("topright", pch = 1, col = c("blue", "red"), legend = c("May", "Other Months"), pt.cex=0.7, cex=0.7)
#note: pch: type of symbols; col: color;cex: size of the box;pt.cex:size of symbols in legend; cex: size of text in legend--can refer to cheatsheet, see "R_reference_card"
# add a line
abline(a=0,b=1) # 45° line y = a + bx
abline(h=75, col = "blue") # horizontal line at 75 with color blue
abline(v=12, col = "red") # vertical line at 12 with color red


### nicer plots with ggplot2
# ggplot2 reference: https://ggplot2.tidyverse.org/reference/
library(wooldridge)
library(gapminder) 
library(ggplot2)
gapminder <- gapminder #import dataset
## plots for one variable
# histogram
ggplot(gapminder) +
  geom_histogram(aes(x = lifeExp), bins = 15)
# bar graph
ggplot(gapminder) +
  geom_bar(aes(x = continent))
# density plot
ggplot(gapminder) +
  geom_density(aes(x = lifeExp))
# density plot by continent
ggplot(gapminder) +   
  geom_density(aes(x = lifeExp, color = continent))

## scatter plot for two variables
# generate an empty graph with only axis
ggplot(gapminder, aes(x = gdpPercap, y = lifeExp))
# add points
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp))
# Change the point color, size and transparency of all points--write outside aes()
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp), color = 'blue') # color
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp), size = 0.5) # size
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp), alpha = 0.5) # alpha changes transparency
# Change the point color, size and transparency by variable-write inside aes()
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp, color = continent)) # color
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp, size = continent)) # size
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp, alpha = continent)) # transparency
ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp, color = year >1980)) # change color by specified condition

# adding more to the plot
g <- ggplot(gapminder) + geom_point(aes(x = gdpPercap, y = lifeExp, color = continent))
g
# add labels, title and caption
g1 <- g + 
  labs(x =  'GDP per capita', 
        y = 'life expectancy',
        color = 'Continent',
        title = 'Relationship between life expectancy and GDP per capita',
        caption = 'dataset: gapminder')
g1
# change scale of axis
g1 + 
  scale_y_continuous(breaks = seq(0,100,10))
  
# add a smooth fit
g1 +
  geom_smooth(aes(x = gdpPercap, y = lifeExp), color = 'red')
  
# add a linear fit, without confidence interval
g1 +
  geom_smooth(aes(x = gdpPercap, y = lifeExp), method = lm, se = FALSE, color = 'red')

# plot multiple plots
ggplot(data = gapminder) +
  geom_point(aes(x = gdpPercap, y = lifeExp)) +
  facet_wrap(~continent, nrow = 2)

# can also change themes
g1
g1 +
  theme_bw()
g1 + 
  theme_classic()
g1 + 
  theme_dark()

# save the plot
ggsave('Figures&Tables/figure1.png',plot = g1, width = 8, height = 6, dpi = 300)

# last fancy thing: animation!
install.packages("gganimate")
library(gganimate)
install.packages("gifski")
install.packages("av")
library(gifski)
library(av)
g1 +
  # Here comes the gganimate specific bits
  labs(title = 'Year: {frame_time}', x = 'GDP per capita', y = 'life expectancy') +
  transition_time(year) +
  ease_aes('linear')


# 6. regressions and tests ------------------------------------------------
library(wooldridge)
library(gapminder)
gapminder <- gapminder
View(gapminder)

### simple OLS with only one regressor
ols1 <- lm(lifeExp ~ gdpPercap, data = gapminder)  # by default, including a constant
summary(ols1)
library(stargazer)
stargazer(ols1, type = 'text')
# recover coefficients by hand:
# vector notation
y = gapminder$lifeExp
x = gapminder$gdpPercap # define x and y
# plug in the formula
beta_1 = cov(x,y)/var(x)
beta_0 = mean(y)-beta_1*mean(x)
beta_0 
round(beta_1, digits = 3) # round it to the 3rd decimal
# matrix notation
X = as.matrix(cbind(1,gapminder$gdpPercap))
head(X)
dim(X)
Y = as.matrix(gapminder$lifeExp)
head(Y)
dim(Y)
beta = solve(t(X)%*%X)%*%t(X)%*%Y  # solve(A) gives the inverse of A where A is a square matrix  
beta
round(beta, digits = 3)

### add more controls
ols2 <- lm(lifeExp ~ gdpPercap + pop, data = gapminder)
stargazer(ols2, type = 'text')
# can also add transformed controls
ols3 <- lm(lifeExp ~ log(gdpPercap) + pop + I(pop^2), data = gapminder) # I(pop^2) gives squared population term
stargazer(ols3, type = 'text')
# interaction term
ols4 <- lm(lifeExp ~ gdpPercap + pop + gdpPercap:pop, data = gapminder) # gdpPercap:pop gives interaction term
stargazer(ols4, type = 'text')
ols5 <- lm(lifeExp ~ gdpPercap*pop, data = gapminder) # equivalent to ols4
stargazer(ols5, type = 'text')

### display two regressions together and export
stargazer(ols1, ols2, title="Results", align=TRUE, type="text")
stargazer(ols1, ols2, title="Results", align=TRUE, type="text", add.lines = list(c("Controls", "No", "Yes")))  # can add lines
stargazer(ols1, ols2, title="Results", align=TRUE, type="text", add.lines = list(c("Controls", "No", "Yes")), out="Figures&Tables/ols.html") # export

# get certain coefficient and store it
summary(ols2)
coef(ols2)[2]
summary(ols2)$coefficients
coeff <- summary(ols2)$coefficients[2,1]
std <- summary(ols2)$coefficients[2,2]
p <- summary(ols2)$coefficients[2,4]
print(paste("Coefficient is",coeff,
            "standard error is", std, 
            "p value is", p)) # could also round them to look better

# Store and check the residuals 
resid1 <- resid(ols2)
head(resid1)
mean(resid1)
round(mean(resid1), digits = 3)
plot(fitted(ols2), resid1) # plot residuals against fitted values to check homoskedasticity
abline(h = 0)
plot(density(resid1)) # check if it's roughly bell-shaped

### robust standard errors
library(sandwich)
library(lmtest)
stargazer(coeftest(ols2,vcovHC),type="text")

### clustered standard errors
stargazer(coeftest(ols2,vcovCL, cluster=gapminder$country),type="text")

### add fixed effects
library(fixest)
fe1 <- feols(lifeExp ~ gdpPercap + pop | continent, data = gapminder) # continent FE
summary(fe1)
# this package is also easy for robust and cluster standard errors
fe2 <- feols(lifeExp ~ gdpPercap + pop | continent, se = 'hetero', data = gapminder) # robust SE
summary(fe2)
fe3 <- feols(lifeExp ~ gdpPercap + pop | continent, cluster = c('country') , data = gapminder) # cluster SE at country level
summary(fe3)
# another way to look at the results
library(broom)
fe2 <- tidy(fe1)

### create regression table (unfortunately feols doesn't work with stargazer)
library(modelsummary)
models <- list('OLS' = ols2, 'FE' = fe1)  #put the models into a list first
modelsummary(models)
# add labels, stars, ignore some stats
modelsummary(models, coef_map = c('gdpPercap' = 'GDP per capita', 'pop' = 'population'), 
             gof_omit = "AIC|BIC|DF|Deviance|IC|Log|Adj|Pseudo|Within|se_type", stars = c('*'  = 0.1, '**' = 0.05, '***' = 0.01))

### export 
modelsummary(models, coef_map = c('gdpPercap' = 'GDP per capita', 'pop' = 'population'), 
             gof_omit = "AIC|BIC|DF|Deviance|IC|Log|Adj|Pseudo|Within|se_type", stars = c('*'  = 0.1, '**' = 0.05, '***' = 0.01), output = 'Figures&Tables/results.tex')



### instrumental variable (IV) regression
ivdata <-  wooldridge::card # need another dataset with instrument
# OLS result
ols = lm(wage ~ educ + black + fatheduc + exper + IQ + south 
            + married + momdad14, data=ivdata)
# Use nearc2 (which is a dummy indicating whether the house is close to a 4-year college) as instrument for education
library(AER)
iv1 = ivreg(wage ~ educ + black + fatheduc + exper + IQ + south 
              + married + momdad14 | nearc4 + black + fatheduc + exper + IQ + south 
              + married + momdad14, data = ivdata)
stargazer(ols, iv1, type = 'text')
firststage = lm(educ ~ nearc4 + black + fatheduc + exper + IQ + south 
                + married + momdad14, data=ivdata)
stargazer(firststage, type = 'text')

# or use feols again
iv2 = feols(wage ~ black + fatheduc + exper + IQ + south 
            + married + momdad14 | educ ~ nearc4, data = ivdata)
summary(iv2)
summary(iv2, stage = 1)



### some hypotheses testing
# simple t tests
# want to test whether mean wage is different from 0
mean(ivdata$wage) # have a look at mean wage
t.test(ivdata$wage) # t test
t.test(ivdata$wage - 577) # test if the mean is 577
# compare father education with mather education
mean(ivdata$fatheduc, na.rm = TRUE)
mean(ivdata$motheduc, na.rm = TRUE)
t.test(ivdata$fatheduc - ivdata$motheduc) # test if the mean of father education is same as mother education
t.test(ivdata$fatheduc - ivdata$motheduc, alternative = c("less")) # test if father's education is more than mother's education


# F tests
library(car)
linearHypothesis(ols,c("black = 0", "exper = 0"), type = c("F"))   # test if the coefficient on black and the coefficient on exper are jointly 0, from the regression in line 549


# 7. R markdown -----------------------------------------------------------

##########################################
# Before we finish: how to open Markdown #
##########################################
# Go to 'file' ---> 'New File' ---> 'R Markdown'
# You may get a message asking to install 1 or more packages. Do it.
# Then you have to select the 'type' of document you want to produce
# Select 'document' (you may notice you can also prepare presentations)
# Type the title of the document (example: "Problem Set 1")
# Type the author(s)
# Select output format (I would say 'pdf') then press 'ok'
# A new document will open. Save it in subfolder within your working directory
# Then you can start using the document. You can look at the uploaded template for more.



