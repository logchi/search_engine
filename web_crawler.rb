require 'net/http'

def web_crawl(seed, max_depth)
  tocrawl = [seed]
  crawled = []
  next_tocrawl = []
  depth = 0
  graph = {}  # Directed graph for all crawled urls
  index = {}  # Index for all words in the crawled pages
  until (depth > max_depth) || (tocrawl.empty?)
    seed = tocrawl.pop
    unless crawled.include?(seed)
      content = get_page(seed)
      add_page_to_index(index, seed, content)
      outlinks = find_all_links(content)
      graph[seed] = outlinks
      next_tocrawl = next_tocrawl | outlinks
      crawled << seed
    end
    if tocrawl.empty?
      tocrawl, next_tocrawl = next_tocrawl, []
      depth += 1
    end
  end
  return index, graph
end

def urank(graph)
  total_links = graph.size
  d = 0.8
  depth = 10  # loop times for getting the ranks
  ranks = {}
  graph.each_key do |url|
    ranks[url] = 1.0 / total_links
  end
  depth.times do
    newranks = {}
    graph.each_key do |url|
      newrank = (1 - d) / total_links
      graph.each do |link, outlinks|
        if outlinks.include?(url)
	  newrank += d * ranks[link] / outlinks.size
	end
      end
      newranks[url] = newrank
    end
    ranks = newranks
  end
  ranks
end

def lookup(keyword, index, ranks)
  index[keyword].sort_by! {|link| ranks[link] }
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
  index, graph = web_crawl(seed, 1)
  ranks = urank(graph)
  puts lookup("5,value", index, ranks)
end

test
