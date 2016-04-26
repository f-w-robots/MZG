require 'docker'

['ruby'].each do |lang|
  puts "pullign #{lang}"
  Docker::Image.build_from_dir('images/', { 'dockerfile' => "Dockerfile.#{lang}" }) do |v|
    if (log = JSON.parse(v)) && log.has_key?("stream")
      $stdout.puts log["stream"]
    end
  end
end

puts "finish"
