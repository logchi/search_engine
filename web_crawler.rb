require 'net/http'

def web_crawl(seed, max_depth)
  tocrawl = [seed]
  crawled = []
  next_tocrawl = []
  depth = 0
  index = {}
  until (depth > max_depth) || (tocrawl.empty?)
    seed = tocrawl.pop
    unless crawled.include?(seed)
      content = get_page(seed)
      add_page_to_index(index, seed, content)
      next_tocrawl = next_tocrawl | find_all_links(content)
      crawled << seed
    end
    if tocrawl.empty?
      tocrawl, next_tocrawl = next_tocrawl, []
      depth += 1
    end
  end
  index
end

def lookup(keyword, index)
  index[keyword]
end

def add_page_to_index(index, url, content)
  words = content.split
  words.each do |word|
    add_url_to_index(index, word, url)
  end
end

def add_url_to_index(index, keyword, url)
  index.has_key?(keyword) ? index[keyword] <<  url 
                          : index[keyword] = [url]
end

def get_page(link)
  begin
    Net::HTTP.get( URI(link) )
  rescue Exception
    ""
  end
end

def find_link(page, start_anchor)
  start_href = page.index('href=', start_anchor)
  start_link = page.index('"', start_href) + 1
  end_link   = page.index('"', start_link) - 1
  link       = page[start_link..end_link]
  return link, end_link + 1
end

def find_all_links(page)
  links = []
  start = 0
  while start_anchor = page.index(/<\s*a\s.*href=/, start) 
    link, start = find_link(page, start_anchor)
    links << link
  end
  links
end

def test
  seed = "http://www.baidu.com/"
  index = web_crawl(seed, 1)
  index.each {|entry| p entry }
end

def boundry
  puts
  3.times { print "=" * 40 + "\n" }
  puts
end

test
