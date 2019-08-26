import std.stdio;
import std.net.curl;
import arsd.dom;
import std.conv : to;
import std.algorithm : endsWith, map;
import std.array;
import std.container;
import std.uri : encode;
import translation;

void main(string[] args)
{
	if (args.length < 2)
	{
		writeln("Run this with at least one argument!");
		return;
	}

	const word = args[1];

	auto html_document = new Document(get_page_html(word));

	auto tt = get_result_tables(html_document);

	foreach (t; tt)
	{
		bool other = t.isOtherTerm;

		writeln(t);

		string category = "";
		foreach (d; t.data)
		{
			if (d.category == category)
			{
				write(", " ~ d.target);
			}
			else {
				writeln("\n" ~ d.category ~ ": " ~ d.target);
			}
		}
	}

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

	return tt;
}
