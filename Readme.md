### Plugin to render books info at octopress
#### Installation
ensure such gem exist on you Gemfile

```ruby

gem 'nokogiry'
```

puts plugins contents in your octopress blog's directory

#### Usage

``` markdown
{% reading http://amazon_book_url read %}
```
#### Styles (example)
``` scss

.book_info{
	display:inline-block;
	padding:10px;
	float:left;
	margin:10px;
	border:1px solid #ccc;
	box-shadow:0px 0px 5px rgba(0,0,0,0.3);
	height:230px;
	.book_title{
		width:150px;
		font-size:0.8em;
	}
	.rate{
		font-style:italic;
		font-size:0.9em;
	}
	img{
		width:150px;
	}
}																						}
```

That's it. Enjoy!
