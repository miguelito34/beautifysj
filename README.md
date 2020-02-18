# Analyzing the Efficacy of the BeautifySJ Initative

### Overview
We will analyze 311 requests in San Jose to understand strends in the systems use and potential areas for improvement. Namely, we will focus on the following questions:

* What are the demographic descriptors of the census block groups who are requesting a majority of services through the mobile app? 
* What are the demographic descriptors of the census block groups who are requesting a majority of services through the web platforms?
* What are the demographic descriptors of the census block groups who are requesting a majority of services through the MySanJose platforms (web and mobile app) combined?

### Getting Set Up

* If you're only interested in downloading the pre-processed data for analysis, skip to the next section.

1. Folder Structure

* __data__: cleaned data
* __data_raw__: raw data
* __docs__: data documentation and notes
* __analysis__: exploratory data analysis on your cleaned data
* __scripts__: data-cleaning scripts
* __reports__: findings to present to others

2. Clone the GitHub repo into a directory of your choosing. You can name the directory whatever you'd like.
```
mkdir <your new folder>
cd <your new folder>
git init
git remote add origin git@github.com:miguelito34/beautifysj.git
git pull origin master
```

3. The first time you go to push a file, you may receive this note:
```
fatal: The current branch master has no upstream branch.
To push the current branch and set the remote as upstream, use

    git push --set-upstream origin master
```

If you see that, push using the instructions as above:
```
git push --set-upstream origin master
```

From now on, anytime you need to make changes, you should be able to push using:
```
git push
```

4. Make a credentials file if you wish to re-run the scripts

In the project directory, create a new R script called `credentials.R`. Include the following lines with the relevant credentials:
```
my_census_api_key <- "<YOUR CENSUS API KEY>"
```

Follow the relevant links to sign up for any needed credentials you don't already have or cannot supply:

* my_census_api_key: [get API key here](https://api.census.gov/data/key_signup.html)

### Data

The data for this project are pulled from many different sources, though they are not to be openly shared.

* __BeautifySJ Requests Data__: This data represents requests for services (Abandoned Vehicles, Graffiti, Illegal Dumping, Potholes, Streetlight Outages, General Requests) which came through the MySanJose website, phone application, or city-wide call-center between July 2018 and September 2019 and was given by our partners at the City of San Jose.

* __San Jose Social Progress Index__: This information describes social progress in San Jose over that past few years. More info on this data can be found [here](https://partners.sanjosemayor.org/performance/social-progress-index/).

* __The US Census__: Data was pulled from the [US Census](https://data.census.gov/cedsci/?intcmp=aff_cedsci_banner) via the R package [tidycensus](https://walkerke.github.io/tidycensus/), which allows for easy access to the Census API.

### Analyzing the Pre-processed Data

You can find the cleaned data to download [here](https://github.com/miguelito34/beautifysj/raw/master/data_clean/requests/beautifysj_data.tsv.zip)