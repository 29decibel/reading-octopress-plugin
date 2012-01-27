# Title: Amazon reading books tag for Jekyll
# Author: mike lee http://29decibel.me
# Description: Display books infos by supply a amazon book url
#
# Syntax {% reading url/to/books_on_amazon [read reading] %}
#
# Example:
# {% reading http://www.amazon.com/gp/product/B001C30BH6/ref=s9_wishf_gw_g351_t?ie=UTF8&coliid=IDF9XLPONVMAD&colid=9R2Z2VDYATDN&pf_rd_m=ATVPDKIKX0DER&pf_rd_s=right-3&pf_rd_r=0JHWXC2V73MXN60VZRM5&pf_rd_t=101&pf_rd_p=481918071&pf_rd_i=507846 read %}
# {% reading http://www.amazon.com/Entrepreneurs-Guide-Customer-Development-ebook/ reading %}
#
# Output:
# <div class='read'>
# 	<img src='books_url'></img>
# 	<span class='title'></span>
# 	<span rating='rate'>5</span>
# </div>
# <div class='reading'>
# 	<img src='books_url'></img>
# 	<span class='title'></span>
# 	<span rating='rate'>5</span>
# </div>
#
require 'nokogiri'
require 'open-uri'

module Jekyll

  class ReadingTag < Liquid::Tag
		@read
		@book_url = ''
		CACHE_INFO_SEP = '__@@__'

    def initialize(tag_name, markup, tokens)
			@book_url,@read = markup.split(' ')
			@cache_folder = File.expand_path '../caches',File.dirname(__FILE__)
			FileUtils.mkdir_p @cache_folder unless File.exist?(@cache_folder)
			@cache_infos = {}
			restore_cache if cache_exist?
      super
    end

		def cache_file
			@cache_file ||= File.join(@cache_folder,'reading_tag.cache')
		end

		def cache_exist?
			File.exist? cache_file
		end

		def restore_cache
			File.open(cache_file) do |file|
				while(line=file.gets)
					url,title,img,rate = line.split(CACHE_INFO_SEP)
					@cache_infos[url] = {:title => title,:img	=> img,:rate => rate}
				end
			end
		end


    def render(context)
      output = super
			# check cache
			if @cache_infos[@book_url]
				@title = @cache_infos[@book_url]['title']
				@img = @cache_infos[@book_url]['img']
				@rate = @cache_infos[@book_url]['rate']
			else
				puts "begin fetch book info of #{@book_url}"
				# get book infos 
				doc = Nokogiri::HTML(open(@book_url))
				@title = doc.at_css('#btAsinTitle').content
				if @title.length > 40
					@title = @title[0..40] + '...'
				end
				@img = doc.at_css('img#prodImage').attr('src')
				@rate = doc.at_css('.swSprite.s_star_4_5').attr('title')
				# cache infos
				save_to_cache_file(@book_url,@title,@img,@rate)
			end
			#render
      if @book_url
				reading_markup = "<div class='book_info #{@read}'>"
				reading_markup += "<a href='#{@book_url}'><img src='#{@img}'></img></a>"
				reading_markup += "<div class='book_title'>#{@title}</div>"
				reading_markup += "<div class='rate'>#{@rate}</div>"
				reading_markup += '</div>'
      else
        "Error processing input, expected syntax: {% reading url/to/books_url_at_amazon [read reading] %}"
      end
    end

		def save_to_cache_file(url,title,img,rate)
			puts 'save to cache file'
			File.open(cache_file,'a') do |file|
				file.puts([url,title,img,rate].join(CACHE_INFO_SEP))
			end
		end

  end
end

Liquid::Template.register_tag('reading', Jekyll::ReadingTag)


