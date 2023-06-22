#!/usr/bin/env ruby

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title english-words
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "Placeholder" }

require 'net/http'
require 'uri'
require 'json'

open_ai_api_key = "OPEN_AI_API_KEY"

system_message = <<~SYSTEM_MESSAGE
  Please output "Japanese meaning", "English description", "thesaurus", "phonetic symbols", and "example sentences" based on the given English word in the following format.

  # Given word

  description

  # Output

  Japanese meaning: 記述、叙述、描写
  English description: a statement that represents something in words
  Thesaurus: account, characterization, chronicle, depiction, description, detail
  Phonetic symbols: dɪskrípʃən
  Example sentences:
  - The description of the book was accurate.
  - The description of the book was accurate.
SYSTEM_MESSAGE

user_message = ARGV[0]

uri = URI.parse('https://api.openai.com/v1/chat/completions')
request = Net::HTTP::Post.new(uri)
request.content_type = 'application/json'
request['Authorization'] = "Bearer #{open_ai_api_key}"
request.body = {
  model: "gpt-3.5-turbo",
  messages: [
    { role: "system", content: system_message },
    { role: "user", content: user_message }
  ]
}.to_json

req_options = {
  use_ssl: uri.scheme == 'https'
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

puts response.body
