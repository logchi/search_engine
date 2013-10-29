page = '<a class="dropdown-toggle" href="/courses">Course Catalog</a>'
start_anchor = page.index(/<\s*a.+href=/)
start_href = page.index('href=', start_anchor)
start_link = page.index('"', start_href) + 1
end_link = page.index('"', start_link) - 1
first_link = page[start_link..end_link]
puts first_link

