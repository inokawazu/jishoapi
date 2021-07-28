module main

import net.urllib as nu
import net.http as nh {get}
import x.json2

fn jisho_url(safequery string) string{
	return "https://jisho.org/api/v1/search/words?keyword=" + safequery
}

fn convert_search_to_jisho_url(search string) string {
	ss := nu.path_escape(search)
	return jisho_url(ss)
}

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
			'wordreadings' {
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

fn main() {
	resp := get(convert_search_to_jisho_url("#jlpt-n1 #verb"))?
	jjson := json2.raw_decode(resp.text) ? 
	println(typeof(jjson).name) 
	jjson_map := jjson.as_map()
	data_arry := jjson_map["data"].arr()
	println(data_arry.len)
	mut ents := []Entry{len: data_arry.len}
	
	for mut ent in ents {
		data := data_arry.pop()
		ent.from_json(data)
		println(ent.slug)
	}

	println("The number of results is ${ents.len}")
}
