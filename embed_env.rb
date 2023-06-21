require 'dotenv'

Dotenv.load

Dir.glob('src/*.rb').each do |file|
  file_name = file.split('/').last

  buffer = File.read(file)

  %w[NOTION_API_TOKEN DAILY_TASK_DATABASE_ID].each do |key|
    buffer.gsub!(key, ENV[key])
  end

  File.open("dist/#{file_name}", "w") { |f| f.write(buffer) }
end