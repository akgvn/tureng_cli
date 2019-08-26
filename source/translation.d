module translation;

import std.array : appender;
import std.stdio;
import arsd.dom : Element;

class Translation
{
    public string type;
    public string source;
    public string target;

    this(string[] data)
    {
        this.type = data[1];
        this.source = data[2];
        this.target = data[3];
    }

    override string toString()
    {
        return "(" ~ this.type ~ ") " ~ this.source ~ ": " ~ target;
    }
}

class Translation_Table
{
    public string source_lang;
    public string target_lang;
    public Translation[] data;

    this(Element table_html)
    {
        import std.algorithm : map, filter;
        import std.string : strip;
        import std.array : array;

        auto inner_data = appender!(string[]);
        foreach (table_row; table_html.querySelectorAll("tr"))
        {
            auto table_headers = table_row.querySelectorAll("th")
                .map!(d => strip(d.innerText)).array;

            if (table_headers.array() != [])
            {
                this.source_lang = table_headers[1];
                this.target_lang = table_headers[2];
            }
            else
            {
                auto table_data = table_row.querySelectorAll("td")
                    .map!(d => strip(d.innerText)).array;

                if (table_data.length > 2) // Filter out the unimportant noise.
                {
                    inner_data.put(table_data.map!(st => reducer(st)).array);
                }
            }
        }
        writeln(inner_data);
        writeln();
    }
}

string reducer(string st)
{
    import std.string : strip;
    import std.conv : to;
    import std.algorithm : endsWith;

    string temp = strip(to!string(st));

    if (temp.endsWith("."))
    {
        temp = strip(temp[0 .. $ - 2]);
    }

    return temp;
}
