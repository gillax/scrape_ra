require 'bundler'
Bundler.require
require_relative 'scrape_ra'

dir_path = "" # = "build"
FileUtils.mkdir_p(dir_path) unless FileTest.exist?(dir_path)

episodes = [1,2,3]

Parallel.each(episodes, in_threads: 5) {|episode|
  ScrapeRA.new(episode, dir_path).scrape(AudioFormat::M4A)
}
