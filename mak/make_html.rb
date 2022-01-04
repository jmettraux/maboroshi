
html =
  File.read('www/index._html')

style = %w[
  www/css/normalize-8.0.1.css
  www/css/maboroshi.css ]
    .inject('') { |s, path| s + "\n" + File.read(path) }
script = %w[
  www/js/jaabro-1.4.0.com.js
  www/js/maboroshi.js
  www/js/h.min.js
  www/js/qrcode.min.js ]
    .inject('') { |s, path| s + "\n" + File.read(path) }

i = html.index('/** STYLE **/')
html.insert(i + 13, style);

i = html.index('/** SCRIPT **/')
html.insert(i + 14, script);

File.open('www/index.html', 'wb') { |f| f.write(html) }

