# Requires
moment = require 'moment'
moment.lang('ru')

# Define the DocPad Configuration
docpadConfig = {
	templateData:
		site:
    	title: "Разработчик 1C"

		getPreparedTitle: -> if @document.title then "#{@document.title} | #{@site.title}" else @site.title
		formatDate: (date,format='LLL') -> return moment(date).format(format)

	collections:
		develop: ->
			@getCollection("html").findAllLive({categories: "develop1c"})

		skd: ->
			@getCollection("html").findAllLive({categories: "skd"})

		pages: ->
		    @getCollection("html").findAllLive({relativeOutDirPath: 'posts'}, [date:-1])

	plugins:
	  rss:
	    default:
	      collection: 'pages'
	      url: '/rss.xml' # optional, this is the default

    ghpages:
        deployRemote: 'origin'
        deployBranch: 'gh-pages'
}

# Export the DocPad Configuration
module.exports = docpadConfig
