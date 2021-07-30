# jishoapi
A vlang library that provides a jisho.org API interface.

# API

The `JishoWordSearch` struct is used to encapsulate the a API called to jisho.org's
free api. The `keyword` field must be specified which is the keyword query term used in the 
jisho.org API. `page` is an `int` field that represents the requested page. The method `.search()` 
performs the API called with the specific `JishoWordSearch`, mutating the `response`.

## Example (CLI App)

This example code is a simple CLI app that prints (ugly) wordreadings and misc stuff
from a search. The usage is `./appname <jisho query>`.

```
module main
import os
import jishoapi {JishoWordSearch}

fn main() {

	if os.args.len>1 {
		search_string := os.args[1..].join(" ")
		mut jws := JishoWordSearch{keyword: search_string}
		jws.search()?

		for ent in jws.response.data {
			println("WordReadings: ${ent.wordreadings} ")
			println("WordReadings: ${ent.senses} ")
			println("")
		}

	}

}
```
