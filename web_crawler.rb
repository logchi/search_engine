require 'net/http'

def web_crawl(seed)
  tocrawl = [seed]
  crawled = []
  until tocrawl.empty?
    seed_link = tocrawl.pop
    unless crawled.include?(seed_link)
      crawled << seed_link
      tocrawl = tocrawl | find_all_links( get_page(seed_link) )
    end
  end
  crawled
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
