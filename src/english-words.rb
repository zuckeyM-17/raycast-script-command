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

open_ai_api_key = 'OPEN_AI_API_KEY'

system_message = <<~SYSTEM_MESSAGE
  Based on the English word entered by the user, output the "Japanese meaning", "English description", "thesaurus", "phonetic symbols", and "example sentences" in the following format (JSON).

  # Given word

  description

  # Output

  {
    "additional_info": "this is additional info",
    "ja": "記述、叙述、描写",
    "description": "a statement that represents something in words",
    "thesaurus": "account, characterization, chronicle, depiction, description, detail",
    "phonetic_symbols": "dɪskrípʃən",
    "examples": [
      "the description of the event was quite different from what had actually happened.",
      "The description of the book was accurate."
    ]
  }
SYSTEM_MESSAGE

user_message = ARGV[0]

uri = URI.parse('https://api.openai.com/v1/chat/completions')
request = Net::HTTP::Post.new(uri)
request.content_type = 'application/json'
request['Authorization'] = "Bearer #{open_ai_api_key}"
request.body = {
  model: 'gpt-3.5-turbo',
  messages: [
    { role: 'system', content: system_message },
    { role: 'user', content: user_message },
    { role: 'system', content: '{ "additional_info":' }
  ]
}.to_json

req_options = {
  use_ssl: uri.scheme == 'https'
}

response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end

res = JSON.parse(format('{ "additional_info": %s', JSON.parse(response.body)['choices'][0]['message']['content']))

notion_api_token = 'NOTION_API_TOKEN'
english_words_database_id = 'ENGLISH_WORDS_DATABASE_ID'

uri = URI.parse('https://api.notion.com/v1/pages')
request = Net::HTTP::Post.new(uri)
request.content_type = 'application/json'
request['Authorization'] = "Bearer #{notion_api_token}"
request['Notion-Version'] = '2022-06-28'

def create_content(text)
  {
    object: 'block',
    type: 'paragraph',
    paragraph: { rich_text: [{ type: 'text', text: { content: text } }] }
  }
end

request.body = {
  parent: { database_id: english_words_database_id },
  properties: {
    en: {
      title: [
        { text: { content: ARGV[0] } }
      ]
    },
    ja: {
      rich_text: [{ text: { content: res['ja'] } }]
    },
    sym: {
      rich_text: [{ text: { content: res['phonetic_symbols'] } }]
    }
  },
  children: [
    create_content(res['description']),
    create_content('## thesaurus'),
    create_content(res['thesaurus']),
    create_content('## examples')
  ].concat(res['examples'].map { |e| create_content(e) })
}.to_json

req_options = {
  use_ssl: uri.scheme == 'https'
}

Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
