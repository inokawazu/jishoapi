module main

import net.urllib as nu
import net.http as nh {get}
import x.json2
import os

struct WordReading {
	mut:
	word string
	reading string
}

struct Sense {
	mut:
	english_definitions []string
	parts_of_speech []string
	links []string
	restrictions []string
	see_also []string
	antonyms []string
	source []string
	info []string
}

struct Attribution {
	mut: 
	jmdict string
	dmnedict string
	dbpedia string
}

struct Entry { 
	mut:
		slug string
		is_common bool
		tags []string
		jlpt []string
		wordreadings []WordReading
		senses []Sense
		attribution Attribution
}

struct JishoResponse{
	mut:
	meta map[string]json2.Any
	data []Entry
}

struct JishoWordSearch {
	base_url string = "https://jisho.org/api/v1/search/words" 
	mut:
	keyword string [required]
	page int = 1
	response JishoResponse = JishoResponse{}
}

fn (mut wr WordReading) from_json(f json2.Any) {
	obj := f.as_map()
	for k, v in obj {
		match k {
			'word' { wr.word = v.str() }
			'reading' { wr.reading = v.str()}
			else {}
		}
	}
}

fn (mut sn Sense) from_json(f json2.Any) {
	obj := f.as_map()
	for k, v in obj {
		match k {
			'english_definitions' { sn.english_definitions = v.arr().map(it.str()) }
			'parts_of_speech' { sn.parts_of_speech = v.arr().map(it.str()) }
			'links' { sn.links = v.arr().map(it.str()) }
			'restrictions' { sn.restrictions = v.arr().map(it.str()) }
			'see_also' { sn.see_also = v.arr().map(it.str()) }
			'antonyms' { sn.antonyms = v.arr().map(it.str()) }
			'source' { sn.source = v.arr().map(it.str()) }
			'info' { sn.info = v.arr().map(it.str()) }
			else {}
		}
	}
}

fn (mut attr Attribution) from_json(f json2.Any) {
	obj := f.as_map()
	for k, v in obj {
		match k {
			'jmdict' { attr.jmdict = v.str() }
			'jmnedict' { attr.dmnedict = v.str()}
			'dbpedia' { attr.dbpedia = v.str()}
			else {}
		}
	}
}

fn (mut ent Entry) from_json(f json2.Any) {
	obj := f.as_map()
	for k, v in obj {
		match k {
			'slug' { ent.slug = v.str() }
			'is_common' { ent.is_common = v.bool() }
			'tags' { ent.tags = v.arr().map(it.str()) }
			'jlpt' { ent.jlpt = v.arr().map(it.str()) }
			'japanese' {
				data := v.arr()
				ent.wordreadings = []WordReading{len: data.len}
				for mut wr in ent.wordreadings { 
					wr.from_json(data.pop()) 
				}
			}
			'senses' {
				data := v.arr()
				ent.senses = []Sense{len: data.len}
				for mut sn in ent.senses { 
					sn.from_json(data.pop()) 
				}
			}
			'attribution' { ent.attribution.from_json(v) }
			else {}
		}
	}
}

fn (mut jr JishoResponse) from_json(f json2.Any) {
	obj := f.as_map()
	for k, v in obj {
		match k {
			'meta' { jr.meta = v.as_map() }
			'data' {
				data := v.arr()
				jr.data = []Entry{len: data.len}
				for mut ent in jr.data { 
					ent.from_json(data.pop()) 
				}
			}
			else {}
		}
	}
}

fn (jr JishoResponse) is_ok() bool {
	status := jr.meta["status"].int()// or {error("Error with status code for Jisho Response.")}
	return status == int(nh.Status.ok)
}

fn (jws JishoWordSearch) url() string {
	kw := "?keyword=" + nu.path_escape(jws.keyword)
	pg := "&page=" + jws.page.str()
	return jws.base_url + kw + pg 
}

fn (mut jws JishoWordSearch) search() ? {
	resp := get(jws.url()) ?
	jjson := json2.raw_decode(resp.text) ? 
	jws.response.from_json(jjson)
}

fn main() {

	if os.args.len>1 {
		search_string := os.args[1..].join(" ")
		// println("The arg string is ${}")
		mut jws := JishoWordSearch{keyword: search_string}
		// println(jws)
		jws.search()?

		for ent in jws.response.data {
			// println("Slug: ${ent.slug} ")
			println("WordReadings: ${ent.wordreadings} ")
			println("WordReadings: ${ent.senses} ")
			println("")
		}

	}

}
