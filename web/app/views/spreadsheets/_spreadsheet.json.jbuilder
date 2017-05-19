json.extract! spreadsheet, :name, :initial_page

json.pages spreadsheet.pages do |page|
  json.partial! 'pages/page', page: page
end
