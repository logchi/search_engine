require 'net/http'

def web_crawl(seed, max_depth)
  next_tocrawl = [seed]
  crawled = []
  depth = 0
  while depth < max_depth && !next_tocrawl.empty?
    tocrawl = next_tocrawl
    tocrawl.each do |seed_link|
      unless crawled.include?(seed_link)
        next_tocrawl = next_tocrawl | find_all_links( get_page(seed_link) )
        crawled << seed_link
      end
      next_tocrawl.delete seed_link
    end
    depth = depth + 1
  end
  crawled = crawled + next_tocrawl
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
  seed = "http://www.sohu.com/"
  (0..2).each do |depth|
    puts web_crawl(seed, depth)
    boundry
  end
end

def boundry
  puts
  3.times { print "=" * 40 + "\n" }
  puts
end

test
