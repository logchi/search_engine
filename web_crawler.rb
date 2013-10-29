require 'net/http'

page = Net::HTTP.get('stackoverflow.com', '/index.html')

def find_link(page, start_anchor)
  start_href   = page.index('href=', start_anchor)
  start_link   = page.index('"', start_href) + 1
  end_link     = page.index('"', start_link) - 1
  link         = page[start_link..end_link]
  return link, end_link + 1
end

links = []
start = 0
while start_anchor = page.index(/<\s*a.+href=/, start) 
  link, start = find_link(page, start_anchor)
  links << link
end

puts links
