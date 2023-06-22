require 'dotenv'

Dotenv.load

Dir.glob('src/*.rb').each do |file|
  file_name = file.split('/').last

  buffer = File.read(file)

  %w[
    NOTION_API_TOKEN
    DAILY_TASK_DATABASE_ID
    OPEN_AI_API_KEY
    ENGLISH_WORDS_DATABASE_ID
  ].each do |key|
    buffer.gsub!(key, ENV.fetch(key, nil))
  end

  File.write("dist/#{file_name}", buffer)
end
