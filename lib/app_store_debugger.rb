def puts_with_indent(text, indent)
  puts "#{(' ' * indent)}#{text}"
end

def display(element, indent)
  if element.respond_to?(:each_child)
    puts_with_indent(element.name, indent)
    element.each_child { |child| display(child, indent + 1) }
  else
    text = element.to_s.chomp.strip
    puts_with_indent(text, indent) unless text.empty?
  end
end

http = SimpleHttp.new(App.first.url)
http.request_headers['User-Agent'] = 'iTunes/8.2.1 (Macintosh; U; PPC Mac OS X 10.5.8)'
http.request_headers['X-Apple-Store-Front'] = '143444,5'
response = http.get
doc = Hpricot::XML(response)
root = ((doc/'Document')[0]/'View')[0]
display(root, 0)

