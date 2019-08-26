import std.stdio;
import std.net.curl;
import arsd.dom;
import std.conv : to;
import std.algorithm : endsWith, map;
import std.array;
import std.container;
import std.uri : encode;
import translation;

void printer(Array!(string[]) data)
{
	string category = "";
	string keyword = ""; // TODO kelimeler aynı mı kontrol et row[2]
	foreach (row; data)
	{
		if (category != row[1])
		{
			if (category != "")
				writeln();

			category = row[1];
			write(category, ": ", row[3]);
		}
		else if (category == row[1])
		{
			write(", ", row[3]);
		}
	}
	writeln();
}

void main(string[] args)
{
	if (args.length < 2)
	{
		writeln("Run this with at least one argument!");
		return;
	}

	const word = args[1];

	auto html_document = new Document(get_page_html(word));

	

	get_result_tables(html_document);

	// auto word_data = new Translation[inner_data.length];

	int count = 0;
	/*
	foreach (ref d; inner_data)
	{
		word_data[count++] = new Translation(d);
	}

	writeln(word_data);
	*/
}

string get_page_html(string word)
{
	string address = "https://tureng.com/en/turkish-english/" ~ word;
	return to!string(get(address.encode()));
}

auto get_result_tables(Document doc)
{
	auto tables = doc.querySelectorAll("#englishResultsTable");
	// auto table = table_html.querySelectorAll("table");

	auto tt = new Translation_Table[tables.length];

	int count = 0;
	foreach (table; tables)
	{
		tt[count++] = new Translation_Table(table);
	}
}
