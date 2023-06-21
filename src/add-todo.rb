#!/usr/bin/env ruby

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title add-todo
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🤖
# @raycast.argument1 { "type": "text", "placeholder": "TODO" }
# @raycast.argument2 { "type": "text", "placeholder": "Category" }

require 'net/http'
require 'uri'
require 'time'
require 'json'

notion_api_token = 'NOTION_API_TOKEN'
daily_task_database_id = 'DAILY_TASK_DATABASE_ID'

cat = 'Skill'
categories = %w[Skill 家事 Studist プライベート]
cat = ARGV[1] if categories.include?(ARGV[1])

uri = URI.parse('https://api.notion.com/v1/pages')
request = Net::HTTP::Post.new(uri)
request.content_type = 'application/json'
request['Authorization'] = "Bearer #{notion_api_token}"
request['Notion-Version'] = '2022-06-28'
request.body = {
  parent: { database_id: daily_task_database_id },
  properties: {
    name: {
      title: [
        { text: { content: ARGV[0] } }
      ]
    },
    start_date: {
      date: { start: Time.now.strftime('%F') }
    },
    status: {
      select: { name: '今日の作業' }
    },
    category: {
      select: { name: cat }
    }
  }
}.to_json

req_options = {
  use_ssl: uri.scheme == 'https'
}

Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
  http.request(request)
end
