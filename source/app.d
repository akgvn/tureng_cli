import std.stdio;
import std.net.curl;
import arsd.dom;
import std.conv;
import std.string;
import std.algorithm;
import std.array;
import std.container;
import std.uri : encode;
import translation;

string reducer(string st)
{
	string temp = strip(to!string(st));

	if (temp.endsWith("."))
	{
		temp = strip(temp[0 .. $ - 2]);
	}

	return temp;
}

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
	/*
	if (args.length < 2) {
		writeln("Argüman olarak kelime vermelisin!");
		return;
	}*/

	const word = "popo"; // args[1];

	auto html_document = new Document(get_page_html(word));

	// Returns 2 tables: Meanings, other terms
	auto tables = html_document.querySelectorAll("#englishResultsTable");

	Array!(string[]) inner_data;
	foreach (table; tables)
	{

		foreach (e; table.querySelectorAll("tr"))
		{
			auto data = e.querySelectorAll("td");

			if (data.length > 2)
			{
				inner_data.insert(data.map!(e => reducer(e.innerText)).array);
			}
		}
		printer(inner_data);
		if (tables.length > 1)
			writeln("---");
	}

	auto word_data = new Translation[inner_data.length];

	int count = 0;
	foreach (ref d; inner_data)
	{
		word_data[count++] = new Translation(d);
	}

	writeln(word_data);
}

string get_page_html(string word)
{
	string address = "https://tureng.com/en/turkish-english/" ~ word;
	return to!string(get(address.encode()));
}
