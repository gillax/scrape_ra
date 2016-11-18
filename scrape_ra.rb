require 'mechanize'

module AudioFormat
  MP3 = ".mp3"
  M4A = ".m4a"
end

class ScrapeRA
  @@num = 0

  def self.title(_episode, _page)
    suffix = _page.search("h1.cloudcast-title").inner_text
    "#{_episode} #{suffix}"
  end

  def self.audio_id(_page)
    _page.search('span.play-button.play-button-cloudcast-page')[0][:'m-preview'].split('previews').last.gsub(AudioFormat::MP3, "")
  end

  def self.base_url(_num)
    "https://stream#{_num}.mixcloud.com"
  end


  def initialize(_episode, _dest)
    @agent = Mechanize.new

    #@agent.user_agent_alias = 'Mac Mozilla'
    #@agent.log = Logger.new('./debug.log')

    @episode = _episode
    @num = @@num = (@@num == 9) ? 1 : @@num + 1
    @dest = _dest
  end

  def scrape(_format)
    page = @agent.get("https://www.mixcloud.com/residentadvisor/ra#{@episode}/")

    @title = ScrapeRA.title(@episode, page)
    @audio_id = ScrapeRA.audio_id(page)

    if _format == AudioFormat::M4A
      begin
        m4a_download()
      rescue => e
        err_handler(e)
        pp "retry."
        mp3_download()
      end
    else
      mp3_download()
    end

  rescue => e
    err_handler(e)
  end


  private

  def m4a_download()
    @url = "#{ScrapeRA.base_url(@num)}/c/m4a/64#{@audio_id}#{AudioFormat::M4A}"
    download()
  end

  def mp3_download()
    @url = "#{ScrapeRA.base_url(@num)}/c/originals#{@audio_id}#{AudioFormat::MP3}"
    download()
  end

  def download()
    pp "Downloading... [#{@title}](#{@url})"
    @title.gsub!("/", "_") # slash to underscore
    @agent.get(@url).save("#{@dest}/#{@title}")
  end

  def err_handler(e)
    pp e
    puts e.backtrace.join("\n")
    pp "fail... [#{@title}](#{@url})"
  end

end
