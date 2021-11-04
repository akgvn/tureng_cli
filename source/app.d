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
	bool abridged = false;
	string word;

	if (args.length < 2)
	{
		writeln("Run this with at least one argument!");
		return;
	}
	else if (args.length > 2)
	{
		foreach (ar; args)
		{
			if (ar == "-a")
			{
				abridged = true;
			}
			else
			{
				word = ar;
			}
		}
	}
	else
	{
		word = args[1];
	}

	auto html_document = new Document(get_page_html(word));

	auto ttables = get_result_tables(html_document);

	writer(ttables, abridged);
}

void writer(Translation_Table[] ttables, bool abridged)
{
	foreach (t; ttables)
	{
		bool other = t.isOtherTerm;

		if (abridged && other)
		{
			break;
		}

		write("# ", t.toString());

		string category = "";
		if (!other)
		{
			foreach (d; t.data)
			{
				if (d.category == category)
				{
					write(", " ~ d.target);
				}
				else
				{
					category = d.category;
					write("\n" ~ d.category ~ ": " ~ d.target);
				}
			}
		}
		else
		{
			foreach (d; t.data)
			{
				if (d.category == category)
				{
					write("\n\t" ~ d.source ~ " : " ~ d.target);
				}
				else
				{
					category = d.category;
					write("\n" ~ d.category ~ " => \n\t" ~ d.source ~ " : " ~ d.target);
				}
			}
		}
		writeln();
		writeln();
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

	foreach (idx, table; tables)
	{
		tt[idx] = Translation_Table(table);
	}

	return tt;
}
