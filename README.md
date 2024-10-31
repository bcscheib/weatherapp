# Weatherapp

This is a demo app to use retrieve the current forecast for today.

### Running Locally

You'll want the `master.key` file shared with you first 
so you can get the API key I used (see API section below)

Then you're starting your app like normal
`rails s`

Run tests with
`rspec`

### API

The API used to retrieve results is available at
https://www.weatherapi.com

You must either get a new API key and put it in the secure credentials
or use the master key to decrypt and use current credentials.

Otherwise, you will receive an error trying to get results.

That error looks like `Woops, the API url for gathering data is bad or unreachable! Check the URL and API key.`

### Design

Most of the app source is in an application boundary called `weather` available at
`app/src/weather`.

In order to maintain principle of least responsiblity we are adapting an 
interpretation of domain drive design DDD and using design patterns
like factories and value objects as well as use cases, of which we only have one
here since our data is used in one instance, a search.

The main use case is `use_cases/weather_search.rb` which serves as the main entry point for our controller 
`WeatherController#index` action.

We are also set up such that we could implement other APIs or strategies later to show data by adding
an IoC or some other pattern swapping the `WeatherAPICom` API for another API, such as Apple's.

## Functionality

You can look up weather conditions in either a postal code in the US
or a city/state combination.

So for example you can try
`20814` which is `Bethesda,MD`

Or you can try
`Bethesda,MD` directly in the search box.

We show the name of the location, the current temp, the high and low for the day.

To clear the form, you can use the `Reset` button, which just shows the instructions again.

We also show if a location's data was cached with a label of `**This is Cached Result.` when it was cached.

## Caching

Currently we are only using the memory cache store and caching for 30 minutes
the actual results from the API, not the action itself or the html response of the action.

## Known Issues
- while you can do US zip codes and city/states, you are able to put in a city/country as well - didn't get around to limiting that

So for instance `Paris,France` works

- sometimes if you put in an incorrect city/state combo what comes back can be a different state than what you had entered

So for instance enter `scranton,nj` and you get `Scranton,KS` results and location name