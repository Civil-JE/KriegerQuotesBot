require 'twitter'
require 'csv'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

############Twitter key Variable set #######################
$TWITTER_APP_KEY=
$TWITTER_APP_SECRET=
$TWITTER_ACCESS_TOKEN=
$TWITTER_ACCESS_TOKEN_SECRET=
######################Variables###############################

runNumTimesARGV = ARGV[0] #Input for how many times you want the script to run
hoursARGV = ARGV[1] #Input to variable for how many hours you want the script to wait before running again. 
$runNumTimes = Integer(runNumTimesARGV) #Converts the input for how many times to run to an integer
$hours = Integer(hoursARGV) #Converts the input for how hours to wait before running again to an integer
$oldQuote = Array.new #Creates an array to hold quotes already used
$numberofQuotes #Number of quotes in the .CSV file

################# Reads in a random quote from the .csv file. ################
def read_in_quote
	if $counter == 0 #If this is the first quote, don't need to check to see if it was already posted
		CSV.foreach('Quotes.csv') do |row|
			$quote = row[rand(0..$numberofQuotes)]
		end
	else
		begin  #Picks the quote out and then makes sure it hasn't been used recently.
			CSV.foreach('Quotes.csv') do |row|
				$quote = row[rand(0..$numberofQuotes)]
			end
			check_If_Posted
		end until $used == false
	end
end

################ Counts how many quotes are in the CSV file ###############
def countQuotes
	File.foreach('Quotes.csv') {}
	$numberofQuotes = $.
	puts "There are currently: #{$numberofQuotes} quotes in the CSV"
end

################# Checks the quote to see if it's been posted already ################
def check_If_Posted 
	$used = $oldQuote.include? $quote
end

################ Prints the quote into powershell ################
def printQuote 
	client = Twitter::REST::Client.new do |config| #Sets up the twitter connection
		config.consumer_key        = $TWITTER_APP_KEY
		config.consumer_secret     = $TWITTER_APP_SECRET
		config.access_token        = $TWITTER_ACCESS_TOKEN
		config.access_token_secret = $TWITTER_ACCESS_TOKEN_SECRET
	end
	puts "Tweeting out:\n" + $quote
	client.update($quote)
end

################ Stores quote so it can be checked against so it doesn't get used again ################
def set_oldQuote 
	if $counter == 0
		$oldQuote[0] = $quote
	elsif $counter < 11 #If 11 quotes haven't been stored yet, just adds one to the start
		$oldQuote.unshift($quote)
	elsif #If 11 quotes have been stored, deletes the oldest one and adds one to the start
		puts "#{$oldQuote[10]} will be deleted from the list of Old Quotes"
		$oldQuote.delete_at(10)
		$oldQuote.unshift($quote)	
	end
end

################ Sleep for hours given in command line between tweets ################
def sleepfor 
	timetorun = $hours * 60 * 60
	sleep(timetorun)
end

################ Runs everything ################
def run_script 
	i=0
	$counter = 0
	countQuotes
	until i > $runNumTimes
		read_in_quote
		printQuote
		set_oldQuote
		puts "Counter is at #{$counter}"
		puts "Done! Sleeping for #{$hours} hours now."
		puts ""
		i += 1
		$counter += 1
		sleepfor
	end
	puts "Tweeted #{$runNumTimes} times!"
end

run_script


