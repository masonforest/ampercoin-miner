require 'bundler/setup'
Bundler.require

require 'optparse'
require 'httparty'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
end.parse!

p options
p ARGV

loop do
  @transactions = HTTParty.get("http://localhost:3000/transactions.json?status=unmined")

  @transactions.each do |transaction|
    transaction = Ampercoin::Transaction.new(
      sender: transaction['sender'],
      receiver: transaction['receiver'],
      amount: transaction['amount']
    )

    transaction.mine
    puts "mined"

    HTTParty.post "http://localhost:3000/transactions/#{transaction.id}",
      body: {magic_number: transaction.magic_number}
  end

  sleep 1
end

